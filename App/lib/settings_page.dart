import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter/update_weight_goal_page.dart';
import 'package:my_first_flutter/update_weight_page.dart';
import 'main.dart';
import 'utils.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  Widget placeholderPage() {
    return const Placeholder();
  }

  Widget updateWeightWidget() {
    return const UpdateWeightPage();
  }

  Widget updateWeightGoalWidget() {
    return const UpdateWeightGoalPage();
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
          child: Utils.createTitleSmall('Toggle Dark Mode', context),
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
                          Utils.createTitleMedium('Account Settings', context),
                    ),
                    settingsTile('Update weight', updateWeightWidget),
                    settingsTile('Update weight goal', updateWeightGoalWidget),
                    settingsTile('Change Email/Password', placeholderPage),
                    // settingsTile('Privacy Settings', placeholderPage),
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(16),
                      child: Utils.createTitleMedium('Preferences', context),
                    ),
                    // settingsTile('Notifications', placeholderPage),
                    darkModeTile(),
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(16),
                      child: Utils.createTitleMedium('Help', context),
                    ),
                    settingsTile('FAQ', placeholderPage),
                    settingsTile('Contact Us', placeholderPage),
                  ],
                ),
                // const SizedBox(height: 10),
                // Column(
                //   children: [
                //     Container(
                //       alignment: Alignment.centerLeft,
                //       padding: const EdgeInsets.all(16),
                //       child: Utils.createTitleMedium('About', context),
                //     ),
                //     settingsTile('Private Policy', placeholderPage),
                //     settingsTile('Terms of Use', placeholderPage),
                //   ],
                // ),
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
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, size: 24),
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
