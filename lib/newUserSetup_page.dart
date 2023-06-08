import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
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
  bool? isMale = null;

  // DateTime picker
  DateTime today = DateTime.now();
  int prevLength = 0; // used to determine if increasing or decreasing
  dateTimeAutoSlash(value) {
    if (value.length < prevLength) {
      prevLength = value.length;
    } else if (value.length == 2 || value.length == 5) {
      birthdayController.value = TextEditingValue(
        text: "$value/",
        selection: TextSelection.fromPosition(
          TextPosition(offset: value.length + 1),
        ),
      );
      prevLength = value.length + 1;
    }
  }

  String? birthdayValidator(String? birthday) {
    if (!Utils.validDateTime(birthday!)) {
      return "Please enter a valid birthday (dd/mm/yyyy)";
    }
    return null;
  }

  // Height validator
  String? heightValidator(String? value) {
    if (value == null) return null;
    int? height = int.tryParse(value);
    return height == null || height < 0 || height > 250 // assume no one > 250cm
        ? "Please enter a valid height"
        : null;
  }

  // Weight validator
  String? weightValidator(String? value) {
    if (value == null) return null;
    double? weight = double.tryParse(value);
    return weight == null || weight < 0 || weight > 250 // assume no one > 250kg
        ? "Please enter a valid weight"
        : null;
  }

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
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                          "This page will be broken down into sequential "
                          "pages for filling in different information."),
                      TextFormField(
                        validator: (val) {
                          return val == ""
                              ? "Please enter your first name"
                              : null;
                        },
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
                        validator: (val) {
                          return val == ""
                              ? "Please enter your last name"
                              : null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: lastNameController,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color),
                          border: OutlineInputBorder(),
                          labelText: "Last Name",
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isMale = true;
                                  });
                                },
                                child: Text("Male"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: (isMale == null || !isMale!)
                                      ? Colors.white
                                      : Colors.orange,
                                )),
                          ),
                          Expanded(
                            child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isMale = false;
                                  });
                                },
                                child: Text("Female"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: (isMale == null || isMale!)
                                      ? Colors.white
                                      : Colors.orange,
                                )),
                          ),
                        ],
                      ),
                      TextFormField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          //  dd/mm/yyyy is 10 letters
                        ],
                        onChanged: dateTimeAutoSlash,
                        validator: birthdayValidator,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: birthdayController,
                        decoration: InputDecoration(
                          suffixIcon: GestureDetector(
                            child: const Icon(
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
                                final newDateStr =
                                    Utils.dateTimeToString(newDate);
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
                        validator: heightValidator,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(3),
                        ],
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
                        validator: weightValidator,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        inputFormatters: [LengthLimitingTextInputFormatter(4)],
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
    final bool isValidInputs = formKey.currentState!.validate();
    isMale ?? Utils.showSnackBar("Select your gender!");
    if (!isValidInputs) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    try {
      final user = UserData(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        gender: isMale! ? "Male" : "Female",
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
