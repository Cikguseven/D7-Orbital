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

  final String firstName;
  final String lastName;
  final String gender;
  final String birthday;
  final double height;
  final double weight;
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
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'birthday': birthday,
        'height': height,
        'weight': weight,
        'RMR': rmr,
        'sugarIntake': sugarIntake,
        'proteinIntake': proteinIntake,
        'fatsIntake': fatsIntake,
        'carbsIntake': carbsIntake,
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
