import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter/user_data.dart';
import 'package:my_first_flutter/utils.dart';
import 'app.dart';
import 'main.dart';

class SetupPage4 extends StatefulWidget {
  UserData? user;
  final XFile image;
  final bool fromCamera;
  final bool fromUpdate;

  SetupPage4({Key? key, this.user, required this.image, required this.fromCamera, required this.fromUpdate})
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
              backgroundImage: FileImage(File(widget.image.path)),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: confirmCallback,
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all(Size.fromWidth(
                    MediaQuery.of(context).size.width * 0.7)),
              ),
              child: widget.fromUpdate ? const Text('Update profile picture') : const Text('Complete sign up'),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                if (widget.fromCamera) Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
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

  Future confirmCallback() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    // Store image on Firebase
    String imagePath = 'pfp/${FirebaseAuth.instance.currentUser!.uid}.jpg';
    Reference ref = FirebaseStorage.instance.ref().child(imagePath);
    await ref.putFile(File(widget.image.path));
    String imageURL = await ref.getDownloadURL();

    if (widget.fromUpdate) {
      try {
        await FirebaseFirestore.instance
            .collection('userData')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'pfpURL': imageURL});
      } on FirebaseAuthException {
        Utils.showSnackBar('Unable to update profile picture');
      } finally {
        Utils.showSnackBar('Profile picture successfully updated', isBad: false);
        if (widget.fromCamera) Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        setState(() {
          imageCache.clear();
          imageCache.clearLiveImages();
        });
      }
    } else {
      try {
        widget.user?.pfpURL = imageURL;
        final docUser = FirebaseFirestore.instance
            .collection('userData')
            .doc(FirebaseAuth.instance.currentUser!.uid);
        await docUser.set(widget.user!.toJson());
      } on FirebaseAuthException {
        Utils.showSnackBar('Unable to set up profile');
      } finally {
        Utils.showSnackBar('Set up complete!', isBad: false);
        setState(
              () {
            done = true;
          },
        );
        Navigator.pop(context);
      }
    }
  }
}
