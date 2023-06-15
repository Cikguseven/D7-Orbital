import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter/comment_class.dart';
import 'package:my_first_flutter/post_class.dart';
import 'package:my_first_flutter/star_rating.dart';
import 'package:my_first_flutter/user_class.dart';
import 'package:my_first_flutter/utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';


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
  var uuid = const Uuid();
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
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              controller: commentController,
              validator: commentValidator,
              decoration: InputDecoration(
                prefixIcon: const CircleAvatar(
                    radius: 20,
                    // Change to user's profile photo eventually
                    backgroundImage: AssetImage(
                      "images/Cat.jpeg",
                    )),
                suffixIcon: TextButton(
                  onPressed: newCommentSetupCallback,
                  child: const Icon(Icons.arrow_upward),
                ),
                labelText: "What are your thoughts?",
              ),
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
            return TopCommentCard(post: widget.post);
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
        final docComment = docPost
            .collection('comments')
            .doc(uuid.v4());
        CommentData currentComment = CommentData(
            firstName: widget.user.firstName,
            lastName: widget.user.lastName,
            comment: finalComment,
            postTime: DateTime.now());
        await docComment.set(currentComment.toJson());
        await docPost.update({'commentCount': widget.post.commentCount++});
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
  });

  final PostData post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: CircleAvatar(
                radius: 20,
                // Change to user's profile photo eventually
                backgroundImage: AssetImage(
                  "images/Cat.jpeg",
                )),
          ),
          Utils.createHorizontalSpace(15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name container
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

                    // Post age container
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

                // Rating container
                StarRating(
                  rating: post.rating.toDouble(),
                ),

                // Nutritional information container
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 15),
                //   child: InkWell(
                //     onTap: () {
                //       Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (BuildContext context) =>
                //                   NutritionWidget(post: post, user: user)));
                //     },
                //     child: Text(
                //       "View nutritional information",
                //       style: TextStyle(color: NUS_BLUE),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentCard extends StatelessWidget {
  const CommentCard({super.key, required this.comment, required this.user});

  final CommentData comment;
  final UserData user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: CircleAvatar(
              radius: 20,
              // Change to user's profile photo eventually
              backgroundImage: AssetImage(
                "images/Cat.jpeg",
              )),
        ),
        Utils.createHorizontalSpace(15),
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
                // Age of comment
                Text(
                  timeago.format(comment.postTime),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ]),
              Utils.createVerticalSpace(5),
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
