import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'utils.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  Widget placeholderPage() {
    return const Placeholder();
  }

  @override
  Widget build(BuildContext context) {
    ListTile settingsTile(String text, Widget Function() onTapPage) {
      return ListTile(
        leading: Container(
          width: 300, // necessary hack for text to be aligned properly
          height: 300,
          alignment: Alignment.centerLeft,
          child: Utils.createTitleSmall(text, context),
        ),
        trailing: const Icon(Icons.keyboard_arrow_right_rounded),
        tileColor: Colors.white,
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => onTapPage()));
        },
      );
    }

    ListTile darkModeTile() {
      return ListTile(
        leading: Container(
          width: 300, // necessary hack for text to be aligned properly
          height: 300,
          alignment: Alignment.centerLeft,
          child: Utils.createTitleSmall('Dark Mode', context),
        ),
        trailing: const DarkModeSwitch(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              // Testing out to see if this will make the code more
              // readable. In the main container I have multiple Containers to contain
              // a section each, and within each container also arranged in Column
              children: [
                Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(16),
                      child:
                          Utils.createTitleMedium("Account Settings", context),
                    ),
                    settingsTile("Configure Profile", placeholderPage),
                    settingsTile("Change Email/Password", placeholderPage),
                    settingsTile("Privacy Settings", placeholderPage),
                  ],
                ),
                Utils.createVerticalSpace(10),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(16),
                      child: Utils.createTitleMedium("Preferences", context),
                    ),
                    settingsTile("Notification", placeholderPage),
                    darkModeTile(),
                  ],
                ),
                Utils.createVerticalSpace(10),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(16),
                      child: Utils.createTitleMedium("Help", context),
                    ),
                    settingsTile("FAQ", placeholderPage),
                    settingsTile("Contact Us", placeholderPage),
                  ],
                ),
                Utils.createVerticalSpace(10),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(16),
                      child: Utils.createTitleMedium("About", context),
                    ),
                    settingsTile("Private Policy", placeholderPage),
                    settingsTile("Terms of Use", placeholderPage),
                  ],
                ),
                Utils.createVerticalSpace(52),
                ElevatedButton.icon(
                  style: ButtonStyle(
                    textStyle: MaterialStateProperty.all(
                        Theme.of(context).textTheme.titleMedium),
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                    fixedSize: MaterialStateProperty.all(Size.fromWidth(
                        MediaQuery.of(context).size.width - 16 * 2)),
                  ),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, size: 24),
                  label: const Text("Log Out"),
                ),
                Utils.createVerticalSpace(52),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DarkModeSwitch extends StatefulWidget {
  const DarkModeSwitch({super.key});

  @override
  State<DarkModeSwitch> createState() => _SwitchState();
}

class _SwitchState extends State<DarkModeSwitch> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Switch(
      // This bool value toggles the switch.
      value: isDarkMode,
      activeColor: Colors.black12,
      onChanged: (bool value) {
        // This is called when the user toggles the switch.
        setState(() {
          if (value) {
            print('Switched to dark mode');
          } else {
            print('Switched to light mode');
          }
          MyApp.themeNotifier.value =
          MyApp.themeNotifier.value == ThemeMode.light
              ? ThemeMode.dark
              : ThemeMode.light;
          isDarkMode = value;
        });
      },
    );
  }
}
