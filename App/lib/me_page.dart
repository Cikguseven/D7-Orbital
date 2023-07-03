import 'dart:math';

import 'package:flutter/material.dart';
import 'main.dart';
import 'settings_page.dart';
import 'user_data.dart';
import 'utils.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'day_log.dart';

class MePage extends StatefulWidget {
  final UserData user;

  const MePage({Key? key, required this.user}) : super(key: key);

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  int numNotifications = 0;
  String? imageURL;
  int _currentCalories = 0;
  int _goalCalories = 0;

  void loadLastFoodImage() async {
    final diary = widget.user.diary;
    if (diary.isEmpty) {
      return;
    }
    final mostRecentDayLogPostIds = diary.last.postIDs;
    if (mostRecentDayLogPostIds.isEmpty) {
      return;
    }
    imageURL = await Utils.getPostByID(mostRecentDayLogPostIds.last)
        .then((value) => value?.imageURL);

    setState(() {
      // to refresh page
    });
  }

  void loadProgress() async {
    loadCalories();
    loadActivities();
  }

  void loadCalories() async {
    DayLog dayLog = await Utils.getDayLogToday();
    _currentCalories = dayLog.caloriesIn;
    _goalCalories = UserData.nutritionCalculator(widget.user)[0];
  }

  void loadActivities() async {} // TODO: TO be added

  @override
  void initState() {
    super.initState();
    loadLastFoodImage();
    loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String greetings = now.hour < 4
        ? "Good night"
        : now.hour < 12
            ? "Good morning"
            : now.hour < 18
                ? "Good afternoon"
                : "Good evening";

    // Text onTrackIndicator;

    int experience = widget.user.experience;
    int level = (sqrt(experience) * 0.25).floor() + 1;
    num experienceForPrevLevel = pow(4 * (level - 1), 2);
    num experienceForNextLevel = pow(4 * level, 2);
    num experienceForCurrLevel = experienceForNextLevel - experienceForPrevLevel;
    double levelPercent = (experience - experienceForPrevLevel)/ experienceForCurrLevel;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Me"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.mail_outline_rounded),
            onPressed: () {
              setState(
                () {
                  numNotifications = 0;
                },
              );
            },
          ),
          Stack(
            children: [
              numNotifications != 0
                  ? Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$numNotifications',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Container(),
            ],
          ), // Notifications
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const SettingsPage()));
            },
            icon: const Icon(Icons.settings),
          ), // Settings
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              child: Column(
                children: [
                  imageURL == null
                      ? Container()
                      : CircleAvatar(
                          radius: 50,
                          foregroundImage: NetworkImage(imageURL!),
                        ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Utils.createHeadlineMedium(
                    // Limit the length of name displayed to 10
                    "$greetings, ${widget.user.firstName.substring(0, min(widget.user.firstName.length, 10))}!",
                    context,
                    align: TextAlign.start),
                Utils.createVerticalSpace(26),
                Utils.createHeadlineSmall("Your daily overview", context),
                Utils.createVerticalSpace(8),
                Text(
                  "You are on track!",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.lightGreen,
                      ),
                ),
                Utils.createVerticalSpace(26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Calories
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            padding:
                                const MaterialStatePropertyAll(EdgeInsets.zero),
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            minimumSize:
                                const MaterialStatePropertyAll(Size.infinite),
                            foregroundColor:
                                const MaterialStatePropertyAll(Colors.black),
                            backgroundColor:
                                const MaterialStatePropertyAll(Colors.orange),
                          ),
                          onPressed: () {
                            Utils.showSnackBar("Calories");
                          },
                          child: CircularPercentIndicator(
                            radius: MediaQuery.of(context).size.width / 6 - 4,
                            lineWidth: 13.0,
                            animation: true,
                            percent: min(_currentCalories / _goalCalories, 1.0),
                            header: Utils.createTitleSmall("Calories", context),
                            center: const Icon(
                              Icons.fastfood_rounded,
                              size: 48,
                            ),
                            footer: Utils.createTitleSmall(
                                "$_currentCalories/$_goalCalories", context),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: Colors.green,
                          ),
                        ),
                      ),
                    ),
                    Utils.createHorizontalSpace(16),
                    //   Activity
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            padding:
                                const MaterialStatePropertyAll(EdgeInsets.zero),
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            minimumSize:
                                const MaterialStatePropertyAll(Size.infinite),
                            foregroundColor:
                                const MaterialStatePropertyAll(Colors.black),
                            backgroundColor:
                                const MaterialStatePropertyAll(Colors.purple),
                          ),
                          onPressed: () {
                            Utils.showSnackBar("Activity");
                          },
                          child: CircularPercentIndicator(
                            radius: MediaQuery.of(context).size.width / 6 - 4,
                            lineWidth: 13.0,
                            animation: true,
                            percent: min(0.7, 1.0),
                            header: Utils.createTitleSmall("Activity", context),
                            center: const Icon(
                              Icons.sports_kabaddi_rounded,
                              size: 48,
                            ),
                            footer:
                                Utils.createTitleSmall("1463/2000", context),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Utils.createVerticalSpace(30),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: MyApp.themeNotifier.value == ThemeMode.light
                      ? Colors.black
                      : Colors.white,
                ),
                Utils.createVerticalSpace(20),
                Utils.createHeadlineSmall("Experience", context),
                Utils.createVerticalSpace(20),
                LinearPercentIndicator(
                  padding: EdgeInsets.zero,
                  // width: 170.0,
                  animation: true,
                  animationDuration: 100,
                  lineHeight: 20.0,
                  trailing: Utils.createTitleSmall(
                      "Level ${level}\n ${experience}/${experienceForNextLevel} XP",
                      context),
                  percent: levelPercent,
                  center: Text("${(levelPercent * 100).toStringAsFixed(1)}%"),
                  barRadius: const Radius.circular(16),
                  progressColor: Colors.green,
                  backgroundColor: const Color(0xFF888888),
                ),
                Utils.createVerticalSpace(26),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.user.experience += 10;
                          setState(() {
                            Utils.updateUserData({
                              'experience': widget.user.experience + 10,
                            });
                          });
                        },
                        child: const Text("Check in for 10 XP"),
                      ),
                    )
                  ],
                ),
                Utils.createVerticalSpace(30),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: MyApp.themeNotifier.value == ThemeMode.light
                      ? Colors.black
                      : Colors.white,
                ),
                Utils.createVerticalSpace(20),
                Utils.createHeadlineSmall("Badges", context),
                Utils.createVerticalSpace(20),
                Row(
                  children: [
                    // TODO: Make our own Badge class that includes original art and assign badges to userData
                    const Icon(
                      Icons.back_hand_rounded,
                      size: 48,
                      color: Colors.blueAccent,
                    ),
                    Utils.createHorizontalSpace(20),
                    const Icon(Icons.camera_alt,
                        size: 48, color: Colors.deepOrange),
                    Utils.createHorizontalSpace(20),
                    const Icon(
                      Icons.sports_soccer_rounded,
                      size: 48,
                    ),
                    Utils.createHorizontalSpace(20),
                    const Icon(Icons.sports_gymnastics_rounded,
                        size: 48, color: Colors.brown),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
