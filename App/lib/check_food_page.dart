import 'package:cross_file_image/cross_file_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter/manual_food_select_page.dart';
import 'package:my_first_flutter/share_food_page.dart';
import 'package:my_first_flutter/user_data.dart';
import 'package:my_first_flutter/food_data.dart';
import 'package:my_first_flutter/utils.dart';

Widget foodDataWidget(
    String title, double field1, String field2, bool isEnergy, BuildContext context) {
  String unit1 = "kJ";
  String unit2 = "kcal";
  if (!isEnergy) {
    unit1 = "g";
    unit2 = "";
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
        Utils.createLabelLarge("${field1.round().toString()} $unit1", context),
        Utils.createVerticalSpace(4),
        Utils.createLabelLarge("$field2 $unit2", context),
        Utils.createVerticalSpace(12),
        Container(
          height: 1.0,
          width: 62,
          color: Colors.black,
        ),
        Utils.createVerticalSpace(4),
        Utils.createTitleSmall("temp%", context),
        // TODO: Have a global access to user so we can get his information from any page in the app, useful here for calculating % target
      ],
    ),
  );
}

Widget allFoodDataWidget(
  int calories, double protein, double fats, double carbs, double sugar, BuildContext context
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      foodDataWidget("Energy", calories * 4.184,
          calories.toString(), true, context),
      foodDataWidget(
          "Protein", protein, "H/M/L", false, context),
      foodDataWidget(
          "Fat", fats, "H/M/L", false, context),
      foodDataWidget(
          "Carbs", carbs, "H/M/L", false, context),
      foodDataWidget(
          "Sugar", sugar, "H/M/L", false, context),
    ],
  );
}

class CheckFoodPage extends StatefulWidget {
  XFile? image;
  FoodData
      fd; // Food data that was taken from firebase, used to fill up the page
  final UserData user;
  CheckFoodPage({Key? key, required this.image, required this.fd, required this.user})
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Energy
              foodDataWidget("Energy", widget.fd.energyKJ,
                  "${widget.fd.energy}", true, context),

              // Protein
              foodDataWidget(
                  "Protein", widget.fd.protein, "H/M/L", false, context),

              // Fat
              foodDataWidget("Fat", widget.fd.fats, "H/M/L", false, context),

              // Carbs
              foodDataWidget("Carbs", widget.fd.carbs, "H/M/L", false, context),

              // Sugar
              foodDataWidget("Sugar", widget.fd.sugar, "H/M/L", false, context),
            ],
          ),
          Utils.createVerticalSpace(52),

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
                        builder: (BuildContext context) => ShareFoodPage(image: widget.image, user: widget.user, fd: widget.fd),
                      ),
                    );
                  },
                  child: const Text(
                    "Confirm",
                  ),
                ),
                Utils.createVerticalSpace(52),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
