import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_first_flutter/post_class.dart';
import 'package:my_first_flutter/settings_page.dart';
import 'package:my_first_flutter/user_class.dart';
import 'package:my_first_flutter/utils.dart';
import 'package:my_first_flutter/csv_to_firebase.dart';

class MeWidget extends StatefulWidget {
  final UserData user;
  final List<PostData> post;

  MeWidget({Key? key, required this.user, required this.post}) : super(key: key);

  @override
  State<MeWidget> createState() => _MeWidgetState();
}

class _MeWidgetState extends State<MeWidget> {
  int numNotifications = 0;

  @override
  Widget build(BuildContext context) {
    print(DateTime.now().year);
    print(Utils.stringToDateTime(widget.user.birthday));
    print('a');
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            /// Placeholder testing notifications
            setState(
              () {
                numNotifications++;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => CSVUploadWidget()));
              },
            );
          },
          icon: const Icon(Icons.person),
        ),
        title: Text("Me"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.mail_outline_rounded),
            onPressed: () {
              setState(
                () {
                  numNotifications = 0;
                },
              );
            },
          ),
          Stack(
            children: [
              numNotifications != 0
                  ? Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$numNotifications',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const SettingsPage()));
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
                "This page will contain statistics of the User. Testing CRUD..."),
            const SizedBox(
              height: 10,
            ),
            Text("Hey ${widget.user.firstName}!"),
            const SizedBox(
              height: 10,
            ),
            Text(
                "Age: You are ${DateTime.now().year - Utils.stringToDateTime(widget.user.birthday).year} this year"),
            const SizedBox(
              height: 10,
            ),
            Text("Height: ${widget.user.height} CM"),
            const SizedBox(
              height: 10,
            ),
            Text("Weight: ${widget.user.weight} KG"),
            const SizedBox(
              height: 10,
            ),
            Text("Gender: ${widget.user.gender}"),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton.icon(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.arrow_back, size: 32),
              label: const Text("Sign Out"),
            )
          ],
        ),
      ),
    );
  }
}
