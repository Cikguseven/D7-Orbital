import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:intl/intl.dart';

import 'comment_data.dart';
import 'day_log.dart';
import 'post_data.dart';
import 'user_data.dart';

class Utils {
  static final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  static showSnackBar(
    String? text, {
    bool isBad = true,
    int duration = 2,
  }) {
    if (text == null) return;

    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: isBad ? Colors.red : Colors.green,
      duration: Duration(seconds: duration),
    );
    scaffoldKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Signs into firebase
  static firebaseSignIn(String email, String password) {
    return FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  }

  /// Creates firebase auth user
  static firebaseCreateUser(String email, String password) {
    return FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
  }

  /// Gets the current firebase authenticated user.
  /// Only use after signed in!
  static User? getAuthUser() {
    final authUser = FirebaseAuth.instance.currentUser;
    assert(authUser != null, 'No currently logged in user');
    return authUser;
  }

  /// Setups new user data, putting into firebase
  static firebaseSetupNewUser(UserData user) async {
    // Sets the fields
    final docUser = FirebaseFirestore.instance
        .collection('userData')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    await docUser.set(user.toJson());

    // Creates the diary collection
    docUser.collection('diary').add({'First Diary': 0});
  }

  /// Gets the current firebase authenticated user's data.
  /// Only use after signed in! (ASYNC)
  static Future<UserData> getUserData({String? uid}) async {
    final docUser = FirebaseFirestore.instance
        .collection('userData')
        .doc(uid ?? getAuthUser()!.uid);

    return docUser.get().then(
      (DocumentSnapshot doc) {
        if (doc.exists) {
          // user has been created before, proceed to read
          final data = doc.data() as Map<String, dynamic>;
          UserData user = UserData.fromJson(data);
          return user;
        }
        // new user detected, create user and proceed with setup
        return UserData.newUser;
      },
    );
  }

  static Future<void> updateUserData(Map<String, dynamic> changes) async {
    final docUser = FirebaseFirestore.instance
        .collection('userData')
        .doc(getAuthUser()!.uid);

    docUser.update(changes);
  }

  static Future<DayLog> getDayLog() async {
    String dayLogName = DayLog.dayLogNameFromTimeStamp(Timestamp.now());
    final docDayLog = FirebaseFirestore.instance
        .collection('userData')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('diary')
        .doc(dayLogName);

    return docDayLog.get().then((doc) {
      if (doc.exists) {
        return DayLog.fromJson(doc.data()!);
      } else {
        return DayLog.createNew(DateTime.now());
      }
    });
  }

  static Future<List<DayLog>> getWeekLog() async {
    List<DayLog> logs = [];
    final collection = FirebaseFirestore.instance
        .collection('userData')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('diary');
    for (int i = 0; i < 7; i++) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      String dayLogName =
          DayLog.dayLogNameFromTimeStamp(Timestamp.fromDate(date));
      await collection.doc(dayLogName).get().then((doc) {
        if (doc.exists) {
          logs.add(DayLog.fromJson(doc.data()!));
        } else {
          logs.add(DayLog.createNew(date));
        }
      });
    }
    return logs;
  }

  /// Gets all post data by user.
  static Future<List<PostData>> getDiary() async {
    List<PostData> posts = [];
    FirebaseFirestore.instance
        .collection('posts')
        .where('ownerID', isEqualTo: getAuthUser()!.uid)
        .orderBy('postTime', descending: true)
        .snapshots()
        .forEach((querySnapshot) {
      for (var post in querySnapshot.docs) {
        posts.add(PostData.fromJson(post.data()));
      }
    });
    return posts;
  }

  /// Gets all current post data.
  static Future<List<PostData>> getPosts() async {
    List<PostData> posts = [];
    FirebaseFirestore.instance
        .collection('posts')
        .where('forDiary', isEqualTo: false)
        .orderBy('postTime', descending: true)
        .snapshots()
        .forEach((querySnapshot) {
      for (var post in querySnapshot.docs) {
        posts.add(PostData.fromJson(post.data()));
      }
    });
    return posts;
  }

  /// Gets a specific post.
  static Future<PostData?> getPostByID(String postID) async {
    final post =
        await FirebaseFirestore.instance.collection('posts').doc(postID).get();
    if (post.exists) {
      return PostData.fromJson(post.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  /// Gets all comment data from specified post.
  static Future<List<CommentData>> getComments(String postID) async {
    List<CommentData> comments = [];
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postID)
        .collection('comments')
        .orderBy('postTime', descending: false)
        .snapshots()
        .forEach((querySnapshot) {
      for (var comment in querySnapshot.docs) {
        comments.add(CommentData.fromJson(comment.data()));
      }
    });
    return comments;
  }

  static Image appLogo(context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Image.asset('assets/logo-white-text.png',
          width: 0.8 * MediaQuery.of(context).size.width);
    }
    return Image.asset('assets/logo-black-text.png',
        width: 0.8 * MediaQuery.of(context).size.width);
  }

  static Container sectionBreak(context) {
    return Container(
      height: 1,
      width: double.infinity,
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.black
          : Colors.white,
    );
  }

  /// Converts Date time to string to save to database. DD/MM/YYYY
  static String dateTimeToString(DateTime dt) {
    String day = dt.day.toString().padLeft(2, '0');
    String month = dt.month.toString().padLeft(2, '0');

    return '$day/$month/${dt.year}';
  }

  /// Converts the stored string taken from the database back to DT.
  /// Do not use out of context.
  static DateTime stringToDateTime(String dt) {
    int day = int.parse(dt.substring(0, 2));
    int month = int.parse(dt.substring(3, 5));
    int year = int.parse(dt.substring(6, 10));
    return DateTime(year, month, day);
  }

  /// Checks if given string is valid date
  static bool validDateTime(String dt) {
    if (dt.length < 10) return false;
    int? day = int.tryParse(dt.substring(0, 2));
    int? month = int.tryParse(dt.substring(3, 5));
    int? year = int.tryParse(dt.substring(6, 10));
    DateFormat format = DateFormat('dd/MM/yyyy');
    if (year! > DateTime.now().year || year < 1907) return false;
    try {
      // TODO: Fix this, dont use try catch as control flow
      format.parseStrict('$day/$month/$year');
    } on FormatException {
      return false;
    }
    return true;
  }

  // ======= UI Stuff =======

  /// To create a Material colour for Themedata from Hex value.
  /// From https://medium.com/@nickysong/creating-a-custom-color-swatch-in-flutter-554bcdcb27f3
  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  /// Creates a text field that utilises headlineMedium style.
  /// Used for header.
  static Text createHeadlineMedium(String text, BuildContext context,
      {TextAlign align = TextAlign.center}) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineMedium,
      textAlign: align,
    );
  }

  /// Creates a text field that utilises headlineSmall style.
  /// Used for smaller header.
  static Text createHeadlineSmall(String text, BuildContext context,
      {TextAlign align = TextAlign.center}) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineSmall,
      textAlign: align,
    );
  }

  /// Creates a text field that utilises titleSmall style.
  /// Used for regular text.
  static Text createTitleMedium(String text, BuildContext context,
      {TextAlign align = TextAlign.center}) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium,
      textAlign: align,
    );
  }

  /// Creates a text field that utilises titleSmall style.
  /// Used for smaller regular text.
  static Text createTitleSmall(String text, BuildContext context,
      {TextAlign align = TextAlign.center}) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall,
      textAlign: align,
    );
  }

  static Text createLabelLarge(String text, BuildContext context,
      {TextAlign align = TextAlign.center}) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge,
      textAlign: align,
    );
  }
}
