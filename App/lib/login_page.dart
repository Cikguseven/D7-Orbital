import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'reset_password_page.dart';
import 'utils.dart';

class LoginWidget extends StatefulWidget {
  final VoidCallback onClickSignUp;

  const LoginWidget({Key? key, required this.onClickSignUp}) : super(key: key);

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
            children: [
              const SizedBox(height: 60),
              Utils.appLogo(context),
              const SizedBox(height: 50),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                      child: const Icon(
                        Icons.remove_red_eye,
                      ),
                      onTap: () => setState(() => obscureFlag = !obscureFlag),
                    ),
                    labelText: 'Password',
                  ),
                  obscureText: obscureFlag, // Obscure password field
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 10, 0, 0),
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  child: const Text(
                    'Forgot Password',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blueAccent,
                    ),
                  ),
                  onTap: () {
                    navigatorKey.currentState!.push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const ResetPasswordPage();
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(Size.fromWidth(
                      MediaQuery.of(context).size.width - 16 * 2)),
                ),
                onPressed: signInCallBack,
                child: const Text(
                  'Log in',
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('---------- or ----------',
                    style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(Size.fromWidth(
                      MediaQuery.of(context).size.width - 16 * 2)),
                ),
                onPressed: widget.onClickSignUp,
                child: const Text(
                  'Sign up here',
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
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
    } on FirebaseAuthException {
      Utils.showSnackBar('Enter a valid account');
    } finally {
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }
  }
}