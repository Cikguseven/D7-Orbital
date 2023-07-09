class CommentData {
  final String firstName;
  final String lastName;
  final String pfpURL;
  final String comment;
  final DateTime postTime;

  CommentData({
    required this.comment,
    required this.firstName,
    required this.lastName,
    required this.pfpURL,
    required this.postTime,
  });

  Map<String, dynamic> toJson() => {
    'comment': comment,
    'firstName': firstName,
    'lastName': lastName,
    'pfpURL': pfpURL,
    'postTime': postTime,
  };

  static CommentData fromJson(Map<String, dynamic> data) {
    return CommentData(
      comment: data['comment'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      pfpURL: data['pfpURL'],
      postTime: data['postTime'].toDate(),
    );
  }
}
