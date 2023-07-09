import 'package:cloud_firestore/cloud_firestore.dart';

class DayLog {
  final DateTime date;
  int caloriesIn;
  double proteinIn;
  double fatsIn;
  double carbsIn;
  double sugarIn;
  int weekday;

  // List<ActivityData>? activitiesData;
  // int caloriesOut;

  DayLog(this.date, this.caloriesIn, this.proteinIn, this.fatsIn,
      this.carbsIn, this.sugarIn, this.weekday);

  Map<String, dynamic> toJson() => {
    'caloriesIn': caloriesIn,
    'carbsIn': carbsIn,
    'date': date,
    'fatsIn': fatsIn,
    'proteinIn': proteinIn,
    'sugarIn': sugarIn,
    'weekday': weekday,
  };

  static DayLog fromJson(Map<String, dynamic> data) => DayLog(
    data['caloriesIn'],
    data['carbsIn'],
    data['date'].toDate(),
    data['fatsIn'],
    data['proteinIn'],
    data['sugarIn'],
    data['weekday']
  );

  static String dayLogNameFromTimeStamp(Timestamp ts) {
    DateTime dt = ts.toDate();
    return '${dt.day}_${dt.month}_dayLog';
  }

  DayLog.createNew(DateTime dt) : this(dt, 0, 0, 0, 0, 0, dt.weekday);
}
