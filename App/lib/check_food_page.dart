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
    String title, dynamic value, UserData user, BuildContext context) {
  String unit = "g";
  String percentIntake = '';

  switch (title) {
    case "Energy":
      {
        percentIntake = (value * 100 / user.rmr).toStringAsFixed(1);
        unit = "kcal";
        break;
      }
    case "Protein":
      {
        percentIntake = (value * 100 / user.proteinGoal).toStringAsFixed(1);
        break;
      }
    case "Fats":
      {
        percentIntake = (value * 100 / user.fatsGoal).toStringAsFixed(1);
        break;
      }
    case "Carbs":
      {
        percentIntake = (value * 100 / user.carbsGoal).toStringAsFixed(1);
        break;
      }
    case "Sugar":
      {
        percentIntake = (value * 100 / user.sugarGoal).toStringAsFixed(1);
        break;
      }
  }

  return Container(
    // color: , // TODO: different colours for different levels
    margin: const EdgeInsets.symmetric(horizontal: 2),
    padding: const EdgeInsets.symmetric(vertical: 4),
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.black,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Utils.createTitleSmall(title, context),
        Utils.createVerticalSpace(12),
        Utils.createLabelLarge("${value.round().toString()} $unit", context),
        Utils.createVerticalSpace(10),
        Container(
          height: 1.0,
          width: 62,
          color: Colors.black,
        ),
        Utils.createVerticalSpace(5),
        Utils.createTitleSmall("$percentIntake%", context),
        Utils.createVerticalSpace(5),
        // TODO: Have a global access to user so we can get his information from any page in the app, useful here for calculating % target
      ],
    ),
  );
}

// Widget to create all nutrtional data boxes
Widget allFoodDataWidget(int calories, double protein, double fats,
    double carbs, double sugar, UserData user, BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      foodDataWidget("Energy", calories, user, context),
      foodDataWidget("Protein", protein, user, context),
      foodDataWidget("Fats", fats, user, context),
      foodDataWidget("Carbs", carbs, user, context),
      foodDataWidget("Sugar", sugar, user, context),
    ],
  );
}

class CheckFoodPage extends StatefulWidget {
  final XFile? image;
  FoodData
      fd; // Food data that was taken from firebase, used to fill up the page
  final UserData user;
  final String postID;
  final String imageURL;

  CheckFoodPage(
      {Key? key,
      required this.image,
      required this.fd,
      required this.user,
      required this.postID,
      required this.imageURL})
      : super(key: key);

  @override
  State<CheckFoodPage> createState() => _CheckFoodPageState();
}

class _CheckFoodPageState extends State<CheckFoodPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Snap"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Image
          Container(
            height: 200,
            width: 200,
            decoration: widget.image == null
                ? null
                : BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      image: XFileImage(widget.image!),
                    ),
                  ),
          ),
          Utils.createVerticalSpace(26),

          // Name of Food headline text
          Utils.createHeadlineMedium(widget.fd.name, context),
          Utils.createVerticalSpace(26),

          // Nutritional information regular
          Utils.createHeadlineSmall("Nutritional Information", context),
          Utils.createVerticalSpace(16),

          // Nutrition bar
          allFoodDataWidget(widget.fd.energy, widget.fd.protein, widget.fd.fats,
              widget.fd.carbs, widget.fd.sugar, widget.user, context),

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
                        widget.fd = newFD;
                      }
                    });
                  },
                  child: const Text(
                    "Edit food entry",
                  ),
                ),

                Utils.createVerticalSpace(26),

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
                            fd: widget.fd,
                            postID: widget.postID,
                            imageURL: widget.imageURL),
                      ),
                    );
                  },
                  child: const Text(
                    "Confirm",
                  ),
                ),
                Utils.createVerticalSpace(42),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
