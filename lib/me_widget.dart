import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_first_flutter/user_class.dart';
import 'package:my_first_flutter/utils.dart';

class MeWidget extends StatelessWidget {
  UserData user;
  MeWidget({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(DateTime.now().year);
    print(Utils.stringToDateTime(user.birthday));
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("This page will contain statistics of the User. Testing CRUD..."),
            SizedBox(height: 10,),
            Text("Hey ${user.firstName}!"),
            SizedBox(height: 10,),
            Text("Age: You are ${DateTime.now().year - Utils.stringToDateTime(user.birthday).year} this year"),
            SizedBox(height: 10,),
            Text("Height: ${user.height} CM"),
            SizedBox(height: 10,),
            Text("Weight: ${user.weight} KG"),
            SizedBox(height: 10,),
            Text("Gender: ${user.gender}"),
            SizedBox(height: 10,),
            ElevatedButton.icon(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: Icon(Icons.arrow_back, size: 32),
              label: Text("Sign Out"),
            )
          ],
        ),
      ),
    );
  }
}
