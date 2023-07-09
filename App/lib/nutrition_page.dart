import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'day_log.dart';
import 'user_data.dart';
import 'utils.dart';

class NutritionPage extends StatefulWidget {
  final UserData user;

  const NutritionPage({Key? key, required this.user})
      : super(key: key);

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  int pageIndex = 0;
  int touchedIndex = -1;
  PageController controller = PageController(viewportFraction: 0.9);
  late Future<List<DayLog>> weekLog;

  @override
  void initState() {
    super.initState();
    getWeekLog();
  }

  Future getWeekLog() async {
    weekLog = Utils.getWeekLog();
    setState(() {});
  }

  Column progressContainer(
      String title, dynamic current, dynamic goal, String units) {
    double percent = current / goal;
    double fixedPercent = min(percent, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Utils.createTitleSmall(title, context),
        const SizedBox(height: 6),
        Row(
          children: [
            Column(
              children: [
                LinearPercentIndicator(
                  alignment: MainAxisAlignment.spaceBetween,
                  padding: EdgeInsets.zero,
                  width: MediaQuery.of(context).size.width * 0.6,
                  animation: true,
                  animationDuration: 100,
                  lineHeight: 20.0,
                  percent: fixedPercent,
                  center: Text('${(percent * 100).toStringAsFixed(0)}%'),
                  barRadius: const Radius.circular(99),
                  progressColor: percent > 1.25 ? Colors.amber : Colors.green,
                  backgroundColor: const Color(0xFF888888),
                ),
              ],
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Utils.createTitleSmall(
                      '${current.toInt()}/$goal $units', context),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DayLog>>(
      future: weekLog,
      builder: (context, logs) {
        if (logs.hasData) {
          return Scaffold(
              appBar: AppBar(
                title: const Text('Nutrition'),
                centerTitle: true,
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Utils.createHeadlineSmall('Daily progress', context),
                    const SizedBox(height: 10),
                    progressContainer(
                        'Calories', logs.data![0].caloriesIn,
                        UserData.nutritionCalculator(widget.user)[0], "kcal"),
                    progressContainer('Protein', logs.data![0].proteinIn,
                        UserData.nutritionCalculator(widget.user)[1], "g"),
                    progressContainer('Fats', logs.data![0].fatsIn,
                        UserData.nutritionCalculator(widget.user)[2], "g"),
                    progressContainer(
                        'Carbohydrates', logs.data![0].carbsIn,
                        UserData.nutritionCalculator(widget.user)[3], "g"),
                    progressContainer('Sugar', logs.data![0].sugarIn,
                        UserData.nutritionCalculator(widget.user)[4], "g"),
                    const SizedBox(height: 10),
                    Utils.sectionBreak(context),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Utils.createHeadlineSmall('Trends', context),
                        SmoothPageIndicator(
                          controller: controller,
                          count: 5,
                          textDirection: TextDirection.ltr,
                          effect: const ColorTransitionEffect(
                            dotHeight: 12,
                            dotWidth: 12,
                            activeDotColor: Color(0xFF003D7C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: PageView.builder(
                          itemCount: 5,
                          controller: controller,
                          onPageChanged: (int tempIndex) =>
                              setState(() => pageIndex = tempIndex),
                          itemBuilder: (_, innerIndex) {
                            String title;
                            switch (innerIndex) {
                              case 0:
                                title = 'Calories';
                                break;
                              case 1:
                                title = 'Protein';
                                break;
                              case 2:
                                title = 'Fats';
                                break;
                              case 3:
                                title = 'Carbohydrates';
                                break;
                              case 4:
                                title = 'Sugar';
                                break;
                              default:
                                throw Error();
                            }
                            return Transform.scale(
                              scale: innerIndex == pageIndex ? 1 : 0.85,
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                      const EdgeInsets.fromLTRB(20, 10, 0, 0),
                                      child: Utils.createTitleSmall(
                                          title, context),
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: BarChart(
                                          data(logs.data!, innerIndex)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              ));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  BarChartData data(List<DayLog> weeklyLog, int pageIndex) {
    String units = pageIndex == 0 ? ' kcal' : ' g';
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.grey,
          tooltipHorizontalAlignment: FLHorizontalAlignment.center,
          tooltipMargin: -50,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String weekDay;
            int newIndex = (group.x + weeklyLog[0].weekday) % 7;
            switch (newIndex) {
              case 0:
                weekDay = 'Monday';
                break;
              case 1:
                weekDay = 'Tuesday';
                break;
              case 2:
                weekDay = 'Wednesday';
                break;
              case 3:
                weekDay = 'Thursday';
                break;
              case 4:
                weekDay = 'Friday';
                break;
              case 5:
                weekDay = 'Saturday';
                break;
              case 6:
                weekDay = 'Sunday';
                break;
              default:
                throw Error();
            }
            double barValue;
            if (pageIndex == 0) {
              barValue = weeklyLog[6 - group.x].caloriesIn.toDouble();
            } else if (pageIndex == 1) {
              barValue = weeklyLog[6 - group.x].proteinIn.toDouble();
            } else if (pageIndex == 2) {
              barValue = weeklyLog[6 - group.x].fatsIn.toDouble();
            } else if (pageIndex == 3) {
              barValue = weeklyLog[6 - group.x].carbsIn.toDouble();
            } else {
              barValue = weeklyLog[6 - group.x].sugarIn.toDouble();
            }
            return BarTooltipItem(
              '$weekDay\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: barValue.toString() + units,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return getTitles(value, weeklyLog);
            },
            reservedSize: 38,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(weeklyLog, pageIndex),
      gridData: const FlGridData(show: false),
    );
  }

  Widget getTitles(double value, List<DayLog> weeklyLog) {
    TextStyle style = TextStyle(
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.black
          : Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text;
    int newIndex = (value.toInt() + weeklyLog[0].weekday) % 7;
    switch (newIndex) {
      case 0:
        text = Text('M', style: style);
        break;
      case 1:
        text = Text('T', style: style);
        break;
      case 2:
        text = Text('W', style: style);
        break;
      case 3:
        text = Text('T', style: style);
        break;
      case 4:
        text = Text('F', style: style);
        break;
      case 5:
        text = Text('S', style: style);
        break;
      case 6:
        text = Text('S', style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: AxisSide.bottom,
      space: 16,
      child: text,
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y,
    int pageIndex, {
    bool isTouched = false,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    double maxValue = UserData.nutritionCalculator(widget.user)[pageIndex] * 1.25;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          color: y > maxValue ? Colors.amber : Colors.green,
          toY: min(y, maxValue),
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: UserData.nutritionCalculator(widget.user)[pageIndex] * 1.25,
            color: const Color(0xFF888888),
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups(List<DayLog> weeklyLog, int pageIndex) =>
      List.generate(7, (i) {
        if (pageIndex == 0) {
          return makeGroupData(i, weeklyLog[6 - i].caloriesIn.toDouble(), pageIndex,
              isTouched: i == touchedIndex);
        } else if (pageIndex == 1) {
          return makeGroupData(i, weeklyLog[6 - i].proteinIn.toDouble(), pageIndex,
              isTouched: i == touchedIndex);
        } else if (pageIndex == 2) {
          return makeGroupData(i, weeklyLog[6 - i].fatsIn.toDouble(), pageIndex,
              isTouched: i == touchedIndex);
        } else if (pageIndex == 3) {
          return makeGroupData(i, weeklyLog[6 - i].carbsIn.toDouble(), pageIndex,
              isTouched: i == touchedIndex);
        } else if (pageIndex == 4) {
          return makeGroupData(i, weeklyLog[6 - i].sugarIn.toDouble(), pageIndex,
              isTouched: i == touchedIndex);
        } else {
          throw Error;
        }
      });
}
