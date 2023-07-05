import 'package:flutter/material.dart';
import 'home_page.dart';
import 'me_page.dart';
import 'setup_page_1.dart';
import 'snapper_widget.dart';
import 'user_data.dart';
import 'utils.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  static final List<String> idToMap = ['Home', 'Snap', 'Me'];
  Map<String, dynamic> screenNameToWidgetMap = {
    'Home': (UserData userData) => HomeWidget(user: userData),
    'Snap': (UserData userData) => SnapperWidget(user: userData),
    'Me': (UserData userData) => MePage(user: userData),
  };

  int selectedScreenIdx = 0;
  String selectedScreenName = idToMap[0];

  @override
  Widget build(BuildContext context) {
    // print('APP');
    return Scaffold(
      body: StreamBuilder(
        stream: Stream.fromFuture(Utils.getUserData()),
        builder: (BuildContext context, user) {
          if (user.data == UserData.newUser) {
            // print('new user');
            return const SetupPage1();
          } else {
            // print(user.data);
            if (user.data == null) {
              // print('Null userdata');
              return const Scaffold();
            }
            // print('Not null userdata');
            return Scaffold(
              body: screenNameToWidgetMap[selectedScreenName](user.data),
              bottomNavigationBar: BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.restaurant_menu_rounded),
                    label: 'Snap',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Me',
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
