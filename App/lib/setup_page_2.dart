import 'package:flutter/material.dart';
import 'package:my_first_flutter/setup_page_3.dart';
import 'user_data.dart';

class SetupPage2 extends StatefulWidget {
  final UserData user;

  const SetupPage2({Key? key, required this.user}) : super(key: key);

  @override
  State<SetupPage2> createState() => _SetupPage2();
}

class _SetupPage2 extends State<SetupPage2> {
  @override
  Widget build(BuildContext context) {
    List<int> nutritionInfo = UserData.nutritionCalculator(widget.user);
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Based on your profile, here are your recommended daily nutritional requirements:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 40),
          Text('Calories: ${nutritionInfo[0]} kcal'),
          const SizedBox(height: 10),
          Text('Protein: ${nutritionInfo[1]} g'),
          const SizedBox(height: 10),
          Text('Fats: ${nutritionInfo[2]} g'),
          const SizedBox(height: 10),
          Text('Carbohydrates: ${nutritionInfo[3]} g'),
          const SizedBox(height: 10),
          Text('Sugar: ${nutritionInfo[4]} g'),
          const SizedBox(height: 50),
          ElevatedButton.icon(
            onPressed: openSetupPage3,
            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            label: const Text('Next'),
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(Size.fromWidth(
                  MediaQuery.of(context).size.width * 0.5)),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            label: const Text('Back'),
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(Size.fromWidth(
                  MediaQuery.of(context).size.width * 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  void openSetupPage3() {
    setState(
      () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    SetupPage3(user: widget.user)));
      },
    );
  }
}
