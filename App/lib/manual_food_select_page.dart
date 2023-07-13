import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import 'food_data.dart';
import 'nutrition_data.dart';

class ManualFoodSelectPage extends StatefulWidget {
  const ManualFoodSelectPage({Key? key}) : super(key: key);

  @override
  State<ManualFoodSelectPage> createState() => _ManualFoodSelectPageState();
}

class _ManualFoodSelectPageState extends State<ManualFoodSelectPage> {
  String? selectedCanteen;
  String? selectedStall;
  FoodData? selectedFood;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snap and Log'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.fromLTRB(0, 0, 12.0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF313131)
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withOpacity(0.7)
                      : Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: DropdownButton2(
              iconStyleData: IconStyleData(
                iconEnabledColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Theme.of(context).primaryColor,
              ),
              style: const TextStyle(fontWeight: FontWeight.normal),
              underline: Container(),
              // removes the ugly underline by making it nothing
              isExpanded: true,
              items: NutritionData.canteens
                  .map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,),)))
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
              hint: const Text('Select canteen/category'),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.fromLTRB(0, 0, 12.0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF313131)
                  : Colors.white,
              boxShadow: selectedCanteen != null
                  ? [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withOpacity(0.7)
                            : Colors.grey.withOpacity(0.3),
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
                iconEnabledColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Theme.of(context).primaryColor,
              ),
              style: const TextStyle(fontWeight: FontWeight.normal),
              underline: Container(),
              isExpanded: true,
              items: NutritionData.canteenToStallMap[selectedCanteen]
                  ?.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,),)))
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
              hint: const Text('Select stall/category'),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.fromLTRB(0, 0, 12.0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF313131)
                  : Colors.white,
              boxShadow: selectedStall == null
                  ? null
                  : [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withOpacity(0.7)
                            : Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
            ),
            child: DropdownButton2(
              iconStyleData: IconStyleData(
                iconEnabledColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Theme.of(context).primaryColor,
              ),
              style: const TextStyle(fontWeight: FontWeight.normal),
              underline: Container(),
              // removes the ugly underline by making it nothing
              isExpanded: true,
              items: NutritionData.stallToFoodMap[selectedStall]
                  ?.map((e) => DropdownMenuItem(value: e, child: Text(e.name, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,),)))
                  .toList(),
              value: selectedFood,
              onChanged: (FoodData? food) {
                setState(
                  () {
                    selectedFood = food;
                  },
                );
              },
              hint: const Text('Select food'),
            ),
          ),
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
                  child: const Text('Confirm'),
                ),
                const SizedBox(height: 52),
              ],
            ),
          )
        ],
      ),
    );
  }
}
