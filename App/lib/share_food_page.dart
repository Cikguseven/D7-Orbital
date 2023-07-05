import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:uuid/uuid.dart';

import 'day_log.dart';
import 'food_data.dart';
import 'main.dart';
import 'post_data.dart';
import 'user_data.dart';
import 'utils.dart';

class ShareFoodPage extends StatefulWidget {
  dynamic image;
  final UserData user;
  final FoodData foodData;

  ShareFoodPage(
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
        title: const Text('Snap and Log'),
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

          // Caption
          TextFormField(
            maxLines: 4,
            minLines: 4,
            controller: captionController,
            decoration: const InputDecoration(
              labelText: 'Write a caption...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 52),
          Utils.createTitleMedium('Rate your meal', context),
          // const SizedBox(height: 16),
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
                                'Not implemented yet!'); // TODO: Implement adding to diary
                          },
                          child: const Text('Add to diary'),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: newPostSetupCallback,
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

  Future newPostSetupCallback() async {
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
        String imagePath = 'posts/${postID}.jpg';
        Reference ref = FirebaseStorage.instance.ref().child(imagePath);
        await ref.putFile(File(widget.image.path));
        imageLoc = await ref.getDownloadURL();
      } else {
        imageLoc = widget.image;
      }
      // Share with community
      final docPost =
          FirebaseFirestore.instance.collection('posts').doc(postID);
      final PostData newPost = PostData(
        firstName: widget.user.firstName,
        lastName: widget.user.lastName,
        caption: caption,
        location: 'Singapore',
        postID: postID,
        imageLoc: imageLoc,
        pfpURL: widget.user.pfpURL,
        commentCount: 0,
        rating: _rating,
        calories: widget.foodData.energy,
        protein: widget.foodData.protein,
        fats: widget.foodData.fats,
        carbs: widget.foodData.carbs,
        sugar: widget.foodData.sugar,
        postTime: DateTime.now(),
        likedBy: [],
      );
      await docPost.set(newPost.toJson());

      // Add to diary
      final docDiary = FirebaseFirestore.instance
          .collection('userData')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('diary')
          .doc(DayLog.dayLogNameFromTimeStamp(Timestamp.now()));

      late DayLog existingDayLog;
      await docDiary.get().then((doc) {
        if (doc.exists) {
          existingDayLog = DayLog.fromJson(doc.data()!);
        } else {
          existingDayLog = DayLog.createNew();
        }
      });

      existingDayLog.postIDs.add(postID);
      existingDayLog.caloriesIn += widget.foodData.energy;
      existingDayLog.proteinIn += widget.foodData.protein;
      existingDayLog.fatIn += widget.foodData.fats;
      existingDayLog.carbIn += widget.foodData.carbs;
      existingDayLog.sugarIn += widget.foodData.sugar;

      await docDiary.set(existingDayLog.toJson());

      await Utils.updateUserData({
        'experience': widget.user.experience + 50,
      });
    } on FirebaseAuthException {
      Utils.showSnackBar('Unable to share post');
    } finally {
      Utils.showSnackBar('Shared successfully', isBad: false);
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }
  }
}
