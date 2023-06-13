import 'package:flutter/material.dart';
import 'package:my_first_flutter/post_class.dart';
import 'package:my_first_flutter/user_class.dart';

class NutritionWidget extends StatefulWidget {
  final PostData post;
  final UserData user;
  const NutritionWidget({Key? key, required this.post, required this.user}) : super(key: key);
  @override
  State<NutritionWidget> createState() => _NutritionState();
}

class _NutritionState extends State<NutritionWidget> {

  @override
  Widget build(BuildContext context) {
    return Text('23');
  }

}