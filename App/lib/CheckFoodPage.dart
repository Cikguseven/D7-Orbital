import 'package:cross_file_image/cross_file_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter/ManualFoodSelectPage.dart';
import 'package:my_first_flutter/ShareFoodPage.dart';
import 'FoodDataClass.dart';
import 'package:my_first_flutter/utils.dart';

Widget foodDataWidget(
    String title, String field1, String field2, BuildContext context) {
  return Container(
    // color: , // TODO: different colours for different levels
    margin: EdgeInsets.symmetric(horizontal: 2),
    padding: EdgeInsets.symmetric(vertical: 4),
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
        Utils.createTitleSmall(field1, context),
        Utils.createVerticalSpace(4),
        Utils.createTitleSmall(field2, context),
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

class CheckFoodPage extends StatefulWidget {
  XFile? image;
  FoodData
      fd; // Food data that was taken from firebase, used to fill up the page
  CheckFoodPage({Key? key, required this.image, required this.fd})
      : super(key: key);

  @override
  State<CheckFoodPage> createState() => _CheckFoodPageState();
}

class _CheckFoodPageState extends State<CheckFoodPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Snap"),
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
          Utils.createHeadlineMedium("${widget.fd.name}", context),
          Utils.createVerticalSpace(26),

          // Nutritional information regular
          Utils.createHeadlineSmall("Nutritional Information", context),
          Utils.createVerticalSpace(16),

          // Nutrition bar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Energy
              foodDataWidget("Energy", "${widget.fd.energyKJ}",
                  "${widget.fd.energy}", context),

              // Protein
              foodDataWidget(
                  "Protein", "${widget.fd.protein}", "H/M/L", context),

              // Fat
              foodDataWidget("Fat", "${widget.fd.fat}", "H/M/L", context),

              // Carbs
              foodDataWidget("Carbs", "${widget.fd.carb}", "H/M/L", context),

              // Sugar
              foodDataWidget("Sugar", "${widget.fd.sugar}", "H/M/L", context),
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
                              ManualFoodSelectPage()),
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
                        builder: (BuildContext context) => ShareFoodPage(image: widget.image),
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
