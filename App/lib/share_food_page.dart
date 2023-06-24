import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter/post_data.dart';
import 'package:my_first_flutter/user_data.dart';
import 'package:my_first_flutter/utils.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:uuid/uuid.dart';

import 'main.dart';

class ShareFoodPage extends StatefulWidget {
  // TODO: Now, i just .popUntil(), which causes the page to go back to Snap, But i want to reset all the way back to Home Page
  XFile? image;
  final UserData user;
  final String postID;
  final String imageURL;

  ShareFoodPage(
      {Key? key,
      required this.image,
      required this.user,
      required this.postID,
      required this.imageURL})
      : super(key: key);

  @override
  State<ShareFoodPage> createState() => _ShareFoodPageState();
}

class _ShareFoodPageState extends State<ShareFoodPage> {
  Uuid uuid = const Uuid();
  final captionController = TextEditingController();
  late int _rating;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Snap and Log"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            width: 200,
            decoration: widget.image == null
                ? null
                : BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      image: XFileImage(widget.image!),
                    ),
                  ),
          ),

          // Caption
          TextFormField(
            maxLines: 4,
            minLines: 4,
            controller: captionController,
            decoration: const InputDecoration(
              labelText: "Write a caption...",
              alignLabelWithHint: true,
            ),
          ),
          Utils.createVerticalSpace(52),
          Utils.createTitleMedium("Rate your meal", context),
          // Utils.createVerticalSpace(16),
          // Rate your meal
          Center(
            child: RatingBar.builder(
              itemSize: MediaQuery.of(context).size.width / 7,
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                _rating = rating.toInt();
              },
            ),
          ),

          // Submit buttons
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: Theme.of(context)
                              .elevatedButtonTheme
                              .style
                              ?.copyWith(
                                backgroundColor: const MaterialStatePropertyAll(
                                    Colors.white),
                                textStyle: MaterialStatePropertyAll(
                                  TextStyle(
                                      foreground: Paint()
                                        ..color =
                                            Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            Utils.showSnackBar(
                                "Not implemented yet!"); // TODO: Implement adding to diary
                          },
                          child: const Text("Add to diary"),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: newPostSetupCallback,
                          child: const Text("Share!"),
                        ),
                      ),
                    ],
                  ),
                ),
                Utils.createVerticalSpace(52),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future newPostSetupCallback() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final docPost =
          FirebaseFirestore.instance.collection('posts').doc(widget.postID);
      final PostData newPost = PostData(
        firstName: widget.user.firstName,
        lastName: widget.user.lastName,
        caption: captionController.text.trim(),
        location: 'Singapore',
        postID: widget.postID,
        imageURL: widget.imageURL,
        commentCount: 0,
        rating: _rating,
        calories: 883,
        protein: 20.2,
        fats: 1.1,
        carbs: 99.3,
        sugar: 13.3,
        postTime: DateTime.now(),
        likedBy: [],
      );
      await docPost.set(newPost.toJson());
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
    } finally {
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }
  }
}
