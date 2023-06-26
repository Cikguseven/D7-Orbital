import 'package:flutter/material.dart';
import 'package:my_first_flutter/home_page.dart';
import 'package:my_first_flutter/me_page.dart';
import 'package:my_first_flutter/new_user_setup_page.dart';
import 'package:my_first_flutter/snapper_widget.dart';
import 'package:my_first_flutter/user_data.dart';
import 'package:my_first_flutter/utils.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  static final List<String> idToMap = ["Home", "Snap", "Me"];
  Map<String, dynamic> screenNameToWidgetMap = {
    "Home": (UserData userData) => HomeWidget(user: userData),
    "Snap": (UserData userData) => SnapperWidget(user: userData),
    "Me": (UserData userData) => MePage(user: userData),
  };

  int selectedScreenIdx = 0;
  String selectedScreenName = idToMap[0];

  @override
  Widget build(BuildContext context) {
    // print("APP");
    return Scaffold(
      body: StreamBuilder(
        stream: Stream.fromFuture(Utils.getUserData()),
        builder: (BuildContext context, user) {
          if (user.data == UserData.newUser) {
            // print("new user");
            return const NewUserSetupPage();
          } else {
            // print(user.data);
            if (user.data == null) {
              // print("Null userdata");
              return const Scaffold();
            }
            // print("Not null userdata");
            return Scaffold(
              body: screenNameToWidgetMap[selectedScreenName](user.data),
              bottomNavigationBar: BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.restaurant_menu_rounded),
                    label: "Snap",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.man_4_rounded),
                    label: "Me",
                  )
                ],
                currentIndex: selectedScreenIdx,
                onTap: (int index) {
                  setState(
                    () {
                      selectedScreenIdx = index;
                      selectedScreenName = idToMap[index];
                    },
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
