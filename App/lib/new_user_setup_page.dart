import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Gender Toggle button
  final List<bool> genderSelected = [false, false]; // Male, Female

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
    return done
        ? const App()
        : // TODO: fix this, abit of circular App call this, this call App but i think is a quick fix for now
        CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 26, 0, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Utils.createHeadlineMedium("Hello!", context),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Utils.createHeadlineSmall(
                              "Welcome to Make it Count!", context),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 26, 0, 0),
                        child: Center(
                          child: Utils.createTitleMedium(
                              "Let us get to know you better", context),
                        ),
                      ),
                      Utils.createVerticalSpace(16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextFormField(
                          validator: (val) {
                            return val == ""
                                ? "Please enter your first name"
                                : null;
                          },
                          controller: firstNameController,
                          decoration: const InputDecoration(
                            labelText: "First Name",
                          ),
                          // autovalidateMode: AutovalidateMode.onUserInteraction,
                          // validator: emailValidator,
                        ),
                      ),
                      Utils.createVerticalSpace(16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextFormField(
                          validator: (val) {
                            return val == ""
                                ? "Please enter your last name"
                                : null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: lastNameController,
                          decoration: const InputDecoration(
                            labelText: "Last Name",
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 26, 0, 0),
                        child: Center(
                          child: Utils.createTitleMedium(
                              "Select the gender we should use to \n"
                              "calculate your calorie needs:",
                              context,
                              align: TextAlign.center),
                        ),
                      ),
                      Utils.createVerticalSpace(16),
                      ToggleButtons(
                        isSelected: genderSelected,
                        onPressed: (int index) {
                          setState(
                            () {
                              for (int buttonIndex = 0;
                                  buttonIndex < genderSelected.length;
                                  buttonIndex++) {
                                if (buttonIndex == index) {
                                  genderSelected[buttonIndex] = true;
                                } else {
                                  genderSelected[buttonIndex] = false;
                                }
                              }
                            },
                          );
                        },
                        textStyle: Theme.of(context).textTheme.titleMedium,
                        // Text color of non-selected button
                        color: Theme.of(context).primaryColor,
                        // Text color of selected button
                        selectedColor: Colors.white,
                        // Background color of selected button
                        fillColor: Theme.of(context).primaryColor,
                        // Splash color when seledted
                        splashColor: Theme.of(context).primaryColor,
                        borderColor: Colors.black,
                        constraints: const BoxConstraints(
                          minHeight: 40,
                          minWidth: 120,
                        ),
                        borderRadius: BorderRadius.circular(100),
                        children: const <Text>[
                          Text("Male"),
                          Text("Female"),
                        ],
                      ),
                      Utils.createVerticalSpace(16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextFormField(
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
                                if (newDate == null) {
                                  return;
                                } else {
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
                            labelText: "dd/mm/yyyy",
                          ),
                        ),
                      ),
                      Utils.createVerticalSpace(16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextFormField(
                          validator: heightValidator,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(3),
                          ],
                          controller: heightController,
                          decoration: const InputDecoration(
                            labelText: "Height in CM",
                          ),
                        ),
                      ),
                      Utils.createVerticalSpace(16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextFormField(
                          validator: weightValidator,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(4)
                          ],
                          controller: weightController,
                          decoration: const InputDecoration(
                            labelText: "Weight in KG",
                          ),
                        ),
                      ),
                      Utils.createVerticalSpace(16),
                      ElevatedButton.icon(
                        onPressed: newUserSetupCallback,
                        icon: const Icon(Icons.person_4_rounded, size: 24),
                        label: const Text(
                          "This is Me",
                        ),
                      ),
                      Utils.createVerticalSpace(6),
                      GestureDetector(
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blueAccent,
                          ),
                        ),
                        onTap: () => FirebaseAuth.instance.signOut(),
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
    if (genderSelected.every((element) => element == false)) {
      // all false
      Utils.showSnackBar("Select your gender!");
      return;
    }
    if (!isValidInputs) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final user = UserData(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        gender: genderSelected[0] ? "Male" : "Female",
        birthday: birthdayController.text.trim(),
        height: double.parse(heightController.text.trim()),
        weight: double.parse(weightController.text.trim()),
      );
      final docUser = FirebaseFirestore.instance
          .collection('userData')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      await docUser.set(user.toJson());
      setState(
        () {
          done = true;
        },
      );
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
    } finally {
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }
  }
}
