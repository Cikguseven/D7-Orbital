import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'utils.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({Key? key}) : super(key: key);

  @override
  VerifyEmailPageState createState() => VerifyEmailPageState();
}

class VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    // Won't be null cause called after valid login, which requires a created user
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
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
    await FirebaseAuth.instance.currentUser!
        .reload(); // reload to reflect changes in verification status
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  int cooldown = 0;
  bool canSendEmail = true;

  Future sendEmailVerification() async {
    if (!canSendEmail) {
      Utils.showSnackBar("Can't resend for another ${cooldown > 1 ? "${cooldown} seconds" : "1 second"}");
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
    } on FirebaseAuthException {
      Utils.showSnackBar("Unable to send verification email");
      canSendEmail = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerified
        ? const App()
        : Scaffold(
            body: Column(
              children: [
                Utils.createVerticalSpace(60),
                Image.asset("assets/logo-black-text.png", width: 0.9 * MediaQuery.of(context).size.width,),
                Utils.createVerticalSpace(60),
                Utils.createHeadlineMedium("Verify Email", context),
                Utils.createVerticalSpace(70),
                Utils.createTitleMedium(
                    "A verification email has been sent to: \n ${FirebaseAuth.instance.currentUser!.email}",
                    context),
                Utils.createVerticalSpace(80),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(
                        Size.fromWidth(
                            MediaQuery.of(context).size.width - 16 * 2),
                      ),
                    ),
                    onPressed: sendEmailVerification,
                    icon: const Icon(Icons.email_outlined, size: 24),
                    label: cooldown > 0 ? Text("Resend email in ${cooldown > 1 ? "${cooldown} seconds" : "1 second"}") : Text("Resend email"),
                  ),
                ),
                Utils.createVerticalSpace(26),
                TextButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: Text(
                    "Return to log in",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          );
  }
}
