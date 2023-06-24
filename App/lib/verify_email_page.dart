import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_first_flutter/utils.dart';
import 'package:my_first_flutter/app.dart';

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
        ? const App()
        : Scaffold(
            body: Column(
              children: [
                Utils.createVerticalSpace(18),
                Image.asset("assets/MakeItCountLogo.png"),
                Utils.createHeadlineMedium("Verify Email", context),
                Utils.createVerticalSpace(80),
                Utils.createTitleMedium(
                    "A verification email has been sent to: \n ${FirebaseAuth.instance.currentUser!.email}",
                    context),
                // Column(
                //   children: [
                //     Text(
                //       "A verification email has been sent to:",
                //       style: Theme
                //           .of(context)
                //           .textTheme
                //           .headlineSmall
                //           ?.copyWith(fontSize: 16),
                //     ),
                //     Text(
                //       "${FirebaseAuth.instance.currentUser!.email}",
                //       style: Theme
                //           .of(context)
                //           .textTheme2
                //           .headlineSmall
                //           ?.copyWith(fontSize: 16),
                //     ),
                //   ],
                // ),
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
                    label:
                        Text("Resend email\t${cooldown > 0 ? cooldown : ""}"),
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
