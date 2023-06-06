import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:my_first_flutter/main.dart';
import 'package:my_first_flutter/utils.dart';

class SignupWidget extends StatefulWidget {
  final VoidCallback onClickLogIn;

  const SignupWidget({Key? key, required this.onClickLogIn}) : super(key: key);

  @override
  State<SignupWidget> createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupWidget> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController(); // TODO: Make 2 password fields and validate that they are equals

  String? emailValidator(String? email) =>
      email != null && !EmailValidator.validate(email)
          ? 'Enter a valid email'
          : null;

  String? passwordValidator(String? pwd) =>
      pwd != null && pwd.length < 6
          ? 'Password needs > 6 characters'
          : null;
  bool obscureFlag = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
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
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: emailValidator,
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                      child: Icon(
                        Icons.remove_red_eye,
                        size: 24,
                      ),
                      onTap: () => setState(() => obscureFlag = !obscureFlag),
                      // onTapDown: (_) => setState(() => obscureFlag = false),
                      // onTapUp: (_) => setState(() => obscureFlag = true),
                    ),
                    labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                    border: OutlineInputBorder(),
                    labelText: "Password",
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: passwordValidator,
                  obscureText: obscureFlag, // Obscure password field
                ),
                ElevatedButton.icon(
                  onPressed: signUpCallBack,
                  icon: Icon(Icons.accessibility_new_rounded, size: 24),
                  label: const Text(
                    "Sign Up",
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color),
                    text: 'Have an Account?',
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = widget.onClickLogIn,
                        text: "Log in",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Future signUpCallBack() async {
    final bool isValidInputs = formKey.currentState!.validate();
    if (!isValidInputs) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    try {
      print("Email: ${emailController.text.trim()}");
      print("Password: ${passwordController.text.trim()}");
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      print(e);
      Utils.showSnackBar(e.message);
    } finally {
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }
  }
}
