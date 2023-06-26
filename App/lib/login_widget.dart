import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'forgot_password_page.dart';
import 'main.dart';
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
              Utils.createVerticalSpace(60),
              Image.asset("assets/logo-black-text.png", width: 0.9 * MediaQuery.of(context).size.width,),
              Utils.createVerticalSpace(50),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                  ),
                ),
              ),
              Utils.createVerticalSpace(16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                      child: const Icon(
                        Icons.remove_red_eye,
                        size: 24,
                      ),
                      onTap: () => setState(() => obscureFlag = !obscureFlag),
                    ),
                    labelText: "Password",
                  ),
                  obscureText: obscureFlag, // Obscure password field
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 6, 0, 0),
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  child: const Text(
                    "Forgot Password",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blueAccent,
                    ),
                  ),
                  onTap: () {
                    navigatorKey.currentState!.push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const ForgotPasswordPage();
                        },
                      ),
                    );
                  },
                ),
              ),
              Utils.createVerticalSpace(20),
              ElevatedButton(
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(Size.fromWidth(
                      MediaQuery.of(context).size.width - 16 * 2)),
                ),
                onPressed: signInCallBack,
                child: const Text(
                  "Log in",
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text("---------- or ----------",
                    style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(Size.fromWidth(
                      MediaQuery.of(context).size.width - 16 * 2)),
                ),
                onPressed: widget.onClickSignUp,
                child: const Text(
                  "Sign up",
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
      // await Utils.firebaseSignIn(
      //     emailController.text.trim(), passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
    } finally {
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }
  }
}
