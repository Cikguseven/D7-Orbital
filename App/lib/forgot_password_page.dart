import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'utils.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  String? emailValidator(String? email) =>
      email != null && !EmailValidator.validate(email)
          ? 'Enter a valid email'
          : null;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Utils.createVerticalSpace(60),
              Image.asset("assets/logo-black-text.png", width: 0.9 * MediaQuery.of(context).size.width,),
              Utils.createVerticalSpace(50),
              Utils.createHeadlineMedium("Reset Password", context),
              Utils.createVerticalSpace(25),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                  ),
                  validator: emailValidator,
                ),
              ),
              Utils.createVerticalSpace(35),
              ElevatedButton.icon(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(Size.fromWidth(
                        MediaQuery.of(context).size.width - 15 * 2)),
                  ),
                  onPressed: sendResetEmailCallback,
                  icon: const Icon(Icons.email_outlined, size: 24),
                  label: const Text(
                    "Send email",
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future sendResetEmailCallback() async {
    final bool isValidInputs = formKey.currentState!.validate();
    if (!isValidInputs) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      Utils.showSnackBar("Password reset email sent!");
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    } on FirebaseAuthException {
      Utils.showSnackBar("Unable to reset password");
      navigatorKey.currentState!.pop();
    }
  }
}
