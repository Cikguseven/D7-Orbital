import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_first_flutter/post_data.dart';
import 'package:flutter/material.dart';

class UserData {
  static final UserData newUser = UserData(
    firstName: 'new',
    lastName: 'user',
    gender: '',
    birthday: '',
    height: 0.0,
    weight: 0.0,
    rmr: 2000,
    sugarIntake: 0,
    proteinIntake: 0,
    fatsIntake: 0,
    carbsIntake: 0,
  );

  // Basic Information
  final String firstName;
  final String lastName;
  final String gender;
  final String birthday;
  final double height;
  final double weight;

  // Diary, separate collection
  List<DayLog> diary;

  // Goal, separate collection
  Goal? goal;

  // Miscellaneous
  List<Badge> badgesEarned;
  int experience;
  int level;
  final int rmr;
  final int sugarIntake;
  final int proteinIntake;
  final int fatsIntake;
  final int carbsIntake;

  UserData({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birthday,
    required this.height,
    required this.weight,
    required this.rmr,
    required this.sugarIntake,
    required this.proteinIntake,
    required this.fatsIntake,
    required this.carbsIntake,
  }) : diary = List.empty(), goal = null, badgesEarned = List.empty(), experience = 0, level = 1;

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'birthday': birthday,
        'height': height,
        'weight': weight,
        // 'RMR': rmr,
        // 'sugarIntake': sugarIntake,
        // 'proteinIntake': proteinIntake,
        // 'fatsIntake': fatsIntake,
        // 'carbsIntake': carbsIntake,
      };

  static UserData? fromJson(Map<String, dynamic> data) {
    return UserData(
      firstName: data['firstName'],
      lastName: data['lastName'],
      gender: data['gender'],
      birthday: data['birthday'],
      height: data['height'],
      weight: data['weight'],
      rmr: data['RMR'],
      sugarIntake: data['sugarIntake'],
      proteinIntake: data['proteinIntake'],
      fatsIntake: data['fatsIntake'],
      carbsIntake: data['carbsIntake'],
    );
  }
}

class DayLog {
  final Timestamp date;
  List<PostData> postsData;
  int caloriesIn;
  int proteinIn;
  int fatIn;
  int carbIn;
  int sugarIn;
  List<ActivityData>? activitiesData;
  int caloriesOut;

  DayLog(this.date, this.postsData, this.caloriesIn, this.proteinIn, this.fatIn,
      this.carbIn, this.sugarIn, this.activitiesData, this.caloriesOut);
}

//

enum GoalDescription {
  GAIN_WEIGHT_250,
  GAIN_WEIGHT_500,
  LOSE_WEIGHT_250,
  LOSE_WEIGHT_500,
}

const ActivityLevel = {
  "SEDENTARY": 1.2,
  "LIGHTLY_ACTIVE": 1.375,
  "MODERATELY_ACTIVE": 1.55,
  "VERY_ACTIVE": 1.725,
  "EXTREMELY_ACTIVE": 1.9,
};

class Goal {
  GoalDescription goalDescription;
  String activityLevel;
  int caloriesGoal = 0;
  int activitiesGoal = 0;

  Goal(this.goalDescription, this.activityLevel) {
    final _goals = calculateGoals();
    caloriesGoal = _goals[0];
    activitiesGoal = _goals[1];
  }

  List<int> calculateGoals() {
    //TODO: Add formula
    int _caloriesGoal = 2500;
    int _activitiesGoal = 2000;
    return [_caloriesGoal, _activitiesGoal];
  }
}

class Miscellaneous {
  List<Badge> badgesEarned;
  int experience;
  int level;

  Miscellaneous(this.badgesEarned, this.experience, this.level);

  Miscellaneous.newUser()
      : badgesEarned = List.empty(),
        experience = 0,
        level = 1 {}
}

class Badge {
  Icon icon;
  String description;

  Badge(this.icon, this.description);

}

class ActivityData {
  Activity activity;
  Duration duration;

  ActivityData(this.activity, this.duration);

  int get caloriesBurned =>
      ActivityToCaloriesPerHourMap[activity]! * duration.inHours;
}

enum Activity {
  RUNNING,
  JOGGING,
  WALKING,
  SWIMMING,
  ROPE_SKIPPING,
}

final ActivityToCaloriesPerHourMap = <Activity, int>{ // TOOD: Proper calculator
  Activity.RUNNING: 100,
  Activity.JOGGING: 200,
  Activity.WALKING: 300,
  Activity.SWIMMING: 400,
  Activity.ROPE_SKIPPING: 500,
};