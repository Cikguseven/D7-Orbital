import 'package:cloud_firestore/cloud_firestore.dart';

class DayLog {
  DateTime date;
  int caloriesIn;
  double proteinIn;
  double fatsIn;
  double carbsIn;
  double sugarIn;
  int weekday;

  DayLog({
    required this.caloriesIn,
    required this.carbsIn,
    required this.date,
    required this.fatsIn,
    required this.proteinIn,
    required this.sugarIn,
    required this.weekday,
  });

  Map<String, dynamic> toJson() => {
        'caloriesIn': caloriesIn,
        'carbsIn': carbsIn,
        'date': date,
        'fatsIn': fatsIn,
        'proteinIn': proteinIn,
        'sugarIn': sugarIn,
        'weekday': weekday,
      };

  static DayLog fromJson(Map<String, dynamic> data) {
    return DayLog(
      caloriesIn: data['caloriesIn'],
      carbsIn: data['carbsIn'],
      date: data['date'].toDate(),
      fatsIn: data['fatsIn'],
      proteinIn: data['proteinIn'],
      sugarIn: data['sugarIn'],
      weekday: data['weekday'],
    );
  }

  static String dayLogNameFromTimeStamp(Timestamp ts) {
    DateTime dt = ts.toDate();
    return '${dt.day}_${dt.month}_dayLog';
  }

  static DayLog createNew(DateTime dt) {
    return DayLog(
        caloriesIn: 0,
        carbsIn: 0,
        date: dt,
        fatsIn: 0,
        proteinIn: 0,
        sugarIn: 0,
        weekday: dt.weekday);
  }
}
