import 'package:age_calculator/age_calculator.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter/day_log.dart';
import 'package:my_first_flutter/utils.dart';

class UserData {
  static final UserData newUser = UserData(
    firstName: 'new',
    lastName: 'user',
    gender: '',
    birthday: '',
    height: 0.0,
    weight: 0.0,
    activityMultiplier: 0,
    level: 0,
    experience: 0,
    carbsGoal: 0,
    fatsGoal: 0,
    proteinGoal: 0,
    rmr: 0,
    sugarGoal: 0,
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

  // Goals
  double activityMultiplier;
  int rmr;
  int sugarGoal;
  int proteinGoal;
  int fatsGoal;
  int carbsGoal;

  // Miscellaneous
  List<Badge> badgesEarned;
  int experience = 0;
  int level = 1;

  static setupNewUser({
    required String firstName,
    required String lastName,
    required String gender,
    required String birthday,
    required double height,
    required double weight,
    required double activityMultiplier,
  }) {
    DateTime dtBirthday = Utils.stringToDateTime(birthday);
    DateDuration age = AgeCalculator.age(dtBirthday);
    int yearsOld = age.years;

    double baseRMR = 10 * weight + 6.25 * height - 5 * yearsOld;

    if (gender == "Male") {
      baseRMR += 5;
    } else {
      baseRMR -= 161;
    }

    double proteinMultiplier;

    // unable to use switch for comparing double using ==
    if (activityMultiplier == ActivityMultiplier.SEDENTARY) {
      proteinMultiplier = 0.8;
    } else if (activityMultiplier == ActivityMultiplier.LIGHTLY_ACTIVE) {
      proteinMultiplier = 0.9;
    } else if (activityMultiplier == ActivityMultiplier.MODERATELY_ACTIVE) {
      proteinMultiplier = 1.0;
    } else if (activityMultiplier == ActivityMultiplier.VERY_ACTIVE) {
      proteinMultiplier = 1.1;
    } else {
      // EXTREMELY_ACTIVE
      proteinMultiplier = 1.2;
    }

    int rmr = (baseRMR * activityMultiplier).round();

    int sugarGoal = (rmr / 40).round();

    int proteinGoal = (proteinMultiplier * weight).round();

    int fatsGoal = (rmr / 30).round();

    int carbsGoal = (rmr / 20 * 3).round();
    return UserData(
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      birthday: birthday,
      height: height,
      weight: weight,
      rmr: rmr,
      sugarGoal: sugarGoal,
      proteinGoal: proteinGoal,
      fatsGoal: fatsGoal,
      carbsGoal: carbsGoal,
      activityMultiplier: activityMultiplier,
      experience: 0,
      level: 1,
    );
  }

  UserData(
      {required this.firstName,
      required this.lastName,
      required this.gender,
      required this.birthday,
      required this.height,
      required this.weight,
      required this.rmr,
      required this.sugarGoal,
      required this.proteinGoal,
      required this.fatsGoal,
      required this.carbsGoal,
      required this.activityMultiplier,
      required this.experience,
      required this.level,
      List<DayLog>? existingDiary,
      List<Badge>? existingBadgesEarned})
      : diary = existingDiary ?? List.empty(),
        badgesEarned = existingBadgesEarned ?? List.empty();

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'birthday': birthday,
        'height': height,
        'weight': weight,
        'activityMultiplier': activityMultiplier,
        'rmr': rmr,
        'sugarGoal': sugarGoal,
        'proteinGoal': proteinGoal,
        'fatsGoal': fatsGoal,
        'carbsGoal': carbsGoal,
        'experience': experience,
        'level': level,
      };

  static UserData fromJson(Map<String, dynamic> data) {
    return UserData(
      firstName: data['firstName'],
      lastName: data['lastName'],
      gender: data['gender'],
      birthday: data['birthday'],
      height: data['height'],
      weight: data['weight'],
      activityMultiplier: data['activityMultiplier'],
      rmr: data['rmr'],
      sugarGoal: data['sugarGoal'],
      proteinGoal: data['proteinGoal'],
      fatsGoal: data['fatsGoal'],
      carbsGoal: data['carbsGoal'],
      experience: data['experience'],
      level: data['level'],
    );
  }
}

//

// enum GoalDescription {
//   GAIN_WEIGHT_250,
//   GAIN_WEIGHT_500,
//   LOSE_WEIGHT_250,
//   LOSE_WEIGHT_500,
// }

class ActivityMultiplier {
  /// 1.2
  static double get SEDENTARY => 1.2;

  /// 1.375
  static double get LIGHTLY_ACTIVE => 1.375;

  /// 1.55
  static double get MODERATELY_ACTIVE => 1.55;

  /// 1.725
  static double get VERY_ACTIVE => 1.725;

  /// 1.9
  static double get EXTREMELY_ACTIVE => 1.9;
}

class Badge {
  Icon icon;
  String description;

  Badge(this.icon, this.description);
}

// class ActivityData {
//   Activity activity;
//   Duration duration;
//
//   ActivityData(this.activity, this.duration);
//
//   int get caloriesBurned =>
//       ActivityToCaloriesPerHourMap[activity]! * duration.inHours;
// }
//
// enum Activity {
//   RUNNING,
//   JOGGING,
//   WALKING,
//   SWIMMING,
//   ROPE_SKIPPING,
// }
//
// final ActivityToCaloriesPerHourMap = <Activity, int>{
//   // TOOD: Proper calculator
//   Activity.RUNNING: 100,
//   Activity.JOGGING: 200,
//   Activity.WALKING: 300,
//   Activity.SWIMMING: 400,
//   Activity.ROPE_SKIPPING: 500,
// };
