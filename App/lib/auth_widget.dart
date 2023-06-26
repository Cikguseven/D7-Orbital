import 'package:flutter/material.dart';
import 'login_widget.dart';
import 'signup_widget.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return isLogin
        ? LoginWidget(onClickSignUp: toggleLogInSignUp)
        : SignupWidget(onClickLogIn: toggleLogInSignUp);
  }

  void toggleLogInSignUp() {
    setState(() {
      isLogin = !isLogin;
    });
  }
}
