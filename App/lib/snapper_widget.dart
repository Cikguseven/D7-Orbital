import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:my_first_flutter/check_food_page.dart';
import 'package:my_first_flutter/config/config.dart' as config;
import 'package:my_first_flutter/food_data.dart';
import 'package:my_first_flutter/manual_food_select_page.dart';
import 'package:my_first_flutter/scanner_overlay.dart';
import 'package:my_first_flutter/user_data.dart';
import 'package:my_first_flutter/utils.dart';
import 'package:universal_io/io.dart' as i;
import 'package:uuid/uuid.dart';

import 'classifier.dart';

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

  Future<void> startCamera() async {
    final cameras = availableCameras();
    cameras.then((cams) {
      _controller = CameraController(
        // Get a specific camera from the list of available cameras.
        cams.first,
        // Define the resolution to use.
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _controller.initialize();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await startCamera();
      setState(() {});
    });
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
      body: StreamBuilder(
        stream: Stream.fromFuture(_initializeControllerFuture),
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
        builder: (context) => CheckFoodPage(
          image: null,
          fd: selectedFoodData,
          user: widget.user,
          postID: id,
          imageURL:
              "https://firebasestorage.googleapis.com/v0/b/d7orbital-13611.appspot.com/o/ezgif-3-c4210ba1cd.jpg?alt=media&token=ff2c7484-9fdf-4fe0-9b6c-c1eca6f36092",
        ),
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

  void checkFood(XFile? image) async {
    if (image == null) return;
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

    // Load AI classifier and obtain prediction of food from image
    Classifier? classifier = await Classifier.loadWith(
        labelsFileName: 'assets/labels.txt',
        modelFileName: 'food-classifier.tflite');
    img.Image imageInput = img.decodeImage(File(image.path).readAsBytesSync())!;
    String? foodItem = classifier?.predict(imageInput);

    // Nutritionix api to query nutritional information of predicted food.
    if (foodItem != null) {
      Uri nutritionix =
          Uri.https('trackapi.nutritionix.com', '/v2/natural/nutrients');
      String query = jsonEncode({"query": foodItem});
      Response nutritionInfo = await http.post(
        nutritionix,
        headers: {
          "Content-Type": "application/json",
          "x-app-id": config.nutritionixAppID,
          "x-app-key": config.nutritionixAppKey
        },
        body: query,
      );

      if (nutritionInfo.statusCode == 200) {
        Map<String, dynamic> nutritionixJson = jsonDecode(nutritionInfo.body);
        predictedFood = FoodData(
          name: foodItem,
          energy: nutritionixJson['foods'][0]['nf_calories'].toInt(),
          protein: nutritionixJson['foods'][0]['nf_protein'].toDouble(),
          fats: nutritionixJson['foods'][0]['nf_total_fat'].toDouble(),
          carbs:
              nutritionixJson['foods'][0]['nf_total_carbohydrate'].toDouble(),
          sugar: nutritionixJson['foods'][0]['nf_sugars'].toDouble(),
        );
      }
    }

    Navigator.pop(context); // remove spinner

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => CheckFoodPage(
            image: image,
            fd: predictedFood,
            user: widget.user,
            postID: postID,
            imageURL: imageURL),
      ),
    );
  }
}
