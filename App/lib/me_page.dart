import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'day_log.dart';
import 'main.dart';
import 'nutrition_page.dart';
import 'settings_page.dart';
import 'user_data.dart';
import 'utils.dart';

class MePage extends StatefulWidget {
  final UserData user;

  const MePage({Key? key, required this.user}) : super(key: key);

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  int numNotifications = 0;
  int _currentCalories = 0;
  int _goalCalories = 0;
  bool canCheckIn = false;
  late DayLog dayLog;


  void loadCalories() async {
    dayLog = await Utils.getDayLogToday();
    _currentCalories = dayLog.caloriesIn;
    _goalCalories = UserData.nutritionCalculator(widget.user)[0];
  }

  void checkIn() {
    if (widget.user.checkIn != '') {
      DateTime today = DateTime.now();
      DateTime lastCheckIn = Utils.stringToDateTime(widget.user.checkIn);
      if (today.year == lastCheckIn.year &&
          today.month == lastCheckIn.month &&
          today.day == lastCheckIn.day) {
        return;
      }
    }
    canCheckIn = true;
  }

  @override
  void initState() {
    loadCalories();
    checkIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String greetings = now.hour < 4
        ? 'Good night'
        : now.hour < 12
            ? 'Good morning'
            : now.hour < 18
                ? 'Good afternoon'
                : 'Good evening';

    // Text onTrackIndicator;

    int experience = widget.user.experience;
    int level = (sqrt(experience) * 0.25).floor() + 1;
    num experienceForPrevLevel = pow(4 * (level - 1), 2);
    num experienceForNextLevel = pow(4 * level, 2);
    num experienceForCurrLevel =
        experienceForNextLevel - experienceForPrevLevel;
    double levelPercent =
        (experience - experienceForPrevLevel) / experienceForCurrLevel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Me'),
        centerTitle: true,
        actions: [
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
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(widget.user.pfpURL),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Utils.createHeadlineMedium(
                    // Limit the length of name displayed to 10
                    '$greetings, \n${widget.user.firstName.substring(0, min(widget.user.firstName.length, 10))}!',
                    context,
                    align: TextAlign.start),
                const SizedBox(height: 30),
                Utils.createHeadlineSmall('Your daily overview', context),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Calories
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              padding: const MaterialStatePropertyAll(
                                  EdgeInsets.zero),
                              shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              minimumSize: const MaterialStatePropertyAll(
                                  Size.infinite),
                              foregroundColor: const MaterialStatePropertyAll(
                                  Colors.black),
                              backgroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const MaterialStatePropertyAll(
                                      Colors.white12)
                                  : const MaterialStatePropertyAll(
                                      Colors.blueAccent)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) => NutritionPage(user: widget.user, dayLog: dayLog)));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const Text('Nutrition',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(height: 6),
                                CircularPercentIndicator(
                                  radius:
                                      MediaQuery.of(context).size.width / 6 -
                                          14,
                                  lineWidth: 10,
                                  animation: true,
                                  backgroundColor: const Color(0xFFF5F5F5),
                                  percent: min(
                                      _currentCalories / _goalCalories, 1.0),
                                  center: const Icon(
                                    Icons.fastfood_rounded,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                  circularStrokeCap: CircularStrokeCap.round,
                                  progressColor: Colors.green,
                                ),
                                const SizedBox(height: 6),
                                Text('$_currentCalories/$_goalCalories kcal',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    //   Activity
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              padding: const MaterialStatePropertyAll(
                                  EdgeInsets.zero),
                              shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              minimumSize: const MaterialStatePropertyAll(
                                  Size.infinite),
                              // foregroundColor:
                              //     const MaterialStatePropertyAll(Colors.black),
                              backgroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const MaterialStatePropertyAll(
                                      Colors.white12)
                                  : const MaterialStatePropertyAll(
                                      Colors.blueAccent)),
                          onPressed: () {
                            Utils.showSnackBar('Diary');
                          },
                          child: const Column(
                            children: [
                              SizedBox(height: 8),
                              Text('Diary',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              SizedBox(height: 32),
                              Icon(
                                Icons.sticky_note_2_outlined,
                                size: 60,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: MyApp.themeNotifier.value == ThemeMode.light
                      ? Colors.black
                      : Colors.white,
                ),
                const SizedBox(height: 20),
                Utils.createHeadlineSmall('Experience', context),
                const SizedBox(height: 20),
                LinearPercentIndicator(
                  padding: EdgeInsets.zero,
                  // width: 170.0,
                  animation: true,
                  animationDuration: 100,
                  lineHeight: 20.0,
                  trailing: Utils.createTitleSmall(
                      'Level $level\n $experience/$experienceForNextLevel XP',
                      context),
                  percent: levelPercent,
                  center: Text('${(levelPercent * 100).toStringAsFixed(1)}%'),
                  barRadius: const Radius.circular(16),
                  progressColor: Colors.green,
                  backgroundColor: const Color(0xFF888888),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (canCheckIn) {
                            canCheckIn = false;
                            Utils.showSnackBar('Check in successful',
                                isBad: false);
                            final DateFormat formatter =
                                DateFormat('dd/MM/yyyy');
                            final String formatted =
                                formatter.format(DateTime.now());
                            setState(() {
                              Utils.updateUserData({
                                'experience': widget.user.experience + 10,
                                'checkIn': formatted,
                              });
                            });
                          } else {
                            Utils.showSnackBar('Unable to check in');
                          }
                        },
                        child: canCheckIn
                            ? const Text('Check in for 10 XP')
                            : const Text('Come back tomorrow!'),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: MyApp.themeNotifier.value == ThemeMode.light
                      ? Colors.black
                      : Colors.white,
                ),
                const SizedBox(height: 20),
                Utils.createHeadlineSmall('Badges', context),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    // TODO: Make our own Badge class that includes original art and assign badges to userData
                    Icon(
                      Icons.back_hand_rounded,
                      size: 48,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(width: 20),
                    Icon(Icons.camera_alt,
                        size: 48, color: Colors.deepOrange),
                    SizedBox(width: 20),
                    Icon(
                      Icons.sports_soccer_rounded,
                      size: 48,
                    ),
                    SizedBox(width: 20),
                    Icon(Icons.sports_gymnastics_rounded,
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
