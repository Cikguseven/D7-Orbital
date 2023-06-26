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
    // TODO: Should have CSV files locally to get these
    "Stall 1": [
      FoodData(
          name: "FoodData Item 1",
          energy: 100,
          protein: 10,
          fats: 10,
          carbs: 10,
          sugar: 10)
    ],
    "Stall 2": [
      FoodData(
          name: "FoodData Item 2",
          energy: 200,
          protein: 20,
          fats: 20,
          carbs: 20,
          sugar: 20)
    ],
    "Stall 3": [
      FoodData(
          name: "FoodData Item 3",
          energy: 300,
          protein: 30,
          fats: 30,
          carbs: 30,
          sugar: 30)
    ],
    "Stall A": [
      FoodData(
          name: "FoodData Item 4",
          energy: 400,
          protein: 40,
          fats: 40,
          carbs: 40,
          sugar: 40)
    ],
    "Stall B": [
      FoodData(
          name: "FoodData Item 5",
          energy: 500,
          protein: 50,
          fats: 50,
          carbs: 50,
          sugar: 50)
    ],
    "Stall C": [
      FoodData(
          name: "FoodData Item 6",
          energy: 600,
          protein: 60,
          fats: 60,
          carbs: 60,
          sugar: 60)
    ],
    "Stall X": [
      FoodData(
          name: "FoodData Item 7",
          energy: 700,
          protein: 70,
          fats: 70,
          carbs: 70,
          sugar: 70)
    ],
    "Stall Y": [
      FoodData(
          name: "FoodData Item 8",
          energy: 800,
          protein: 80,
          fats: 80,
          carbs: 80,
          sugar: 80)
    ],
    "Stall Z": [
      FoodData(
          name: "FoodData Item 9",
          energy: 900,
          protein: 90,
          fats: 90,
          carbs: 90,
          sugar: 90)
    ],
    "Stall T": [
      FoodData(
          name: "FoodData Item 10",
          energy: 1000,
          protein: 100,
          fats: 100,
          carbs: 100,
          sugar: 100)
    ],
    "Stall U": [
      FoodData(
          name: "FoodData Item 11",
          energy: 1100,
          protein: 110,
          fats: 110,
          carbs: 110,
          sugar: 110)
    ],
    "Stall V": [
      FoodData(
          name: "FoodData Item 12",
          energy: 1200,
          protein: 120,
          fats: 120,
          carbs: 120,
          sugar: 120)
    ],
  };

  String? selectedCanteen;
  String? selectedStall;
  FoodData? selectedFood;

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
                    selectedStall = null;
                    selectedFood = null;
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
                        offset:
                            const Offset(0, 3), // changes position of shadow
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
                    selectedFood = null;
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
                        offset:
                            const Offset(0, 3), // changes position of shadow
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
                  ?.map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                  .toList(),
              value: selectedFood,
              onChanged: (FoodData? food) {
                setState(
                  () {
                    selectedFood = food;
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
                          Navigator.pop(context, selectedFood);
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
