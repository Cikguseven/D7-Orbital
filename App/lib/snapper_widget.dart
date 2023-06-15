import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:my_first_flutter/CheckFoodPage.dart';
import 'package:my_first_flutter/FoodDataClass.dart';
import 'package:my_first_flutter/ManualFoodSelectPage.dart';
import 'package:my_first_flutter/scanner_overlay.dart';
import 'package:my_first_flutter/user_class.dart';
import 'package:my_first_flutter/utils.dart';

class SnapperWidget extends StatefulWidget {
  UserData user;

  SnapperWidget({Key? key, required this.user})
      : super(key: key); // TODO: this is infact not required

  @override
  State<SnapperWidget> createState() => _SnapperWidgetState();
}

class _SnapperWidgetState extends State<SnapperWidget> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  // List<CameraDescription>? cameras;
  // CameraController? cameraController;

  void startCamera() async {
    // TODO: Note. Camera library causes alog of dequeue buffer error messages
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    if (cameras == null)
      print("NULL CAMERA");
    else
      print("HOOO");
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      cameras.first,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    startCamera();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snap and Log'),
        centerTitle: true,
      ),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Stack(
              fit: StackFit.expand,
              // Might make the picture unusually elongated
              children: [
                CameraPreview(_controller),
                QRScannerOverlay(overlayColour: Colors.grey),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                        ),
                        SizedBox(
                          height: null,
                          width: MediaQuery.of(context).size.width / 2,
                          child: ElevatedButton.icon(
                            onPressed: AnalyseAndLogCallBack,
                            icon: Icon(Icons.edit, size: 24),
                            label: const Text(
                              "Log it",
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        IconButton(
                          color: Theme.of(context).primaryColor,
                          onPressed: GetImageGalleryCallBack,
                          icon: Icon(Icons.insert_drive_file),
                        ),
                      ],
                    ),
                    Utils.createVerticalSpace(16),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: ElevatedButton(
                        onPressed: ManualEntryCallBack,
                        child: const Text(
                          "Manual Entry",
                        ),
                      ),
                    ),
                    Utils.createVerticalSpace(16),
                  ],
                )
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future AnalyseAndLogCallBack() async {
    // Take the Picture in a try / catch block. If anything goes wrong,
    // catch the error.
    try {
      // TODO: Integrate a food recognition model
      // if (_image == null) throw ArgumentError("No image selected");
      // throw UnimplementedError("Has not been implemented");

      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      // Attempt to take a picture and get the file `image`
      // where it was saved.
      final image = await _controller.takePicture();

      if (!mounted) return;

      // If the picture was taken, display it on a new screen.
      checkFood(image);
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
      Utils.showSnackBar(e.toString());
    }
  }

  ManualEntryCallBack() async {
    FoodData selectedFoodData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const ManualFoodSelectPage(),
      ),
    );
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckFoodPage(image: null, fd: selectedFoodData),
      ),
    );
  }

  GetImageGalleryCallBack() async {
    final ImagePicker picker = ImagePicker();
    XFile? image;
    image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    checkFood(image);
  }

  void checkFood(XFile img) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) =>
            CheckFoodPage(image: img, fd: FoodData.NONE),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
