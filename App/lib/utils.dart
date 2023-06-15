import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:my_first_flutter/post_class.dart';
import 'package:my_first_flutter/user_class.dart';

import 'comment_class.dart';

class Utils {
  static final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  static showSnackBar(String? text, {bool isBad = true}) {
    if (text == null) return;

    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: isBad ? Colors.red : Colors.green,
    );
    scaffoldKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Gets the current firebase authenticated user.
  /// Only use after signed in!
  static User? getAuthUser() {
    final authUser = FirebaseAuth.instance.currentUser;
    assert(authUser != null, "No currently logged in user");
    return authUser;
  }

  /// Gets the current firebase authenticated user's data.
  /// Only use after signed in! (ASYNC)
  static Future<UserData?> getUserData({String? uid}) async {
    // uid optional, if not give, takes the current logged in user
    final docUser = FirebaseFirestore.instance
        .collection('userData')
        .doc(uid ?? getAuthUser()!.uid);

    return docUser.get().then(
      (DocumentSnapshot doc) {
        if (doc.exists) {
          // user has been created before, proceed to read
          final data = doc.data() as Map<String, dynamic>;
          return UserData.fromJson(data);
        } else {
          // new user detected, create user and proceed with setup
          return UserData.newUser;
        }
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  /// Gets all current post data.
  static Future<List<PostData>> getPosts() async {
    List<PostData> posts = [];
    FirebaseFirestore.instance
        .collection('posts')
        .orderBy('postTime', descending: true)
        .snapshots()
        .forEach(
      (querySnapshot) {
        for (var post in querySnapshot.docs) {
          final data = post.data();
            posts.add(PostData.fromJson(data));
        }
      }
    );
    return posts;
  }

  /// Gets all comment data from specified post.
  static Future<List<CommentData>> getComments(String postID) async {
    List<CommentData> comments = [];
    FirebaseFirestore.instance
        .collection('comments')
        .doc(postID)
        .collection('comments')
        .orderBy('postTime', descending: true)
        .snapshots()
        .forEach(
            (querySnapshot) {
          for (var comment in querySnapshot.docs) {
            final data = comment.data();
            comments.add(CommentData.fromJson(data));
          }
        }
    );
    return comments;
  }
  //
  // /// Gets the number of comments of specified post.
  // static Future<int> getCommentCount(String postID) async {
  //   AggregateQuerySnapshot query = await FirebaseFirestore.instance
  //       .collection('posts')
  //       .doc(postID)
  //       .collection('comments')
  //       .count()
  //       .get();
  //   return query.count;
  // }

  /// Converts Date time to string to save to database. DD/MM/YYYY
  static String dateTimeToString(DateTime dt) {
    String day = dt.day.toString().padLeft(2, "0");
    String month = dt.month.toString().padLeft(2, "0");

    return "$day/$month/${dt.year}";
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
    DateFormat format = DateFormat("dd/MM/yyyy");
    try {
      // TODO: Fix this, dont use try catch as control flow
      format.parseStrict("$day/$month/$year");
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

  /// Simple create vertical whitespace.
  static Widget createVerticalSpace(double pixels) {
    return SizedBox(
      height: pixels,
    );
  }

  /// Simple create horizontal whitespace.
  static Widget createHorizontalSpace(double pixels) {
    return SizedBox(
      width: pixels,
    );
  }
}
