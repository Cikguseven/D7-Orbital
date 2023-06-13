import 'package:flutter/material.dart';
import 'package:my_first_flutter/post_class.dart';
import 'package:my_first_flutter/user_class.dart';

class CommentsWidget extends StatefulWidget {
  final PostData post;
  final UserData user;
  const CommentsWidget({Key? key, required this.post, required this.user}) : super(key: key);
  @override
  State<CommentsWidget> createState() => _CommentsState();
}

class _CommentsState extends State<CommentsWidget> {

  @override
  Widget build(BuildContext context) {
    return Text('23');
  }

}