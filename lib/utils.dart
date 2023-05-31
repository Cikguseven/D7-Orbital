import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:my_first_flutter/user_class.dart';

class Utils {
  static final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  static showSnackBar(String? text) {
    if (text == null) return;

    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: Colors.red,
    );
    scaffoldKey.currentState!
    ..removeCurrentSnackBar()
    ..showSnackBar(snackBar);
  }
  
  /// Gets the current firebase authenticated user. Only use after signed in!
  static User? getAuthUser() {
    final authUser = FirebaseAuth.instance.currentUser;
    assert(authUser != null, "No currently logged in user");
    return authUser;
  }
  
  /// Gets the current firebase authenticated user's data. Only use after signed in! (ASYNC)
  static Future<UserData?> getUserData({String? uid}) async { // uid optional, if not give, takes the current logged in user
    final docUser = FirebaseFirestore.instance.collection('userData').doc(uid ?? getAuthUser()!.uid);
    return docUser.get().then(
          (DocumentSnapshot doc) {
        if (doc.exists) {
          // user has been created before, proceed to read
          print("exists");
          final data = doc.data() as Map<String, dynamic>;
          return UserData.fromJson(data);
        } else {
          // new user detected, create user and proceed with setup
          print("no exists");
          return UserData.NewUser;
        }
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  /// Converts Date time to string to save to database. DD/MM/YYYY
  static String dateTimeToString(DateTime dt) {
    String day = dt.day.toString().padLeft(2, "0");
    String month = dt.month.toString().padLeft(2, "0");

    return "$day/$month/${dt.year}";
  }
  
  /// Converts the stored string taken from the database back to DT. Do not use out of context.
  static DateTime stringToDateTime(String dt) {
    int day = int.parse(dt.substring(0, 2));
    int month = int.parse(dt.substring(3, 5));
    int year = int.parse(dt.substring(6, 10));
    print("Day: $day");
    print("Month: $month");
    print("Year: $year");
    return DateTime(year, month, day);
  }
  
  /// Checks if given string is valid date
  static bool validDateTime(String dt) {
    if (dt.length < 10) return false;
    int? day = int.tryParse(dt.substring(0, 2));
    int? month = int.tryParse(dt.substring(3, 5));
    int? year = int.tryParse(dt.substring(6, 10));
    DateFormat format = DateFormat("dd/MM/yyyy");
    try { // TODO: Fix this, dont use try catch as control flow
      DateTime finalDate = format.parseStrict("$day/$month/$year");
      print("Final: ${Utils.dateTimeToString(finalDate)}");
      print("Initial: $dt");
    } on FormatException catch (e) {
      return false;
    }
    return true;
  }
}