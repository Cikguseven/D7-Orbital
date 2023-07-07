import 'dart:math';

import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'day_log.dart';
import 'user_data.dart';
import 'utils.dart';

class NutritionPage extends StatefulWidget {
  final UserData user;
  final DayLog dayLog;

  const NutritionPage({Key? key, required this.user, required this.dayLog})
      : super(key: key);

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  final controller = PageController(viewportFraction: 0.9, keepPage: true);
  int _index = 0;

  Padding progressContainer(
      String title, dynamic current, dynamic goal, String units) {
    double percent = min(current / goal, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Utils.createTitleSmall(title, context),
          const SizedBox(height: 6),
          LinearPercentIndicator(
            alignment: MainAxisAlignment.spaceBetween,
            padding: EdgeInsets.zero,
            width: MediaQuery.of(context).size.width * 0.6,
            animation: true,
            animationDuration: 100,
            lineHeight: 20.0,
            trailing: Utils.createTitleSmall(
                '${current.toInt()}/$goal $units', context),
            percent: percent,
            center: Text('${(percent * 100).toStringAsFixed(1)}%'),
            barRadius: const Radius.circular(99),
            progressColor: Colors.green,
            backgroundColor: const Color(0xFF888888),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        centerTitle: true,
      ),
      body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Utils.createHeadlineSmall('Daily progress', context),
                ),
                const SizedBox(height: 6),
                progressContainer('Calories', widget.dayLog.caloriesIn,
                    UserData.nutritionCalculator(widget.user)[0], "kcal"),
                progressContainer('Protein', widget.dayLog.proteinIn,
                    UserData.nutritionCalculator(widget.user)[1], "g"),
                progressContainer('Fats', widget.dayLog.fatsIn,
                    UserData.nutritionCalculator(widget.user)[2], "g"),
                progressContainer('Carbs', widget.dayLog.carbsIn,
                    UserData.nutritionCalculator(widget.user)[3], "g"),
                progressContainer('Sugar', widget.dayLog.sugarIn,
                    UserData.nutritionCalculator(widget.user)[4], "g"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SmoothPageIndicator(
                        controller: controller,
                        count: 5,
                        textDirection: TextDirection.ltr,
                        effect: ColorTransitionEffect(
                          dotHeight: 12,
                          dotWidth: 12,
                          activeDotColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    itemCount: 5,
                    controller: controller,
                    onPageChanged: (int index) =>
                        setState(() => _index = index),
                    itemBuilder: (_, i) {
                      return Transform.scale(
                        scale: i == _index ? 0.95 : 0.8,
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                            child: Text(
                              "Card ${i + 1}",
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                      );
                    }
                  ),
                ),
              ],
            )
    );
  }
}
