import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_first_flutter/setup_page_2.dart';

import 'user_data.dart';
import 'utils.dart';

class SetupPage1 extends StatefulWidget {
  const SetupPage1({Key? key}) : super(key: key);

  @override
  State<SetupPage1> createState() => _SetupPage1();
}

class _SetupPage1 extends State<SetupPage1> {
  double activityMultiplier = ActivityMultiplier.LIGHTLY_ACTIVE;
  double weightGoal = 0.0;
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
        text: '$value/',
        selection: TextSelection.fromPosition(
          TextPosition(offset: value.length + 1),
        ),
      );
      prevLength = value.length + 1;
    }
  }

  String? birthdayValidator(String? birthday) {
    if (!Utils.validDateTime(birthday!)) {
      return 'Please enter a valid date of birth (dd/mm/yyyy)';
    }
    return null;
  }

  // Height validator
  String? heightValidator(String? value) {
    if (value == null) return null;
    int? height = int.tryParse(value);
    return height == null || height < 50 || height > 260
        ? 'Please enter a valid height'
        : null;
  }

  // Weight validator
  String? weightValidator(String? value) {
    if (value == null) return null;
    double? weight = double.tryParse(value);
    return weight == null || weight < 0 || weight > 635
        ? 'Please enter a valid weight'
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
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 60),
                Utils.appLogo(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 40, 0, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Utils.createHeadlineMedium('Hello!', context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Utils.createHeadlineSmall(
                        'Welcome to Make it Count!', context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 26),
                  child: Center(
                    child: Utils.createTitleMedium(
                        'Let us get to know you better', context),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    validator: (val) {
                      return val == '' ? 'Please enter your first name' : null;
                    },
                    controller: firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First name',
                    ),
                    // autovalidateMode: AutovalidateMode.onUserInteraction,
                    // validator: emailValidator,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    validator: (val) {
                      return val == '' ? 'Please enter your last name' : null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last name',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
                  child: Center(
                    child: Utils.createTitleMedium(
                        'Select the gender we should use to \n'
                        'calculate your calorie needs:',
                        context,
                        align: TextAlign.center),
                  ),
                ),
                const SizedBox(height: 18),
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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  // Text color of selected button
                  selectedColor: Colors.white,
                  // Background color of selected button
                  fillColor: const Color(0xFF003D7C),
                  // Splash color when selected
                  splashColor: Theme.of(context).primaryColor,
                  borderColor: Colors.black,
                  constraints: const BoxConstraints(
                    minHeight: 40,
                    minWidth: 120,
                  ),
                  borderRadius: BorderRadius.circular(100),
                  children: const <Text>[
                    Text('Male'),
                    Text('Female'),
                  ],
                ),
                const SizedBox(height: 28),
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
                            firstDate: DateTime(1907),
                            lastDate: today,
                          );

                          // If click on cancel
                          if (newDate == null) {
                            return;
                          } else {
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
                      labelText: 'Date of birth (dd/mm/yyyy)',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                      labelText: 'Height in cm',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    validator: weightValidator,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputFormatters: [LengthLimitingTextInputFormatter(4)],
                    controller: weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight in kg',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 26),
                  child: Center(
                    child: Utils.createTitleMedium(
                        'Select your estimated activity level', context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RadioListTile(
                    title: const Text(
                      'Sedentary',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    subtitle: const Text('Little to no exercise'),
                    value: ActivityMultiplier.SEDENTARY,
                    groupValue: activityMultiplier,
                    onChanged: (value) {
                      setState(() {
                        activityMultiplier = value!;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RadioListTile(
                    title: const Text(
                      'Lightly active',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    subtitle: const Text('1–2 days of exercise in a week'),
                    value: ActivityMultiplier.LIGHTLY_ACTIVE,
                    groupValue: activityMultiplier,
                    onChanged: (value) {
                      setState(() {
                        activityMultiplier = value!;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RadioListTile(
                    title: const Text(
                      'Moderately active',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    subtitle: const Text('3–5 days of exercise in a week'),
                    value: ActivityMultiplier.MODERATELY_ACTIVE,
                    groupValue: activityMultiplier,
                    onChanged: (value) {
                      setState(() {
                        activityMultiplier = value!;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RadioListTile(
                    title: const Text(
                      'Very active',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    subtitle: const Text('6-7 days of exercise in a week'),
                    value: ActivityMultiplier.VERY_ACTIVE,
                    groupValue: activityMultiplier,
                    onChanged: (value) {
                      setState(() {
                        activityMultiplier = value!;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RadioListTile(
                    title: const Text(
                      'Extremely active',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    subtitle: const Text('Exercise twice a day'),
                    value: ActivityMultiplier.EXTREMELY_ACTIVE,
                    groupValue: activityMultiplier,
                    onChanged: (value) {
                      setState(() {
                        activityMultiplier = value!;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 26),
                  child: Center(
                    child: Utils.createTitleMedium(
                        'Set your weight goal', context),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RadioListTile(
                    title: const Text(
                      'Lose 0.5kg a week',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    value: -0.5,
                    groupValue: weightGoal,
                    onChanged: (value) {
                      setState(() {
                        weightGoal = value!;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RadioListTile(
                    title: const Text(
                      'Lose 0.2kg a week',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    value: -0.2,
                    groupValue: weightGoal,
                    onChanged: (value) {
                      setState(() {
                        weightGoal = value!;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RadioListTile(
                    title: const Text(
                      'Maintain my current weight',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    value: 0.0,
                    groupValue: weightGoal,
                    onChanged: (value) {
                      setState(() {
                        weightGoal = value!;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RadioListTile(
                    title: const Text(
                      'Gain 0.2kg a week',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    value: 0.2,
                    groupValue: weightGoal,
                    onChanged: (value) {
                      setState(() {
                        weightGoal = value!;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RadioListTile(
                    title: const Text(
                      'Gain 0.5kg a week',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    value: 0.5,
                    groupValue: weightGoal,
                    onChanged: (value) {
                      setState(() {
                        weightGoal = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: validateForm,
                  icon: const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white),
                  label: const Text('Next'),
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(Size.fromWidth(
                        MediaQuery.of(context).size.width * 0.5)),
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  label: const Text('Log out'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                    fixedSize: MaterialStateProperty.all(Size.fromWidth(
                        MediaQuery.of(context).size.width * 0.5)),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  void validateForm() {
    final bool isValidInputs = formKey.currentState!.validate();
    if (genderSelected.every((element) => element == false)) {
      // all false
      Utils.showSnackBar('Select your gender');
      return;
    }
    if (!isValidInputs) return;

    double height = double.parse(heightController.text.trim());
    double weight = double.parse(weightController.text.trim());
    String birthday = birthdayController.text.trim();

    final user = UserData.setupNewUser(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      gender: genderSelected[0] ? 'Male' : 'Female',
      birthday: birthday,
      height: height,
      weight: weight,
      activityMultiplier: activityMultiplier,
      weightGoal: weightGoal,
    );

    FocusManager.instance.primaryFocus?.unfocus();

    setState(
      () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => SetupPage2(user: user)));
      },
    );
  }
}
