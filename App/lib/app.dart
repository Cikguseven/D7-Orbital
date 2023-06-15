import 'package:flutter/material.dart';
import 'package:my_first_flutter/home_widget.dart';
import 'package:my_first_flutter/user_class.dart';
import 'package:my_first_flutter/new_user_setup_page.dart';
import 'package:my_first_flutter/utils.dart';
import 'package:my_first_flutter/me_widget.dart';
import 'package:my_first_flutter/snapper_widget.dart';

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
    // TODO: Fix this, i dont think the scanner widget needs this data
    // but i have to put cause of the way i change screens
    "Me": (UserData userData) => MeWidget(user: userData),
  };

  int selectedScreenIdx = 0;
  String selectedScreenName = idToMap[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: Stream.fromFuture(Utils.getUserData()),
        builder: (BuildContext context, user) {
          if (user.data == UserData.newUser) {
            return const NewUserSetupPage();
          } else {
            if (user.data == null) {
              return const Scaffold();
            }
            // return CupertinoTabScaffold(
            //   tabBar: CupertinoTabBar(
            //     items: const [
            //       BottomNavigationBarItem(
            //         icon: Icon(Icons.home),
            //         label: "Home Page",
            //       ),
            //       BottomNavigationBarItem(
            //         icon: Icon(Icons.restaurant_menu_rounded),
            //         label: "Snap",
            //       ),
            //       BottomNavigationBarItem(
            //         icon: Icon(Icons.man_4_rounded),
            //         label: "Me",
            //       )
            //     ],
            //   ),
            //   tabBuilder: (BuildContext context, int index) {
            //     return CupertinoTabView(
            //       builder: (BuildContext context) {
            //         if (index == 0) { // TODO: obvious fix this
            //           return HomeWidget(user: user.data!);
            //         } else if (index == 1) {
            //           return SnapperWidget(user: user.data!);
            //         } else if (index == 2) {
            //           return MeWidget(user: user.data!);
            //         }
            //         return Scaffold();
            //       },
            //     );
            //   },
            // );
            return Scaffold(
              // appBar: AppBar(
              //   title: Text(idToMap[selectedScreenIdx]),
              // ),
              body: screenNameToWidgetMap[selectedScreenName](user.data),
              // TODO: Fix this, this one forces every screen to use this argument
              // invoke the screen to create, passing on the userdata
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
