import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'utils.dart';

class UpdateWeightGoalPage extends StatefulWidget {
  const UpdateWeightGoalPage({Key? key}) : super(key: key);

  @override
  State<UpdateWeightGoalPage> createState() => _UpdateWeightGoalPageState();
}

class _UpdateWeightGoalPageState extends State<UpdateWeightGoalPage> {
  double weightGoal = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update weight goal'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RadioListTile(
              title: const Text('Lose 0.5kg a week'),
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
              title: const Text('Lose 0.2kg a week'),
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
              title: const Text('Maintain my current weight'),
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
              title: const Text('Gain 0.2kg a week'),
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
              title: const Text('Gain 0.5kg a week'),
              value: 0.5,
              groupValue: weightGoal,
              onChanged: (value) {
                setState(() {
                  weightGoal = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: updateWeightCallback,
            child: const Text(
              'Update',
            ),
          ),
        ],
      ),
    );
  }

  Future updateWeightCallback() async {
    try {
      await FirebaseFirestore.instance
          .collection('userData')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'weightGoal': weightGoal});
    } on FirebaseAuthException {
      Utils.showSnackBar('Unable to save weight goal');
    } finally {
      Utils.showSnackBar('Weight goal successfully updated', isBad: false);
      Navigator.pop(context);
    }
  }
}
