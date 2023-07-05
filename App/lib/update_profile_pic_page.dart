import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_first_flutter/setup_camera.dart';
import 'package:my_first_flutter/setup_page_4.dart';

class UpdateProfilePicPage extends StatefulWidget {
  const UpdateProfilePicPage({Key? key}) : super(key: key);

  @override
  State<UpdateProfilePicPage> createState() => _UpdateProfilePicPageState();
}

class _UpdateProfilePicPageState extends State<UpdateProfilePicPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update profile picture'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
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
                SetupCameraPage(cameras: value, fromUpdate: true))));
  }

  void getImageGalleryCallBack() async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => SetupPage4(
            image: image,
            fromCamera: false,
            fromUpdate: true
          ),
        ),
      );
    }
  }
}
