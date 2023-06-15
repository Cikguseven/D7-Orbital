class UserData {
  static final UserData newUser = UserData(
      firstName: 'new',
      lastName: 'user',
      gender: '',
      birthday: '',
      height: 0.0,
      weight: 0.0,
  );

  final String firstName;
  final String lastName;
  final String gender;
  final String birthday;
  final double height;
  final double weight;

  UserData({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birthday,
    required this.height,
    required this.weight,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'gender': gender,
    'birthday': birthday,
    'height': height,
    'weight': weight,
  };

  static UserData? fromJson(Map<String, dynamic> data) {
    return UserData(
      firstName: data['firstName'],
      lastName: data['lastName'],
      gender: data['gender'],
      birthday: data['birthday'],
      height: data['height'],
      weight: data['weight'],
    );
  }
}
