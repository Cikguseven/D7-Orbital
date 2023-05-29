import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:my_first_flutter/main.dart';
import 'package:my_first_flutter/user_class.dart';
import 'package:my_first_flutter/utils.dart';
import 'package:my_first_flutter/app.dart';

class NewUserSetupPage extends StatefulWidget {
  const NewUserSetupPage({Key? key}) : super(key: key);

  @override
  State<NewUserSetupPage> createState() => _NewUserSetupPage();
}

class _NewUserSetupPage extends State<NewUserSetupPage> {
  bool done = false;
  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final genderController = TextEditingController();
  final birthdayController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  // Gender Dropdown button
  final genders = ["Male", "Female", "Prefer not to say"];
  String? selectedGender = null;

  // DateTime picker
  DateTime today = DateTime.now();



  // String? emailValidator(String? email) =>
  //     email != null && !EmailValidator.validate(email)
  //         ? 'Enter a valid email'
  //         : null;
  //
  // String? passwordValidator(String? pwd) =>
  //     pwd != null && pwd.length < 6
  //         ? 'Password needs > 6 characters'
  //         : null;
  // bool obscureFlag = true;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    genderController.dispose();
    birthdayController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("done is true? $done");
    return done
        ? App()
        : // TODO: fix this, abit of circular App call this, this call App but i think is a quick fix for now
        CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Form(
                  // key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          "This page will be broken down into sequential pages for filling in different information."),
                      TextFormField(
                        controller: firstNameController,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color),
                          border: OutlineInputBorder(),
                          labelText: "First Name",
                        ),
                        // autovalidateMode: AutovalidateMode.onUserInteraction,
                        // validator: emailValidator,
                      ),
                      TextFormField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color),
                          border: OutlineInputBorder(),
                          labelText: "Last Name",
                        ),
                      ),
                      TextFormField( // TODO: Make Gender a dropdownmenu
                        controller: genderController,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                              color:
                              Theme.of(context).textTheme.bodySmall?.color),
                          border: OutlineInputBorder(),
                          labelText: "Gender",
                        ),
                      ),

                      TextFormField(
                        controller: birthdayController,
                        decoration: InputDecoration(
                          suffixIcon: GestureDetector(
                            child: Icon(
                              Icons.date_range,
                              size: 24,
                            ),
                            onTap: () async {
                              DateTime? newDate = await showDatePicker(
                                context: context,
                                initialDate: today,
                                firstDate: DateTime(1970),
                                lastDate: today,
                              );

                              // If click on cancel
                              if (newDate == null)
                                return;
                              else {
                                final newDateStr = Utils.dateTimeToString(newDate);
                                birthdayController.value = TextEditingValue(
                                  text: newDateStr,
                                  selection: TextSelection.fromPosition(
                                    TextPosition(offset: newDateStr.length),
                                  ),
                                );
                              }
                            },
                          ),
                          labelStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color),
                          border: OutlineInputBorder(),
                          labelText: "dd/mm/yyyy",
                        ),
                      ),
                      TextFormField(
                        controller: heightController,
                        // TODO: Limit height to 3 digits, add checks
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color),
                          border: OutlineInputBorder(),
                          labelText: "Height in CM",
                        ),
                      ),
                      TextFormField(
                        controller: weightController,
                        // TODO: Round weight to 2 dp, add checks
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color),
                          border: OutlineInputBorder(),
                          labelText: "Weight in KG",
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: newUserSetupCallback,
                        icon: Icon(Icons.person_4_rounded, size: 24),
                        label: const Text(
                          "This is Me",
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color),
                          text: 'Cancel',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => FirebaseAuth.instance.signOut(),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
  }

  Future newUserSetupCallback() async {
    // final bool isValidInputs = formKey.currentState!.validate();
    // if (!isValidInputs) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    try {
      final user = UserData(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        gender: genderController.text.trim(),
        birthday: birthdayController.text.trim(),
        height: double.parse(heightController.text.trim()),
        weight: double.parse(weightController.text.trim()),
      );
      final docUser = FirebaseFirestore.instance
          .collection('userData')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      await docUser.set(user.toJson());
      setState(() {
        done = true;
        print("Done is now true");
      });
    } on FirebaseAuthException catch (e) {
      print(e);
      Utils.showSnackBar(e.message);
    } finally {
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }
  }
}
