import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_first_flutter/settings_page.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'check_food_page.dart';
import 'post_data.dart';
import 'star_rating.dart';
import 'user_data.dart';
import 'utils.dart';

class DiaryPage extends StatefulWidget {
  final UserData user;

  const DiaryPage({Key? key, required this.user}) : super(key: key);

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  late Future<List<PostData>> futureDiary;

  @override
  void initState() {
    super.initState();
    getFirstPosts();
  }

  void getFirstPosts() async {
    futureDiary = Utils.getDiary();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Stream.fromFuture(futureDiary),
        builder: (context, posts) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Diary'),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const SettingsPage()));
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
    List<PostData> freshPosts = await Utils.getDiary();
    setState(() {
      futureDiary = Future.value(freshPosts);
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

        const SizedBox(height: 10),

        // Post content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: SizedBox(
                  width: 300,
                  child: Text(
                    post.caption,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
        const SizedBox(height: 15),
      ],
    );
  }
}
