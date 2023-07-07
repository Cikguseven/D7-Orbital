import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'utils.dart';

class UpdateWeightPage extends StatefulWidget {
  const UpdateWeightPage({Key? key}) : super(key: key);

  @override
  State<UpdateWeightPage> createState() => _UpdateWeightPageState();
}

class _UpdateWeightPageState extends State<UpdateWeightPage> {
  final weightController = TextEditingController();

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
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update weight'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              validator: weightValidator,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: [LengthLimitingTextInputFormatter(4)],
              controller: weightController,
              decoration: const InputDecoration(
                labelText: 'Enter your new weight in kg',
              ),
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
    double weight = double.parse(weightController.text.trim());
    try {
      await FirebaseFirestore.instance
          .collection('userData')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'weight': weight});
    } on FirebaseAuthException {
      Utils.showSnackBar('Unable to update weight');
    } finally {
      weightController.clear();
      Utils.showSnackBar('Weight successfully updated', isBad: false);
      Navigator.pop(context);
    }
  }
}
