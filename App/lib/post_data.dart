class PostData {
  final String firstName;
  final String lastName;
  final String caption;
  final String location;
  final String postID;
  final String imageLoc;
  final String pfpURL;
  int commentCount;
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
    required this.imageLoc,
    required this.pfpURL,
    required this.commentCount,
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
        'imageLoc': imageLoc,
        'pfpURL': pfpURL,
        'commentCount': commentCount,
        'rating': rating,
        'calories': calories,
        'protein': protein,
        'fats': fats,
        'carbs': carbs,
        'sugar': sugar,
        'postTime': postTime,
        'likedBy': likedBy,
      };

  static PostData fromJson(Map<String, dynamic> data) {
    return PostData(
      firstName: data['firstName'],
      lastName: data['lastName'],
      caption: data['caption'],
      location: data['location'],
      postID: data['postID'],
      imageLoc: data['imageLoc'],
      pfpURL: data['pfpURL'],
      commentCount: data['commentCount'],
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
