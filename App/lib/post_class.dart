class PostData {
  // static final postData newPost = postData(
  //     firstName: 'new',
  //     lastName: 'user',
  //     gender: '',
  //     birthday: '',
  //     height: 0.0,
  //     weight: 0.0);

  final String firstName;
  final String lastName;
  final String caption;
  final String location;
  final String commentID;
  final int likes;
  final int rating;
  final int calories;
  final double protein;
  final double fats;
  final double carbs;
  final double sugar;
  final DateTime postTime;


  PostData({
    required this.firstName,
    required this.lastName,
    required this.caption,
    required this.location,
    required this.commentID,
    required this.likes,
    required this.rating,
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
    required this.sugar,
    required this.postTime,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'caption': caption,
    'location': location,
    'commentID': commentID,
    'likes': likes,
    'rating': rating,
    'calories': calories,
    'protein': protein,
    'fats': fats,
    'carbs': carbs,
    'sugar': sugar,
    'postTime': postTime,
  };

  static PostData fromJson(Map<String, dynamic> data) {
    return PostData(
      firstName: data['firstName'],
      lastName: data['lastName'],
      caption: data['caption'],
      location: data['location'],
      commentID: data['commentID'],
      likes: data['likes'],
      rating: data['rating'],
      calories: data['calories'],
      protein: data['protein'],
      fats: data['fats'],
      carbs: data['carbs'],
      sugar: data['sugar'],
      postTime: data['postTime'].toDate());
  }
}
