import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter/food_data.dart';
import 'package:my_first_flutter/utils.dart';

class ManualFoodSelectPage extends StatefulWidget {
  const ManualFoodSelectPage({Key? key}) : super(key: key);

  @override
  State<ManualFoodSelectPage> createState() => _ManualFoodSelectPageState();
}

class _ManualFoodSelectPageState extends State<ManualFoodSelectPage> {
  final canteens = ["Frontier", "Techno Edge", "Terrace", "The Deck"];
  final canteenToStallMap = {
    "Frontier": ["Stall 1", "Stall 2", "Stall 3"],
    "Techno Edge": ["Stall A", "Stall B", "Stall C"],
    "Terrace": ["Stall X", "Stall Y", "Stall Z"],
    "The Deck": ["Stall T", "Stall U", "Stall V"],
  };
  final stallToFoodMap = {
    "Stall 1": ["FoodData Item 1"],
    "Stall 2": ["FoodData Item 2"],
    "Stall 3": ["FoodData Item 3"],
    "Stall A": ["FoodData Item 4"],
    "Stall B": ["FoodData Item 5"],
    "Stall C": ["FoodData Item 6"],
    "Stall X": ["FoodData Item 7"],
    "Stall Y": ["FoodData Item 8"],
    "Stall Z": ["FoodData Item 9"],
    "Stall T": ["FoodData Item 10"],
    "Stall U": ["FoodData Item 11"],
    "Stall V": ["FoodData Item 12"],
  };

  String? selectedCanteen;
  String? selectedStall;
  String? selectedFood;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Snap and Log"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.fromLTRB(0, 0, 12.0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: DropdownButton2(
              iconStyleData: IconStyleData(
                iconEnabledColor: Theme.of(context).primaryColor,
              ),
              underline: Container(),
              // removes the ugly underline by making it nothing
              isExpanded: true,
              items: canteens
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              value: selectedCanteen,
              onChanged: (String? canteen) {
                setState(
                  () {
                    selectedCanteen = canteen!;
                  },
                );
              },
              hint: const Text("Select canteen"),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.fromLTRB(0, 0, 12.0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: selectedCanteen != null
                  ? [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ]
                  : null,
            ),
            child: DropdownButton2(
              iconStyleData: IconStyleData(
                iconEnabledColor: Theme.of(context).primaryColor,
              ),
              underline: Container(),
              // removes the ugly underline by making it nothing
              isExpanded: true,
              items: canteenToStallMap[selectedCanteen]
                  ?.map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              value: selectedStall,
              onChanged: (String? stall) {
                setState(
                  () {
                    selectedStall = stall!;
                  },
                );
              },
              hint: const Text("Select stall"),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.fromLTRB(0, 0, 12.0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: selectedStall == null
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
            ),
            child: DropdownButton2(
              iconStyleData: IconStyleData(
                iconEnabledColor: Theme.of(context).primaryColor,
              ),
              underline: Container(),
              // removes the ugly underline by making it nothing
              isExpanded: true,
              items: stallToFoodMap[selectedStall]
                  ?.map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              value: selectedFood,
              onChanged: (String? food) {
                setState(
                  () {
                    selectedFood = food!;
                  },
                );
              },
              hint: const Text("Select food"),
            ),
          ),
          // Utils.createVerticalSpace(MediaQuery.of(context).size.height * 2/5), // TODO: Magic number
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: selectedFood == null
                      ? null
                      : () {
                          FoodData fdToReturn = FoodData(
                              name: selectedFood!,
                              energy: 0,
                              protein: 0,
                              fats: 0,
                              carbs: 0,
                              sugar: 0);
                          Navigator.pop(context, fdToReturn);
                        },
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(Size.fromWidth(
                        MediaQuery.of(context).size.width - 16 * 2)),
                    backgroundColor: selectedFood == null
                        ? const MaterialStatePropertyAll(Colors.grey)
                        : null,
                  ),
                  child: const Text("Confirm"),
                ),
                Utils.createVerticalSpace(52),
              ],
            ),
          )
        ],
      ),
    );
  }
}
