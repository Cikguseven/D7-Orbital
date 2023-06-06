import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_first_flutter/forgot_password_page.dart';
import 'package:my_first_flutter/main.dart';
import 'package:my_first_flutter/utils.dart';



class LoginWidget extends StatefulWidget {
  final VoidCallback onClickSignUp;

  const LoginWidget({Key? key,
    required this.onClickSignUp}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();


}

class _LoginWidgetState extends State<LoginWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                // style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                controller: emailController,
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                  border: OutlineInputBorder(),
                  labelText: "Email",
                ),
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                  suffixIcon: GestureDetector(
                    child: Icon(
                      Icons.remove_red_eye,
                      size: 24,
                    ),
                    onTap: () => setState(() => obscureFlag = !obscureFlag),
                    // onTapDown: (_) => setState(() => obscureFlag = false),
                    // onTapUp: (_) => setState(() => obscureFlag = true),
                  ),
                  border: OutlineInputBorder(),
                  labelText: "Password",
                ),
                obscureText: obscureFlag, // Obscure password field
              ),
              ElevatedButton.icon(
                  onPressed: signInCallBack,
                  icon: Icon(Icons.lock_open_outlined, size: 24),
                  label: const Text(
                    "Log in",
                  )
              ),
              GestureDetector(
                child: Text("Forgot Password?",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Theme.of(context).colorScheme.secondary,
                )),
                onTap: () {
                  navigatorKey.currentState!.push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return ForgotPasswordPage();
                      },
                    ),
                  );
                },
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                  text: "Don't have an Account?",
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickSignUp,
                      text: "Sign Up",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme
                            .of(context)
                            .colorScheme
                            .secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Future signInCallBack() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    try {
      print("Email: ${emailController.text.trim()}");
      print("Password: ${passwordController.text.trim()}");
      await FirebaseAuth.instance.signInWithEmailAndPassword(
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
