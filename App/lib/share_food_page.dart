import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:uuid/uuid.dart';

import 'day_log_data.dart';
import 'food_data.dart';
import 'main.dart';
import 'post_data.dart';
import 'user_data.dart';
import 'utils.dart';

class ShareFoodPage extends StatefulWidget {
  final dynamic image;
  final UserData user;
  final FoodData foodData;

  const ShareFoodPage(
      {Key? key,
      required this.image,
      required this.user,
      required this.foodData})
      : super(key: key);

  @override
  State<ShareFoodPage> createState() => _ShareFoodPageState();
}

class _ShareFoodPageState extends State<ShareFoodPage> {
  Uuid uuid = const Uuid();
  final captionController = TextEditingController();
  int _rating = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Save your post'),
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
                      image: widget.image is XFile
                          ? XFileImage(widget.image)
                          : AssetImage(widget.image) as ImageProvider,
                    ),
                  ),
          ),
          const SizedBox(height: 5),
          // Caption
          TextFormField(
            maxLines: 4,
            minLines: 4,
            controller: captionController,
            decoration: const InputDecoration(
              labelText: 'Write a caption...',
              floatingLabelBehavior: FloatingLabelBehavior.never,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 35),
          Utils.createTitleMedium('Rate your meal', context),
          const SizedBox(height: 10),
          // Rate your meal
          Center(
            child: RatingBar.builder(
              itemSize: MediaQuery.of(context).size.width / 7,
              initialRating: 3,
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
                IconButton(
                  onPressed: () {
                    showHelpDialog(context);
                  },
                  icon: const Icon(Icons.help_outline_rounded),
                ),
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
                          onPressed: () => newPostSetupCallback(true),
                          child: const Text('Save to diary'),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => newPostSetupCallback(false),
                          child: const Text('Share!'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 52),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future newPostSetupCallback(bool forDiary) async {
    String caption = captionController.text.trim();
    if (caption == '') {
      Utils.showSnackBar('Add a caption');
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    String postID = uuid.v4();
    String imageLoc;
    try {
      // Store image on Firebase if it is from the user
      if (widget.image is XFile) {
        String imagePath = 'posts/$postID.jpg';
        Reference ref = FirebaseStorage.instance.ref().child(imagePath);
        await ref.putFile(File(widget.image.path));
        imageLoc = await ref.getDownloadURL();
      } else {
        imageLoc = widget.image;
      }
      // Save post to Firebase
      final docPost =
          FirebaseFirestore.instance.collection('posts').doc(postID);
      final PostData newPost = PostData(
        calories: widget.foodData.energy,
        caption: caption,
        carbs: widget.foodData.carbs,
        commentCount: 0,
        fats: widget.foodData.fats,
        firstName: widget.user.firstName,
        forDiary: forDiary,
        imageLoc: imageLoc,
        lastName: widget.user.lastName,
        likedBy: [],
        ownerID: Utils.getAuthUser()!.uid,
        pfpURL: widget.user.pfpURL,
        postID: postID,
        postTime: DateTime.now(),
        protein: widget.foodData.protein,
        rating: _rating,
        sugar: widget.foodData.sugar,
      );
      await docPost.set(newPost.toJson());

      // Add to logs
      final docLog = FirebaseFirestore.instance
          .collection('userData')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('diary')
          .doc(DayLog.dayLogNameFromTimeStamp(Timestamp.now()));

      late DayLog existingDayLog;
      await docLog.get().then((doc) {
        if (doc.exists) {
          existingDayLog = DayLog.fromJson(doc.data()!);
        } else {
          existingDayLog = DayLog.createNew(DateTime.now());
        }
      });

      existingDayLog.caloriesIn += widget.foodData.energy;
      existingDayLog.proteinIn += widget.foodData.protein;
      existingDayLog.fatsIn += widget.foodData.fats;
      existingDayLog.carbsIn += widget.foodData.carbs;
      existingDayLog.sugarIn += widget.foodData.sugar;

      await docLog.set(existingDayLog.toJson());

      await Utils.updateUserData({
        'experience': forDiary
            ? widget.user.experience + 30
            : widget.user.experience + 50,
        'postCount': ++widget.user.postCount,
      });
    } on FirebaseAuthException {
      Utils.showSnackBar(
          forDiary ? 'Unable to save to diary' : 'Unable to share post');
    } finally {
      FocusManager.instance.primaryFocus?.unfocus();
      Utils.showSnackBar(
          forDiary
              ? 'Successfully saved to diary!'
              : 'Successfully shared post!',
          isBad: false,
          duration: 1);
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }
  }

  void showHelpDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: const Text('Got it'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text('Save options'),
      content: const Text(
        'Only you can see posts saved to your diary\n\nEveryone can see your shared posts',
        style: TextStyle(fontWeight: FontWeight.normal),
      ),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
