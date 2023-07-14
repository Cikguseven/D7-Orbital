class PostData {
  final DateTime postTime;
  final List<String> likedBy;
  final String caption;
  final String firstName;
  final String imageLoc;
  final String lastName;
  final String ownerID;
  final String pfpURL;
  final String postID;
  final bool forDiary;
  final double carbs;
  final double fats;
  final double protein;
  final double sugar;
  final int calories;
  final int rating;
  int commentCount;

  PostData({
    required this.calories,
    required this.caption,
    required this.carbs,
    required this.commentCount,
    required this.fats,
    required this.firstName,
    required this.forDiary,
    required this.imageLoc,
    required this.lastName,
    required this.likedBy,
    required this.ownerID,
    required this.pfpURL,
    required this.postID,
    required this.postTime,
    required this.protein,
    required this.rating,
    required this.sugar,
  });

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'caption': caption,
        'carbs': carbs,
        'commentCount': commentCount,
        'fats': fats,
        'firstName': firstName,
        'forDiary': forDiary,
        'imageLoc': imageLoc,
        'lastName': lastName,
        'likedBy': likedBy,
        'pfpURL': pfpURL,
        'postID': postID,
        'ownerID': ownerID,
        'postTime': postTime,
        'protein': protein,
        'rating': rating,
        'sugar': sugar,
      };

  static PostData fromJson(Map<String, dynamic> data) {
    return PostData(
      calories: data['calories'],
      caption: data['caption'],
      carbs: data['carbs'],
      commentCount: data['commentCount'],
      fats: data['fats'],
      firstName: data['firstName'],
      forDiary: data['forDiary'],
      imageLoc: data['imageLoc'],
      lastName: data['lastName'],
      likedBy: data['likedBy'].cast<String>(),
      pfpURL: data['pfpURL'],
      postID: data['postID'],
      postTime: data['postTime'].toDate(),
      protein: data['protein'],
      ownerID: data['ownerID'],
      rating: data['rating'],
      sugar: data['sugar'],
    );
  }
}
