import 'package:age_calculator/age_calculator.dart';
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
    postCount: 0,
    commentCount: 0,
  );

  // Basic Information
  String pfpURL;
  final String birthday;
  final String checkIn;
  final String firstName;
  final String gender;
  final String lastName;
  final double activityMultiplier;
  final double height;
  final double weight;
  final double weightGoal;
  int commentCount;
  int postCount;
  int experience;

  static setupNewUser({
    required String birthday,
    required String firstName,
    required String gender,
    required String lastName,
    required double activityMultiplier,
    required double height,
    required double weight,
    required double weightGoal,
  }) {
    return UserData(
      activityMultiplier: activityMultiplier,
      birthday: birthday,
      checkIn: '',
      commentCount: 0,
      experience: 0,
      firstName: firstName,
      gender: gender,
      height: height,
      lastName: lastName,
      pfpURL: '',
      postCount: 0,
      weight: weight,
      weightGoal: weightGoal,
    );
  }

  UserData({
    required this.activityMultiplier,
    required this.birthday,
    required this.checkIn,
    required this.commentCount,
    required this.experience,
    required this.firstName,
    required this.gender,
    required this.height,
    required this.lastName,
    required this.pfpURL,
    required this.postCount,
    required this.weight,
    required this.weightGoal,
  });

  Map<String, dynamic> toJson() =>
      {
        'activityMultiplier': activityMultiplier,
        'birthday': birthday,
        'checkIn': checkIn,
        'commentCount': commentCount,
        'experience': experience,
        'firstName': firstName,
        'gender': gender,
        'height': height,
        'lastName': lastName,
        'pfpURL': pfpURL,
        'postCount': postCount,
        'weight': weight,
        'weightGoal': weightGoal,
      };

  static UserData fromJson(Map<String, dynamic> data) {
    return UserData(
      activityMultiplier: data['activityMultiplier'],
      birthday: data['birthday'],
      checkIn: data['checkIn'],
      commentCount: data['commentCount'],
      experience: data['experience'],
      firstName: data['firstName'],
      gender: data['gender'],
      height: data['height'],
      lastName: data['lastName'],
      pfpURL: data['pfpURL'],
      postCount: data['postCount'],
      weight: data['weight'],
      weightGoal: data['weightGoal'],
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

    int rmr =
    (baseRMR * user.activityMultiplier + 1000 * user.weightGoal).round();

    int proteinGoal = (proteinMultiplier * user.weight).round();

    int fatsGoal = (rmr / 30).round();

    int carbsGoal = (rmr / 20 * 3).round();

    int sugarGoal = (rmr / 40).round();

    return [rmr, proteinGoal, fatsGoal, carbsGoal, sugarGoal];
  }
}

class ActivityMultiplier {
  static double get SEDENTARY => 1.2;
  static double get LIGHTLY_ACTIVE => 1.375;
  static double get MODERATELY_ACTIVE => 1.55;
  static double get VERY_ACTIVE => 1.725;
  static double get EXTREMELY_ACTIVE => 1.9;
}
