class PostData {
  static final PostData newPost = PostData(
    firstName: 'John',
    lastName: 'Doe',
    caption: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis aliquam odio quam, sed congue purus pulvinar blandit.',
    location: 'Singapore',
    postID: '',
    rating: 5,
    calories: 1000,
    protein: 20.2,
    fats: 1.1,
    carbs: 99.3,
    sugar: 13.3,
    postTime: DateTime.now(),
    likedBy: [],);

  final String firstName;
  final String lastName;
  final String caption;
  final String location;
  final String postID;
  final int rating;
  final int calories;
  final double protein;
  final double fats;
  final double carbs;
  final double sugar;
  final DateTime postTime;
  final List<String> likedBy;


  PostData({
    required this.firstName,
    required this.lastName,
    required this.caption,
    required this.location,
    required this.postID,
    required this.rating,
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
    required this.sugar,
    required this.postTime,
    required this.likedBy,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'caption': caption,
    'location': location,
    'postID': postID,
    'rating': rating,
    'calories': calories,
    'protein': protein,
    'fats': fats,
    'carbs': carbs,
    'sugar': sugar,
    'postTime': postTime,
    'likedBy': likedBy,
  };

  static PostData fromJson(Map<String, dynamic> data, String postID) {
    return PostData(
      firstName: data['firstName'],
      lastName: data['lastName'],
      caption: data['caption'],
      location: data['location'],
      postID: postID,
      rating: data['rating'],
      calories: data['calories'],
      protein: data['protein'],
      fats: data['fats'],
      carbs: data['carbs'],
      sugar: data['sugar'],
      postTime: data['postTime'].toDate(),
      likedBy: data['likedBy'].cast<String>(),
    );
  }
}
