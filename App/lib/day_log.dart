import 'package:cloud_firestore/cloud_firestore.dart';

class DayLog {
  final Timestamp date;
  List<String> postIDs;
  int caloriesIn;
  double proteinIn;
  double fatIn;
  double carbIn;
  double sugarIn;

  // List<ActivityData>? activitiesData;
  // int caloriesOut;

  DayLog(this.date, this.postIDs, this.caloriesIn, this.proteinIn, this.fatIn,
      this.carbIn, this.sugarIn);

  Map<String, dynamic> toJson() =>
      {
        'date': date,
        'postIDs': postIDs,
        'caloriesIn': caloriesIn,
        'proteinIn': proteinIn,
        'fatIn': fatIn,
        'carbIn': carbIn,
        'sugarIn': sugarIn,
      };

  static DayLog fromJson(Map<String, dynamic> data) =>
      DayLog(
          data["date"],
          data["postIDs"].cast<String>(),
          data["caloriesIn"],
          data["proteinIn"],
          data["fatIn"],
          data["carbIn"],
          data["sugarIn"]
      );
  static String dayLogNameFromTimeStamp(Timestamp ts) {
    DateTime dt = ts.toDate();
    return "${dt.day}_${dt.month}_dayLog";
  }

  DayLog.createNew() : this(Timestamp.now(), [], 0, 0, 0 ,0, 0);
}