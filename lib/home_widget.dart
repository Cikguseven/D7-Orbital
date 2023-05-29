import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_first_flutter/user_class.dart';
import 'package:my_first_flutter/utils.dart';

class HomeWidget extends StatelessWidget {
  UserData user;
  HomeWidget({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(height: MediaQuery.of(context).size.height / 3),
            Text("Signed in as:"),
            Text(user.firstName + " " + user.lastName),
          ],
        ),
      ),
    );
  }
}
