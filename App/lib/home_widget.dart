import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_first_flutter/post_class.dart';
import 'package:my_first_flutter/user_class.dart';
import 'package:my_first_flutter/utils.dart';
import 'package:uuid/uuid.dart';

import 'main.dart';

class HomeWidget extends StatefulWidget {
  final UserData user;
  final List<PostData> post;
  HomeWidget({Key? key, required this.user, required this.post}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  bool done = false;
  var uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Make it Count"),
        ),
      ),
      body: ListView.separated(
        itemCount: widget.post.length,
        itemBuilder: (BuildContext context, int index) {
          return Container (
            height: 100,
            color: Colors.amber[600 - index * 20],
            child: Center(child: Text('${widget.post[index].commentID} || ${widget.post[index].postTime}')),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
      bottomNavigationBar:
      ElevatedButton.icon(
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

// class HomeWidget extends StatelessWidget {
//   UserData user;
//   HomeWidget({Key? key, required this.user}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Center(
//           child: Text("Make it count"),
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // SizedBox(height: MediaQuery.of(context).size.height / 3),
//             Text("Signed in as:"),
//             Text(user.firstName + " " + user.lastName),
//           ],
//         ),
//       ),
//     );
//   }
// }
