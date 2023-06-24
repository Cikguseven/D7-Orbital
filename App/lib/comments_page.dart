import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter/comment_data.dart';
import 'package:my_first_flutter/post_data.dart';
import 'package:my_first_flutter/star_rating.dart';
import 'package:my_first_flutter/user_data.dart';
import 'package:my_first_flutter/utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import 'check_food_page.dart';

class CommentsWidget extends StatefulWidget {
  final PostData post;
  final UserData user;

  const CommentsWidget({Key? key, required this.post, required this.user})
      : super(key: key);

  @override
  State<CommentsWidget> createState() => _CommentsState();
}

class _CommentsState extends State<CommentsWidget> {
  final commentController = TextEditingController();
  Uuid uuid = const Uuid();
  late Future<List<CommentData>> futureComments;

  String? commentValidator(String? comment) =>
      comment != null && comment.isEmpty ? 'Enter a comment' : null;

  @override
  void initState() {
    super.initState();
    futureComments = Utils.getComments(widget.post.postID);
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _pullRefresh();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: futureComments,
              builder: (BuildContext context, comments) {
                return RefreshIndicator(
                  onRefresh: _pullRefresh,
                  child: _listView(comments),
                );
              },
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                  child: CircleAvatar(
                      radius: 20,
                      // Change to user's profile photo eventually
                      backgroundImage: AssetImage(
                        "images/Cow.jpeg",
                      )),
                ),
                Utils.createHorizontalSpace(15),
                Expanded(
                  child: TextFormField(
                    controller: commentController,
                    validator: commentValidator,
                    decoration: InputDecoration(
                      suffixIcon: TextButton(
                        onPressed: newCommentSetupCallback,
                        child: const Icon(Icons.arrow_upward),
                      ),
                      hintText: "What are your thoughts?",
                      hintStyle: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _listView(AsyncSnapshot comments) {
    if (comments.hasData) {
      return ListView.builder(
        itemCount: comments.data.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return TopCommentCard(post: widget.post, user: widget.user);
          }
          return CommentCard(
            comment: comments.data![index - 1],
            user: widget.user,
          );
        },
        physics: const AlwaysScrollableScrollPhysics(),
      );
    } else {
      return const Scaffold(body: Center(child: Text("No comments")));
    }
  }

  // Pull post data from firebase upon refresh
  Future<void> _pullRefresh() async {
    List<CommentData> freshComments =
        await Utils.getComments(widget.post.postID);
    setState(() {
      futureComments = Future.value(freshComments);
    });
  }

  // Submit post to firebase on button press
  Future newCommentSetupCallback() async {
    String finalComment = commentController.text.trim();
    if (finalComment.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      try {
        final docPost = FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.post.postID);
        final docComment = docPost.collection('comments').doc(uuid.v4());
        CommentData currentComment = CommentData(
            firstName: widget.user.firstName,
            lastName: widget.user.lastName,
            comment: finalComment,
            postTime: DateTime.now());
        await docComment.set(currentComment.toJson());
        await docPost.update({'commentCount': ++widget.post.commentCount});
      } on FirebaseAuthException catch (e) {
        Utils.showSnackBar(e.message);
      } finally {
        commentController.clear();
        _pullRefresh();
        Navigator.pop(context);
      }
    }
  }
}

class TopCommentCard extends StatelessWidget {
  const TopCommentCard({
    super.key,
    required this.post,
    required this.user,
  });

  final PostData post;
  final UserData user;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                    radius: 20,
                    // Change to user's profile photo eventually
                    backgroundImage: AssetImage(
                      "images/Dog.jpeg",
                    )),
                Utils.createHorizontalSpace(15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name of poster
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${post.firstName} ${post.lastName}',
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Utils.createHorizontalSpace(8),

                        // Post age
                        Text(
                          timeago.format(post.postTime),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    Utils.createVerticalSpace(5),

                    Text(
                      post.caption,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.visible,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Utils.createVerticalSpace(10),
                  ],
                ),
              ],
            ),
            Utils.createVerticalSpace(10),
            Column(
              children: [
                StarRating(
                  rating: post.rating.toDouble(),
                ),
                Utils.createVerticalSpace(15),

                // Nutritional information container
                Utils.createTitleMedium("Nutritional Information", context),
                Utils.createVerticalSpace(15),

                // Nutrition bar
                allFoodDataWidget(
                  post.calories, post.protein, post.fats, post.carbs, post.sugar, user, context
                ),
              ],
            ),
          ],
        ));
  }
}

class CommentCard extends StatelessWidget {
  const CommentCard({super.key, required this.comment, required this.user});

  final CommentData comment;
  final UserData user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 5, 15, 0),
          child: CircleAvatar(
              radius: 20,
              // Change to user's profile photo eventually
              backgroundImage: AssetImage(
                "images/Dog.jpeg",
              )),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                // Name of commenter
                Text(
                  '${comment.firstName} ${comment.lastName}',
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Utils.createHorizontalSpace(8),

                // Comment age
                Text(
                  timeago.format(comment.postTime),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ]),
              Utils.createVerticalSpace(5),

              // Comment body
              Text(
                comment.comment,
                textAlign: TextAlign.left,
                overflow: TextOverflow.visible,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        )
      ]),
    );
  }
}
