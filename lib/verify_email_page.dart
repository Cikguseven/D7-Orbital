import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_first_flutter/utils.dart';
import 'package:my_first_flutter/app.dart';

import 'home_widget.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({Key? key}) : super(key: key);

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {

  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    // Won't be null cause called after valid login, which requires a created user
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    print("IS EMAIL VERIFIED? $isEmailVerified");
    if (!isEmailVerified) {
      sendEmailVerification();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (timer) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload(); // reload to reflect changes in verification status
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      print("IS EMAIL VERIFIED? $isEmailVerified");
    });

    if (isEmailVerified) timer?.cancel();
  }

  int cooldown = 0;
  bool canSendEmail = true;

  Future sendEmailVerification() async {
    if (!canSendEmail) {
      Utils.showSnackBar("Can't resend for another $cooldown seconds");
      return;
    }
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      canSendEmail = false;
      setState(() => cooldown = 10);
      Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          setState(() => cooldown--);
          if (cooldown <= 0) {
            canSendEmail = true;
            timer.cancel();
          }
        },
      );
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
      canSendEmail = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerified
        ? App()
        : Scaffold(
            appBar: AppBar(
              title: const Text("Verify Email"),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SizedBox(height: MediaQuery.of(context).size.height / 3),
                  Text("A verification email has been sent to:"),
                  Text("${FirebaseAuth.instance.currentUser!.email}"),
                  ElevatedButton.icon(
                    onPressed: sendEmailVerification,
                    icon: Icon(Icons.email_outlined, size: 32),
                    label:
                        Text("Resend email\t${cooldown > 0 ? cooldown : ""}"),
                  ),
                  TextButton(
                      onPressed: () => FirebaseAuth.instance.signOut(),
                      child: Text("Cancel"))
                ],
              ),
            ),
          );
  }
}
