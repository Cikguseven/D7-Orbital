import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:my_first_flutter/settings_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import 'check_food_page.dart';
import 'comments_page.dart';
import 'post_data.dart';
import 'star_rating.dart';
import 'user_data.dart';
import 'utils.dart';

class HomeWidget extends StatefulWidget {
  final UserData user;

  const HomeWidget({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  Uuid uuid = const Uuid();
  late Future<List<PostData>> futurePosts;

  @override
  void initState() {
    getFirstPosts();
    super.initState();
  }

  void getFirstPosts() async {
    futurePosts = Utils.getPosts();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Stream.fromFuture(futurePosts),
        builder: (context, posts) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Home'),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => const SettingsPage()));
                  },
                  icon: const Icon(Icons.settings),
                ), // Settings
              ],
            ),
            body: RefreshIndicator(
              onRefresh: _pullRefresh,
              child: _listView(posts),
            ),
          );
        });
  }

  // List view of posts loaded on refresh
  Widget _listView(AsyncSnapshot posts) {
    if (posts.hasData) {
      if (posts.data!.length == 0) {
        _pullRefresh();
        sleep(const Duration(milliseconds: 300));
      }
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
      return const Scaffold();
    }
  }

  // Pull post data from firebase upon refresh
  Future<void> _pullRefresh() async {
    List<PostData> freshPosts = await Utils.getPosts();
    setState(() {
      futurePosts = Future.value(freshPosts);
    });
  }
}

// Formatted container for posts
class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, required this.user});

  final PostData post;
  final UserData user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Post image
        Container(
          height: MediaQuery.of(context).size.width,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fitWidth,
              image: post.imageLoc.substring(0, 4) == 'http'
                  ? NetworkImage(post.imageLoc)
                  : AssetImage(post.imageLoc) as ImageProvider,
            ),
          ),
        ),

        // Like, comment and share buttons
        SocialContainerWidget(post: post, user: user),
        const SizedBox(height: 5),

        Padding(
          padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
          child: Row(
            children: [
              // User profile image
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: CircleAvatar(
                    radius: 20, backgroundImage: NetworkImage(post.pfpURL)),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name container
                  Text(
                    '${post.firstName} ${post.lastName}',
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),
                  // Caption container
                  SizedBox(
                    width: 280,
                    child: Text(
                      post.caption,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Rating container
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StarRating(
                rating: post.rating.toDouble(),
              ),
              const SizedBox(height: 10),
              // Post age container
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  timeago.format(post.postTime),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              const SizedBox(height: 5),
              // Nutritional information container
              ExpansionTile(
                  title: const Text(
                    'View nutritional information',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                  ),
                  children: [
                    // Nutrition bar
                    allFoodDataWidget(post.calories, post.protein, post.fats,
                        post.carbs, post.sugar, user, context),
                    const SizedBox(height: 15),
                  ]),
            ],
          ),
        ),
        const SizedBox(height: 20),
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
                                post: widget.post, user: widget.user)))
                    .then((value) => setState(() => {}));
              });
            },
            icon: const Icon(Icons.comment_rounded),
            label: Text(
                widget.post.commentCount.toString()), // add number of comments
          ),
        ),
        // Share button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _onShare(context),
            icon: const Icon(Icons.share),
            label: const Text('Share'), // add number of comments
          ),
        ),
      ],
    );
  }

  void _onShare(BuildContext context) async {
    var file = await DefaultCacheManager().getSingleFile(widget.post.imageLoc);
    await Share.shareXFiles([XFile(file.path)],
        text:
            'Check out this post by ${widget.post.firstName} ${widget.post.lastName}!');
  }
}
