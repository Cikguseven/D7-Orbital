import 'comments_widget.dart';
import 'main.dart';
import 'nutrition_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter/post_class.dart';
import 'package:my_first_flutter/star_rating.dart';
import 'package:my_first_flutter/themes/theme_constants.dart';
import 'package:my_first_flutter/user_class.dart';
import 'package:my_first_flutter/utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

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
    _pullRefresh();
    super.initState();
    futurePosts = Utils.getPosts();
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
          return PostCard(
            post: posts.data![index],
            user: widget.user,
          );
        },
        physics: const AlwaysScrollableScrollPhysics(),
      );
    } else {
      return const Scaffold(body: Center(child: Text("No posts")));
    }
  }

  // Pull post data from firebase upon refresh
  Future<void> _pullRefresh() async {
    List<PostData> freshPosts = await Utils.getPosts();
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
      final docPost =
          FirebaseFirestore.instance.collection('posts').doc(uuid.v4());
      await docPost.set(PostData.newPost.toJson());
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
    } finally {
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }
  }
}

// Formatted container for posts
class PostCard extends StatelessWidget {
  PostCard({super.key, required this.post, required this.user});

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

        // Like, comment and share buttons
        SocialContainerWidget(
            post: post, user: user),
        Utils.createVerticalSpace(5),

        // Name container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            '${post.firstName} ${post.lastName}',
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Utils.createVerticalSpace(5),

        // Caption container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            post.caption,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Utils.createVerticalSpace(10),

        // Rating container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: StarRating(
            rating: post.rating.toDouble(),
          ),
        ),
        Utils.createVerticalSpace(10),

        // Nutritional information container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          NutritionWidget(post: post, user: user)));
            },
            child: Text(
              "View nutritional information",
              style: TextStyle(color: NUS_BLUE),
            ),
          ),
        ),
        Utils.createVerticalSpace(10),

        // Post age container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            timeago.format(post.postTime),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        Utils.createVerticalSpace(30),
      ],
    );
  }
}

// Like, comment and share buttons
class SocialContainerWidget extends StatefulWidget {
  final PostData post;
  final UserData user;

  const SocialContainerWidget(
      {Key? key, required this.post, required this.user})
      : super(key: key);

  @override
  State<SocialContainerWidget> createState() => _SocialContainerState();
}

class _SocialContainerState extends State<SocialContainerWidget> {
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
    likeIcon =
        widget.post.likedBy.contains(FirebaseAuth.instance.currentUser?.uid)
            ? Icons.favorite
            : Icons.favorite_border;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Like button
        Expanded(
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
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => CommentsWidget(
                            post: widget.post, user: widget.user)));
              });
            },
            icon: const Icon(Icons.comment_rounded),
            label: Text(widget.post.commentCount.toString()), // add number of comments
          ),
        ),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // open share overlay
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'), // add number of comments
          ),
        ),
      ],
    );
  }
}
