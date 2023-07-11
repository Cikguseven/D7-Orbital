import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter/update_profile_pic_page.dart';
import 'package:my_first_flutter/update_weight_goal_page.dart';
import 'package:my_first_flutter/update_weight_page.dart';

import 'main.dart';
import 'utils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Widget updateWeightWidget() {
    return const UpdateWeightPage();
  }

  Widget updateWeightGoalWidget() {
    return const UpdateWeightGoalPage();
  }

  Widget updateProfilePicWidget() {
    return const UpdateProfilePicPage();
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
        tileColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF111111)
            : Colors.white,
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
          child: Utils.createTitleSmall('Toggle dark mode', context),
        ),
        trailing: const DarkModeSwitch(),
        tileColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF111111)
            : Colors.white,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(16),
                  child:
                      Utils.createTitleMedium('Account Settings', context),
                ),
                settingsTile('Update weight', updateWeightWidget),
                settingsTile('Update weight goal', updateWeightGoalWidget),
                settingsTile(
                    'Update profile picture', updateProfilePicWidget),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(16),
                  child: Utils.createTitleMedium('Preferences', context),
                ),
                darkModeTile(),
                const SizedBox(height: 52),
                ElevatedButton.icon(
                  style: ButtonStyle(
                    textStyle: MaterialStateProperty.all(
                        Theme.of(context).textTheme.titleMedium),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                    fixedSize: MaterialStateProperty.all(Size.fromWidth(
                        MediaQuery.of(context).size.width - 20 * 2)),
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    navigatorKey.currentState!.popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log Out'),
                ),
                const SizedBox(height: 52),
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
  bool isDarkMode = MyApp.themeNotifier.value == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return Switch(
      // This bool value toggles the switch.
      value: isDarkMode,
      activeColor: Colors.black12,
      onChanged: (bool value) {
        // This is called when the user toggles the switch.
        setState(() {
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
