import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_first_flutter/check_food_page.dart';
import 'package:my_first_flutter/food_data.dart';
import 'package:my_first_flutter/manual_food_select_page.dart';
import 'package:my_first_flutter/scanner_overlay.dart';
import 'package:my_first_flutter/user_data.dart';
import 'package:my_first_flutter/utils.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:universal_io/io.dart' as i;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:my_first_flutter/config/config.dart' as config;
import 'classifier.dart';
import 'package:image/image.dart' as img;


class SnapperWidget extends StatefulWidget {
  final UserData user;

  const SnapperWidget({Key? key, required this.user})
      : super(key: key); // TODO: this is infact not required

  @override
  State<SnapperWidget> createState() => _SnapperWidgetState();
}

class _SnapperWidgetState extends State<SnapperWidget> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  Uuid uuid = const Uuid();

  // List<CameraDescription>? cameras;
  // CameraController? cameraController;

  void startCamera() async {

    // TODO: Note. Camera library causes a lot of dequeue buffer error messages
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
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
        actions: [
          IconButton(
            color: Colors.grey,
            onPressed: getImageGalleryCallBack,
            icon: const Icon(Icons.insert_drive_file),
          ),
        ],
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
                const QRScannerOverlay(overlayColour: Colors.grey),
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
                            onPressed: analyseAndLogCallBack,
                            icon: const Icon(Icons.edit, size: 24),
                            label: const Text(
                              "Log it",
                            ),
                          ),
                        ),
                      ],
                    ),
                    Utils.createVerticalSpace(16),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: ElevatedButton(
                        onPressed: manualEntryCallBack,
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

  Future analyseAndLogCallBack() async {
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

  manualEntryCallBack() async {
    FoodData selectedFoodData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const ManualFoodSelectPage(),
      ),
    );
    if (!mounted) return;
    String id = uuid.v4();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckFoodPage(image: null, fd: selectedFoodData, user: widget.user, postID: id, imageURL: config.noImageAvailable,),
      ),
    );
  }

  getImageGalleryCallBack() async {
    final ImagePicker picker = ImagePicker();
    XFile? image;
    image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    checkFood(image);
  }

  void checkFood(XFile image) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    String postID = uuid.v4();
    FoodData predictedFood = FoodData.none;

    // Store image on Firebase
    String imagePath = 'posts/$postID.jpg';
    Reference ref = FirebaseStorage.instance.ref().child(imagePath);
    await ref.putFile(i.File(image.path));
    String imageURL = await ref.getDownloadURL();

    print(imageURL);

    Classifier? classifier = await Classifier.loadWith(labelsFileName: 'assets/labels.txt', modelFileName: 'food-classifier.tflite');
    img.Image imageInput = img.decodeImage(File(image.path).readAsBytesSync())!;
    String? foodItem = classifier?.predict(imageInput);

    // Query nutritionix database for nutritional information of predicted food.
    if (foodItem != null) {
      Uri nutritionix = Uri.https('trackapi.nutritionix.com', '/v2/natural/nutrients');
      String query = jsonEncode({"query": foodItem});
      Response nutritionInfo = await http.post(nutritionix,
        headers: {"Content-Type":"application/json", "x-app-id":config.nutritionixAppID, "x-app-key":config.nutritionixAppKey},
        body: query,);

      if (nutritionInfo.statusCode == 200) {
        print('d');

        Map<String, dynamic> nutritionixJson = jsonDecode(nutritionInfo.body);
        predictedFood = FoodData(
            name: foodItem,
            energy: nutritionixJson['nf_calories'],
            protein: nutritionixJson['nf_protein'],
            fats: nutritionixJson['nf_total_fat'],
            carbs: nutritionixJson['nf_total_carbohydrate'],
            sugar: nutritionixJson['nf_sugars']
        );
      } else {
        print('e1');

        throw Exception('Unable to predict food nutrition.');
      }
    } else {
      print('e2');

      throw Exception('Unable to predict food nutrition.');
    }
    print('f');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) =>
            CheckFoodPage(image: image, fd: predictedFood, user: widget.user, postID: postID, imageURL: imageURL),
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
