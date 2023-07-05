class CommentData {
  final String firstName;
  final String lastName;
  final String pfpURL;
  final String comment;
  final DateTime postTime;

  CommentData({
    required this.firstName,
    required this.lastName,
    required this.pfpURL,
    required this.comment,
    required this.postTime,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'pfpURL': pfpURL,
        'comment': comment,
        'postTime': postTime,
      };

  static CommentData fromJson(Map<String, dynamic> data) {
    return CommentData(
      firstName: data['firstName'],
      lastName: data['lastName'],
      pfpURL: data['pfpURL'],
      comment: data['comment'],
      postTime: data['postTime'].toDate(),
    );
  }
}
