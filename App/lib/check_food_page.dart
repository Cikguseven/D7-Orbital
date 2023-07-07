import 'package:camera/camera.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:flutter/material.dart';

import 'food_data.dart';
import 'manual_food_select_page.dart';
import 'share_food_page.dart';
import 'user_data.dart';
import 'utils.dart';

// Widget for creating box displaying nutritional information
Widget foodDataWidget(
    String title, dynamic value, dynamic goal, BuildContext context) {
  String unit = 'g';
  String percentIntake = '';

  switch (title) {
    case 'Energy':
      {
        percentIntake = (value * 100 / goal).toStringAsFixed(1);
        unit = 'kcal';
        break;
      }
    case 'Protein':
      {
        percentIntake = (value * 100 / goal).toStringAsFixed(1);
        break;
      }
    case 'Fats':
      {
        percentIntake = (value * 100 / goal).toStringAsFixed(1);
        break;
      }
    case 'Carbs':
      {
        percentIntake = (value * 100 / goal).toStringAsFixed(1);
        break;
      }
    case 'Sugar':
      {
        percentIntake = (value * 100 / goal).toStringAsFixed(1);
        break;
      }
  }

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 2),
    padding: const EdgeInsets.symmetric(vertical: 4),
    decoration: BoxDecoration(
      border: Border.all(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Utils.createTitleSmall(title, context),
        const SizedBox(height: 12),
        Utils.createLabelLarge('${value.round().toString()} $unit', context),
        const SizedBox(height: 10),
        Container(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          height: 1.0,
          width: 62,
        ),
        const SizedBox(height: 5),
        Utils.createTitleSmall('$percentIntake%', context),
        const SizedBox(height: 5),
      ],
    ),
  );
}

// Widget to create all nutritional data boxes
Widget allFoodDataWidget(int calories, double protein, double fats,
    double carbs, double sugar, UserData user, BuildContext context) {
  List<int> userNutritionGoals = UserData.nutritionCalculator(user);
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      foodDataWidget('Energy', calories, userNutritionGoals[0], context),
      foodDataWidget('Protein', protein, userNutritionGoals[1], context),
      foodDataWidget('Fats', fats, userNutritionGoals[2], context),
      foodDataWidget('Carbs', carbs, userNutritionGoals[3], context),
      foodDataWidget('Sugar', sugar, userNutritionGoals[4], context),
    ],
  );
}

class CheckFoodPage extends StatefulWidget {
  final dynamic image;
  FoodData foodData;
  final UserData user;

  CheckFoodPage(
      {Key? key,
      required this.image,
      required this.foodData,
      required this.user})
      : super(key: key);

  @override
  State<CheckFoodPage> createState() => _CheckFoodPageState();
}

class _CheckFoodPageState extends State<CheckFoodPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snap'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Image
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fitWidth,
                image: widget.image is XFile
                    ? XFileImage(widget.image)
                    : AssetImage(widget.image) as ImageProvider,
              ),
            ),
          ),
          const SizedBox(height: 26),

          // Name of Food headline text
          Utils.createHeadlineMedium(widget.foodData.name, context),
          const SizedBox(height: 26),

          // Nutritional information regular
          Utils.createHeadlineSmall('Nutritional Information', context),
          const SizedBox(height: 16),

          // Nutrition bar
          allFoodDataWidget(
              widget.foodData.energy,
              widget.foodData.protein,
              widget.foodData.fats,
              widget.foodData.carbs,
              widget.foodData.sugar,
              widget.user,
              context),

          // Elevated button (Edit food item)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(Size.fromWidth(
                        MediaQuery.of(context).size.width - 16 * 2)),
                  ),
                  onPressed: () async {
                    FoodData? newFD = await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const ManualFoodSelectPage()),
                    );
                    setState(() {
                      if (newFD != null) {
                        widget.foodData = newFD;
                      }
                    });
                  },
                  child: const Text(
                    'Edit food entry',
                  ),
                ),

                const SizedBox(height: 26),

                // Elevated button (Confirm)
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(Size.fromWidth(
                        MediaQuery.of(context).size.width - 16 * 2)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => ShareFoodPage(
                            image: widget.image,
                            user: widget.user,
                            foodData: widget.foodData),
                      ),
                    );
                  },
                  child: const Text(
                    'Confirm',
                  ),
                ),
                const SizedBox(height: 42),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
