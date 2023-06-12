import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_first_flutter/post_class.dart';
import 'package:my_first_flutter/user_class.dart';
import 'package:my_first_flutter/utils.dart';
import 'package:uuid/uuid.dart';
import 'main.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeWidget extends StatefulWidget {
  final UserData user;

  const HomeWidget({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  var uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Make it Count"),
        ),
      ),
      body: StreamBuilder(
        stream: Stream.fromFuture(Utils.getPostData()),
        builder: (BuildContext context, posts) {
          if (posts.hasData) {
            return ListView.separated(
              itemCount: posts.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return PostCard(post: posts.data![index]);
              },
              separatorBuilder: (BuildContext context,
                  int index) => const Divider(),
            );
          } else {
            return const Scaffold(
              body: Center(
                child: Text("No posts")
              )
            );
          }
        },
      ),
      bottomNavigationBar: ElevatedButton.icon(
        onPressed: newPostSetupCallback,
        icon: const Icon(Icons.person_4_rounded, size: 24),
        label: const Text(
          "Test post",
        ),
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
      final post = PostData(
        firstName: widget.user.firstName,
        lastName: widget.user.lastName,
        caption: 'test',
        location: 'Singapore',
        commentID: uuid.v4(),
        likes: 0,
        rating: 5,
        calories: 1000,
        protein: 20.2,
        fats: 1.1,
        carbs: 99.3,
        sugar: 13.3,
        postTime: DateTime.now(),
      );
      final docPost = FirebaseFirestore.instance
          .collection('posts')
          .doc(uuid.v4());
      await docPost.set(post.toJson());
    } on FirebaseAuthException catch (e) {
      print(e);
      Utils.showSnackBar(e.message);
    } finally {
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }
  }
}

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
  });

  final PostData post;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add image
        const SizedBox(height: 5),
        Text('${post.firstName} ${post.lastName}'),
        const SizedBox(height: 5),
        Text(post.caption),
        const SizedBox(height: 5),
        Text(timeago.format(post.postTime)),
        const SizedBox(height: 10),
      ],
    );
  }
}