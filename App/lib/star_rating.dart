import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int starCount;
  final double rating;

  const StarRating({super.key, this.starCount = 5, this.rating = .0});

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = const Icon(
        Icons.star_rate,
        color: Colors.grey,
      );
    } else if (index > rating - 1) {
      icon = const Icon(
        Icons.star_rate,
        color: Colors.blue,
      );
    } else {
      icon = const Icon(
        Icons.star_rate,
        color: Colors.amber,
      );
    }
    return InkResponse(
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        children:
            List.generate(starCount, (index) => buildStar(context, index)));
  }
}
