class CommentData {
  static final CommentData newComment = CommentData(
    firstName: 'John',
    lastName: 'Doe',
    comment: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis aliquam odio quam, sed congue purus pulvinar blandit.',
    postTime: DateTime.now(),
  );

  final String firstName;
  final String lastName;
  final String comment;
  final DateTime postTime;


  CommentData({
    required this.firstName,
    required this.lastName,
    required this.comment,
    required this.postTime,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'comment': comment,
    'postTime': postTime,
  };

  static CommentData fromJson(Map<String, dynamic> data) {
    return CommentData(
      firstName: data['firstName'],
      lastName: data['lastName'],
      comment: data['comment'],
      postTime: data['postTime'].toDate(),
    );
  }
}
