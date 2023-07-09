import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'day_log.dart';
import 'diary.dart';
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
  static bool canCheckIn = false;
  late Future<DayLog> dayLog;

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
    _MePageState.canCheckIn = true;
  }

  @override
  void initState() {
    super.initState();
    getDayLog();
    checkIn();
  }

  Future getDayLog() async {
    dayLog = Utils.getDayLog();
    setState(() {});
  }

  Row sectionHeader(String title) {
    return Row(
      children: [
        Utils.createHeadlineSmall(title, context),
        IconButton(
          onPressed: () {
            showHelpDialog(context, title);
          },
          icon: const Icon(Icons.help_outline_rounded),
        ),
      ],
    );
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

    return FutureBuilder<DayLog>(
      future: dayLog,
      builder: (context, logs) {
        if (logs.hasData) {
          int currentCalories = logs.data!.caloriesIn;
          int goalCalories = UserData.nutritionCalculator(widget.user)[0];
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
                            builder: (BuildContext context) =>
                                const SettingsPage()));
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
                      const SizedBox(height: 10),
                      sectionHeader('Overview'),
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
                                    foregroundColor:
                                        const MaterialStatePropertyAll(
                                            Colors.black),
                                    backgroundColor: Theme.of(context)
                                                .brightness ==
                                            Brightness.dark
                                        ? const MaterialStatePropertyAll(
                                            Colors.white12)
                                        : const MaterialStatePropertyAll(
                                            Color(0xFF003D7C))),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              NutritionPage(
                                                  user: widget.user)));
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
                                            MediaQuery.of(context).size.width /
                                                    6 -
                                                14,
                                        lineWidth: 10,
                                        animation: true,
                                        backgroundColor:
                                            const Color(0xFFF5F5F5),
                                        percent: min(
                                            currentCalories / goalCalories,
                                            1.0),
                                        center: const Icon(
                                          Icons.fastfood_rounded,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                        circularStrokeCap:
                                            CircularStrokeCap.round,
                                        progressColor: Colors.green,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                          '$currentCalories/$goalCalories kcal',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14)),
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
                                    backgroundColor:
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const MaterialStatePropertyAll(
                                                Colors.white12)
                                            : const MaterialStatePropertyAll(
                                                Color(0xFF003D7C))),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              DiaryPage(user: widget.user)));
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
                      const SizedBox(height: 20),
                      Utils.sectionBreak(context),
                      sectionHeader('Experience'),
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
                        center: Text(
                            '${(levelPercent * 100).toStringAsFixed(0)}% to Level ${level + 1}'),
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
                                Utils.showSnackBar(
                                  'Check in successful!',
                                  isBad: false,
                                );
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
                                Utils.showSnackBar(
                                  'Unable to check in',
                                  duration: 1,
                                );
                              }
                            },
                            style: ButtonStyle(backgroundColor:
                                MaterialStateProperty.resolveWith(
                              (canCheckIn) {
                                // If the button is pressed, return green, otherwise blue
                                if (_MePageState.canCheckIn) {
                                  return const Color(0xFF003D7C);
                                }
                                return const Color(0xFF565656);
                              },
                            )),
                            child: canCheckIn
                                ? const Text('Check in for 10 XP')
                                : const Text('Come back tomorrow!'),
                          ))
                        ],
                      ),
                      const SizedBox(height: 20),
                      Utils.sectionBreak(context),
                      sectionHeader('Badges'),
                      Row(
                        children: [
                          levelBadge(level),
                          const SizedBox(width: 20),
                          postBadge(widget.user.postCount),
                          const SizedBox(width: 20),
                          commentBadge(widget.user.commentCount),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  IconButton levelBadge(int level) {
    Color badgeColour;
    String badgeLabel;
    if (level > 10) {
      badgeColour = const Color(0xFFFFD33C);
      badgeLabel = 'LevelGold';
    } else if (level > 4) {
      badgeColour = const Color(0xFF777777);
      badgeLabel = 'LevelSilver';
    } else {
      badgeColour = Colors.brown;
      badgeLabel = 'LevelBronze';
    }
    return IconButton(
      icon: Icon(Icons.local_police_sharp, size: 40, color: badgeColour),
      onPressed: () {
        showHelpDialog(context, badgeLabel);
      },
    );
  }

  IconButton postBadge(int postCount) {
    Color badgeColour;
    String badgeLabel;
    if (postCount > 20) {
      badgeColour = const Color(0xFFFFD33C);
      badgeLabel = 'PostGold';
    } else if (postCount > 10) {
      badgeColour = const Color(0xFF777777);
      badgeLabel = 'PostSilver';
    } else {
      badgeColour = Colors.brown;
      badgeLabel = 'PostBronze';
    }
    return IconButton(
      icon: Icon(Icons.camera_alt, size: 40, color: badgeColour),
      onPressed: () {
        showHelpDialog(context, badgeLabel);
      },
    );
  }

  IconButton commentBadge(int commentCount) {
    Color badgeColour;
    String badgeLabel;
    if (commentCount > 20) {
      badgeColour = const Color(0xFFFFD33C);
      badgeLabel = 'CommentGold';
    } else if (commentCount > 10) {
      badgeColour = const Color(0xFF777777);
      badgeLabel = 'CommentSilver';
    } else {
      badgeColour = Colors.brown;
      badgeLabel = 'CommentBronze';
    }
    return IconButton(
      icon: Icon(Icons.try_sms_star_sharp, size: 40, color: badgeColour),
      onPressed: () {
        showHelpDialog(context, badgeLabel);
      },
    );
  }

  void showHelpDialog(BuildContext context, String title) {
    Widget okButton = TextButton(
      child: const Text('Got it'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Text titleText;
    Text contentText;

    if (title.substring(0, 5) == 'Level') {
      if (title.substring(5, 6) == 'G') {
        titleText = const Text('Gold level badge');
        contentText = const Text(
          'Wow you are in the top 0.00001% of users!',
          style: TextStyle(fontWeight: FontWeight.normal),
        );
      } else if (title.substring(5, 6) == 'S') {
        titleText = const Text('Silver level badge');
        contentText = const Text(
          'Thanks for showing our app your love <3',
          style: TextStyle(fontWeight: FontWeight.normal),
        );
      } else {
        titleText = const Text('Bronze level badge');
        contentText = const Text(
          'Remember to check in daily for more XP',
          style: TextStyle(fontWeight: FontWeight.normal),
        );
      }
    } else if (title.substring(0, 4) == 'Post') {
      if (title.substring(4, 5) == 'G') {
        titleText = const Text('Gold post badge');
        contentText = const Text(
          'Watch out for your battery!',
          style: TextStyle(fontWeight: FontWeight.normal),
        );
      } else if (title.substring(4, 5) == 'S') {
        titleText = const Text('Silver post badge');
        contentText = const Text(
          'Up and coming snapper!',
          style: TextStyle(fontWeight: FontWeight.normal),
        );
      } else {
        titleText = const Text('Bronze post badge');
        contentText = const Text(
          'Remember to share or save your food posts',
          style: TextStyle(fontWeight: FontWeight.normal),
        );
      }
    } else if (title.substring(0, 6) == 'Commen') {
      if (title.substring(7, 8) == 'G') {
        titleText = const Text('Gold comment badge');
        contentText = const Text(
          'If this was Twitter, you would be rate limited!',
          style: TextStyle(fontWeight: FontWeight.normal),
        );
      } else if (title.substring(7, 8) == 'S') {
        titleText = const Text('Silver comment badge');
        contentText = const Text(
          'The community has noticed you',
          style: TextStyle(fontWeight: FontWeight.normal),
        );
      } else {
        titleText = const Text('Bronze comment badge');
        contentText = const Text(
          'You can comment on the post of others',
          style: TextStyle(fontWeight: FontWeight.normal),
        );
      }
    } else if (title == 'Overview') {
      titleText = const Text('Overview');
      contentText = const Text(
        'The nutrition page displays your daily progress and weekly trends\n\nThe diary page displays all of your posts',
        style: TextStyle(fontWeight: FontWeight.normal),
      );
    } else if (title == 'Experience') {
      titleText = const Text('Experience');
      contentText = const Text(
        'Gain XP and level up by using the app\n\n+10 XP for daily check in\n+30 XP for adding to diary\n+50 XP for sharing your post with the community',
        style: TextStyle(fontWeight: FontWeight.normal),
      );
    } else {
      titleText = const Text('Badges');
      contentText = const Text(
        'Unlock badges by levelling up and hitting milestones!',
        style: TextStyle(fontWeight: FontWeight.normal),
      );
    }

    AlertDialog alert = AlertDialog(
      title: titleText,
      content: contentText,
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
