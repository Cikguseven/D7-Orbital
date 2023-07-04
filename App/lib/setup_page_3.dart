import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_first_flutter/setup_camera.dart';
import 'package:my_first_flutter/setup_page_4.dart';
import 'package:my_first_flutter/utils.dart';

import 'main.dart';
import 'user_data.dart';

class SetupPage3 extends StatefulWidget {
  final UserData user;

  const SetupPage3({Key? key, required this.user}) : super(key: key);

  @override
  State<SetupPage3> createState() => _SetupPage3();
}

class _SetupPage3 extends State<SetupPage3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 70),
            Utils.createTitleMedium("Add your profile picture", context),
            const SizedBox(height: 70),
            ElevatedButton.icon(
              onPressed: cameraCallBack,
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text('Take a picture'),
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all(
                    Size.fromWidth(MediaQuery.of(context).size.width * 0.7)),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: getImageGalleryCallBack,
              icon: const Icon(Icons.collections, color: Colors.white),
              label: const Text('Select from gallery'),
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all(
                    Size.fromWidth(MediaQuery.of(context).size.width * 0.7)),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                navigatorKey.currentState!.popUntil((route) => route.isFirst);
              },
              icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
              label: const Text('Back'),
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all(
                    Size.fromWidth(MediaQuery.of(context).size.width * 0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void cameraCallBack() async {
    await availableCameras().then((value) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                SetupCameraPage(user: widget.user, cameras: value))));
  }

  void getImageGalleryCallBack() async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => SetupPage4(
            user: widget.user,
            image: image,
          ),
        ),
      );
    }
  }
}
