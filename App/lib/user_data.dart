import 'package:age_calculator/age_calculator.dart';
import 'package:flutter/material.dart';

import 'day_log.dart';
import 'utils.dart';

class UserData {
  static final UserData newUser = UserData(
    firstName: 'new',
    lastName: 'user',
    gender: '',
    birthday: '',
    checkIn: '',
    pfpURL: '',
    height: 0.0,
    weight: 0.0,
    activityMultiplier: 0,
    weightGoal: 0.0,
    experience: 0,
  );

  // Basic Information
  final String firstName;
  final String lastName;
  final String gender;
  final String birthday;
  final String checkIn;
  String pfpURL;
  final double height;
  final double weight;
  final double activityMultiplier;
  final double weightGoal;

  // Diary, separate collection
  List<DayLog> diary;

  // Miscellaneous
  List<Badge> badgesEarned;
  int experience;

  static setupNewUser({
    required String firstName,
    required String lastName,
    required String gender,
    required String birthday,
    required double height,
    required double weight,
    required double activityMultiplier,
    required double weightGoal,
  }) {
    return UserData(
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      birthday: birthday,
      checkIn: '',
      pfpURL: '',
      height: height,
      weight: weight,
      activityMultiplier: activityMultiplier,
      weightGoal: weightGoal,
      experience: 0,
    );
  }

  UserData(
      {required this.firstName,
      required this.lastName,
      required this.gender,
      required this.birthday,
      required this.checkIn,
      required this.pfpURL,
      required this.height,
      required this.weight,
      required this.activityMultiplier,
      required this.weightGoal,
      required this.experience,
      List<DayLog>? existingDiary,
      List<Badge>? existingBadgesEarned})
      : diary = existingDiary ?? List.empty(),
        badgesEarned = existingBadgesEarned ?? List.empty();

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'birthday': birthday,
        'checkIn': checkIn,
        'pfpURL' : pfpURL,
        'height': height,
        'weight': weight,
        'activityMultiplier': activityMultiplier,
        'weightGoal': weightGoal,
        'experience': experience,
      };

  static UserData fromJson(Map<String, dynamic> data) {
    return UserData(
      firstName: data['firstName'],
      lastName: data['lastName'],
      gender: data['gender'],
      birthday: data['birthday'],
      checkIn: data['checkIn'],
      pfpURL: data['pfpURL'],
      height: data['height'],
      weight: data['weight'],
      activityMultiplier: data['activityMultiplier'],
      weightGoal: data['weightGoal'],
      experience: data['experience'],
    );
  }

  static List<int> nutritionCalculator(UserData user) {
    DateTime dtBirthday = Utils.stringToDateTime(user.birthday);
    DateDuration age = AgeCalculator.age(dtBirthday);
    int yearsOld = age.years;

    double baseRMR = 10 * user.weight + 6.25 * user.height - 5 * yearsOld;

    if (user.gender == 'Male') {
      baseRMR += 5;
    } else {
      baseRMR -= 161;
    }

    double proteinMultiplier;

    if (user.activityMultiplier == ActivityMultiplier.SEDENTARY) {
      proteinMultiplier = 0.8;
    } else if (user.activityMultiplier == ActivityMultiplier.LIGHTLY_ACTIVE) {
      proteinMultiplier = 0.9;
    } else if (user.activityMultiplier ==
        ActivityMultiplier.MODERATELY_ACTIVE) {
      proteinMultiplier = 1.0;
    } else if (user.activityMultiplier == ActivityMultiplier.VERY_ACTIVE) {
      proteinMultiplier = 1.1;
    } else {
      // EXTREMELY_ACTIVE
      proteinMultiplier = 1.2;
    }

    int rmr = (baseRMR * user.activityMultiplier + 1000 * user.weightGoal).round();

    int proteinGoal = (proteinMultiplier * user.weight).round();

    int fatsGoal = (rmr / 30).round();

    int carbsGoal = (rmr / 20 * 3).round();

    int sugarGoal = (rmr / 40).round();

    return [rmr, proteinGoal, fatsGoal, carbsGoal, sugarGoal];
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
//   // TODO: Proper calculator
//   Activity.RUNNING: 100,
//   Activity.JOGGING: 200,
//   Activity.WALKING: 300,
//   Activity.SWIMMING: 400,
//   Activity.ROPE_SKIPPING: 500,
// };
