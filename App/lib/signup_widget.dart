import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'utils.dart';

class SignupWidget extends StatefulWidget {
  final VoidCallback onClickLogIn;

  const SignupWidget({Key? key, required this.onClickLogIn}) : super(key: key);

  @override
  State<SignupWidget> createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupWidget> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController =
      TextEditingController(); // TODO: Make 2 password fields and validate that they are equals
  final password2Controller = TextEditingController();

  String? emailValidator(String? email) =>
      email != null && !EmailValidator.validate(email)
          ? 'Enter a valid email'
          : null;

  String? passwordValidator(String? pwd) =>
      pwd != null && pwd.length < 6 ? 'Password needs at least 6 characters' : null;

  String? password2Validator(String? pwd2) =>
      pwd2 != passwordController.text.trim() ? "Password does not match" : null;

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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: emailValidator,
                  ),
                ),
                Utils.createVerticalSpace(16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: passwordValidator,
                    obscureText: obscureFlag, // Obscure password field
                  ),
                ),
                Utils.createVerticalSpace(16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: password2Controller,
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        child: const Icon(
                          Icons.remove_red_eye,
                          size: 24,
                        ),
                        onTap: () => setState(() => obscureFlag = !obscureFlag),
                      ),
                      labelText: "Confirm Password",
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: password2Validator,
                    obscureText: obscureFlag, // Obscure password field
                  ),
                ),
                Utils.createVerticalSpace(26),
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(Size.fromWidth(
                        MediaQuery.of(context).size.width - 16 * 2)),
                  ),
                  onPressed: signUpCallBack,
                  child: const Text(
                    "Sign up",
                  ),
                ),
                Utils.createVerticalSpace(36),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.titleMedium,
                    text: "Have an Account? ",
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = widget.onClickLogIn,
                        text: "Log in",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
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
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      // await FirebaseAuth.instance.createUserWithEmailAndPassword(
      //     email: emailController.text.trim(),
      //     password: passwordController.text.trim());
      await Utils.firebaseCreateUser(
          emailController.text.trim(), passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
    } finally {
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }
  }
}
