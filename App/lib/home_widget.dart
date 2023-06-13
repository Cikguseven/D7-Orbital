import 'dart:io';
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
  late Future<List<PostData>> futurePosts;

  @override
  void initState() {
    super.initState();
    futurePosts = Utils.getPostData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Make it Count"),
        ),
      ),
      body: FutureBuilder(
        future: futurePosts,
        builder: (BuildContext context, posts) {
          return RefreshIndicator(
            onRefresh: _pullRefresh,
            child: _listView(posts),
          );
        },
      ),
      bottomNavigationBar: ElevatedButton.icon(
        onPressed: newPostSetupCallback,
        icon: const Icon(Icons.add, size: 24),
        label: const Text(
          "Test post",
        ),
      ),
    );
  }

  // List view of posts loaded on refresh
  Widget _listView(AsyncSnapshot posts) {
    if (posts.hasData) {
      return ListView.builder(
        itemCount: posts.data!.length,
        itemBuilder: (BuildContext context, int index) {
          return PostCard(post: posts.data![index], user: widget.user,);
        },
        physics: const AlwaysScrollableScrollPhysics(),
      );
    } else {
      return const Scaffold(
          body: Center(
              child: Text("No posts")
          )
      );
    }
  }

  // Pull post data from firebase upon refresh
  Future<void> _pullRefresh() async {
    List<PostData> freshPosts = await Utils.getPostData();
    sleep(Duration(milliseconds: 80));
    setState(() {
      futurePosts = Future.value(freshPosts);
    });
  }

  // Submit post to firebase on button press
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
        caption: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis aliquam odio quam, sed congue purus pulvinar blandit.',
        location: 'Singapore',
        postID: '',
        rating: 5,
        calories: 1000,
        protein: 20.2,
        fats: 1.1,
        carbs: 99.3,
        sugar: 13.3,
        postTime: DateTime.now(),
        likedBy: [],
      );
      final docPost = FirebaseFirestore.instance
          .collection('posts')
          .doc(uuid.v4());
      await docPost.set(post.toJson());
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
    } finally {
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }
  }
}

// Formatted container for posts
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.user
  });

  final PostData post;
  final UserData user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          "images/Cow.jpeg",
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
        const SizedBox(height: 5),

        // Like, comment and share buttons
        SocialContainerWidget(post: post,user: user),
        const SizedBox(height: 5),

        // Name container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text(
            '${post.firstName} ${post.lastName}',
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 5),

        // Caption container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text(
            post.caption,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        const SizedBox(height: 10),

        // Post age container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text(
            timeago.format(post.postTime),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

// Like, comment and share buttons
class SocialContainerWidget extends StatefulWidget {
  final PostData post;
  final UserData user;
  const SocialContainerWidget({Key? key, required this.post, required this.user}) : super(key: key);
  @override
  State<SocialContainerWidget> createState() => _SocialContainerState();
}

class _SocialContainerState extends State<SocialContainerWidget>{
  late IconData likeIcon;

  void toggleLike() {
    List<String> likedBy = widget.post.likedBy;
    String? userID = FirebaseAuth.instance.currentUser?.uid;
    if (likedBy.contains(userID)) {
      likedBy.remove(userID);
    } else {
      likedBy.add(userID!);
    }
    FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.postID)
        .update({'likedBy': likedBy});
  }

  @override
  Widget build(BuildContext context) {
    likeIcon = widget.post.likedBy
        .contains(FirebaseAuth.instance.currentUser?.uid)
        ? Icons.favorite
        : Icons.favorite_border;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Like button
        Expanded(
          flex: 1,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                toggleLike();
              });
            },
            icon: Icon(likeIcon),
            label: Text(widget.post.likedBy.length.toString()),
          ),
        ),
        // Comments button
        Expanded(
          flex: 1,
          child: OutlinedButton.icon(
            onPressed: () {
              // open comments page navigator psuh
            },
            icon: const Icon(Icons.comment_rounded),
            label: Text('2'), // add number of comments
          ),
        ),
        Expanded(
          flex: 1,
          child: OutlinedButton.icon(
            onPressed: () {
              // open share overlay
            },
            icon: const Icon(Icons.share),
            label: Text('Share'), // add number of comments
          ),
        ),
      ],
    );
  }
}
