import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter/setup_page_3.dart';
import 'package:my_first_flutter/user_data.dart';
import 'package:my_first_flutter/utils.dart';
import 'app.dart';
import 'main.dart';

class SetupPage4 extends StatefulWidget {
  final UserData user;
  final XFile image;

  const SetupPage4({Key? key, required this.user, required this.image})
      : super(key: key);

  @override
  State<SetupPage4> createState() => _SetupPage4();
}

class _SetupPage4 extends State<SetupPage4> {
  bool done = false;

  @override
  Widget build(BuildContext context) {
    return done
        ? const App()
        : Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 100),
            Utils.createTitleMedium("Your profile picture", context),
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 120,
              // Change to user's profile photo eventually
              backgroundImage: FileImage(File(widget.image.path)),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: newUserSetupCallback,
              icon: Icon(Icons.person, color: Colors.white),
              label: const Text('This is me'),
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all(Size.fromWidth(
                    MediaQuery.of(context).size.width * 0.7)),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: openSetupPage3,
              icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
              label: const Text('Back'),
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all(Size.fromWidth(
                    MediaQuery.of(context).size.width * 0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future newUserSetupCallback() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    // Store image on Firebase
    String imagePath = 'posts/${FirebaseAuth.instance.currentUser!.uid}.jpg';
    Reference ref = FirebaseStorage.instance.ref().child(imagePath);
    await ref.putFile(File(widget.image.path));
    String imageURL = await ref.getDownloadURL();
    widget.user.pfpURL = imageURL;

    try {
      final docUser = FirebaseFirestore.instance
          .collection('userData')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      await docUser.set(widget.user.toJson());
      setState(
        () {
          done = true;
        },
      );
    } on FirebaseAuthException {
      Utils.showSnackBar('Unable to set up profile');
    }
  }

  void openSetupPage3() {
    setState(
          () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    SetupPage3(user: widget.user)));
      },
    );
  }
}
