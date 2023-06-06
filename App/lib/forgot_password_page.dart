import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_first_flutter/main.dart';
import 'package:my_first_flutter/utils.dart';



class ForgotPasswordPage extends StatefulWidget {

  const ForgotPasswordPage({Key? key,}) : super(key: key);

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
      appBar: AppBar(
        title: const Text("Reset Password"),
      ),
      body: SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
              border: OutlineInputBorder(),
              labelText: "Email",
            ),
            validator: emailValidator,
          ),
          ElevatedButton.icon(
              onPressed: sendResetEmailCallback,
              icon: Icon(Icons.email_outlined, size: 24),
              label: const Text(
                "Reset Password",
              )
          ),
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
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    try {
      print("Email: ${emailController.text.trim()}");
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text.trim()
      );
      Utils.showSnackBar("Password reset email sent!");
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      print(e);

      Utils.showSnackBar(e.message);
      navigatorKey.currentState!.pop();
    }
  }
}
