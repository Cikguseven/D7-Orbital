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
  bool canSendEmail = false;

  Future sendEmailVerification() async {
    if (!canSendEmail) {
      Utils.showSnackBar(
          'Cannot resend for another ${cooldown > 1 ? '$cooldown seconds' : '1 second'}');
      return;
    }
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      canSendEmail = false;
      setState(() => cooldown = 15);
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
      Utils.showSnackBar('Unable to send verification email');
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
                const SizedBox(height: 60),
                Utils.appLogo(context),
                const SizedBox(height: 50),
                Utils.createHeadlineMedium('Verify Email', context),
                const SizedBox(height: 70),
                Utils.createTitleMedium(
                    'A verification email has been sent to: \n ${FirebaseAuth.instance.currentUser!.email}',
                    context),
                const SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: sendEmailVerification,
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(
                        Size.fromWidth(
                            MediaQuery.of(context).size.width - 16 * 2),
                      ),
                      backgroundColor: MaterialStateProperty.all(
                          canSendEmail ? const Color(0xFF003D7C) : const Color(0xFF565656)),
                    ),
                    icon: const Icon(Icons.email_outlined, color: Colors.white),
                    label: cooldown > 0
                        ? Text(
                            'Resend email in ${cooldown > 1 ? '$cooldown seconds' : '1 second'}')
                        : const Text('Resend email'),
                  ),
                ),
                const SizedBox(height: 26),
                ElevatedButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(Size.fromWidth(
                        MediaQuery.of(context).size.width - 16 * 2)),
                  ),
                  child: const Text('Return to log in'),
                ),
              ],
            ),
          );
  }
}
