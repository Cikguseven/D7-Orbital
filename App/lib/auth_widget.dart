import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_first_flutter/login_widget.dart';
import 'package:my_first_flutter/signup_widget.dart';

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
