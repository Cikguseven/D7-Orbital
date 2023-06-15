import 'package:flutter/material.dart';
import 'package:my_first_flutter/settings_page.dart';
import 'package:my_first_flutter/user_class.dart';

import 'package:my_first_flutter/csv_to_firebase.dart';

class MePage extends StatefulWidget {
  UserData user;

  MePage({Key? key, required this.user}) : super(key: key);

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  int numNotifications = 0;

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String greetings = now.hour < 3 ? "Good Night"
        : now.hour < 12 ? "Good Morning"
        : now.hour < 18 ? "Good Afternoon"
        : "Good Evening";

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
                          builder: (BuildContext context) =>
                              const CSVUploadWidget()));
                },
              );
            },
            icon: const Icon(Icons.person),
          ),
          title: const Text("Me"),
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
                        builder: (
                            BuildContext context) => const SettingsPage()));
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: const Placeholder(),
    );
  }
}
