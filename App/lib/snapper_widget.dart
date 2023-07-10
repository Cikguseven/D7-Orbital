import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:my_first_flutter/nutrition_data.dart';

import 'check_food_page.dart';
import 'classifier.dart';
import 'food_data.dart';
import 'manual_food_select_page.dart';
import 'scanner_overlay.dart';
import 'user_data.dart';
import 'utils.dart';

class SnapperWidget extends StatefulWidget {
  final UserData user;

  const SnapperWidget({Key? key, required this.user}) : super(key: key);

  @override
  State<SnapperWidget> createState() => _SnapperWidgetState();
}

class _SnapperWidgetState extends State<SnapperWidget> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  Future<void> startCamera() async {
    final cameras = availableCameras();
    await cameras.then((cams) {
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
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await startCamera();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Stream.fromFuture(_initializeControllerFuture),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Snap'),
                centerTitle: true,
                actions: [
                  IconButton(
                    color: Colors.white,
                    onPressed: getImageGalleryCallBack,
                    icon: const Icon(Icons.collections),
                  ),
                ],
              ),
              body: Stack(
                fit: StackFit.expand,
                // Might make the picture unusually elongated
                children: [
                  CameraPreview(_controller),
                  const QRScannerOverlay(overlayColour: Colors.grey),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: null,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: ElevatedButton.icon(
                          onPressed: analyseAndLogCallBack,
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Log it!',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: ElevatedButton(
                          onPressed: manualEntryCallBack,
                          child: const Text(
                            'Manual entry',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
              ),
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Future analyseAndLogCallBack() async {
    try {
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
      Utils.showSnackBar('Unable to read image');
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckFoodPage(
            image: "assets/NoFood.jpg",
            foodData: selectedFoodData,
            user: widget.user),
      ),
    );
  }

  void getImageGalleryCallBack() async {
    final ImagePicker picker = ImagePicker();
    XFile? image;
    image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) checkFood(image);
  }

  void checkFood(XFile? image) async {
    if (image == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    FoodData predictedFood = FoodData.none;

    // Load AI classifier and obtain prediction of food from image
    Classifier? classifier = await Classifier.loadWith(
        labelsFileName: 'assets/labels.txt',
        modelFileName: 'food-classifier.tflite');
    img.Image imageInput = img.decodeImage(File(image.path).readAsBytesSync())!;
    String? foodItem = classifier?.predict(imageInput);

    // Nutritionix database to query nutritional information of predicted food.
    if (foodItem != null) {
      FoodData? findFood = NutritionData.stallToFoodMap['General']?.firstWhere((fd) => fd.name == foodItem);
      if (findFood != null) {
        predictedFood = findFood;
      }
    }

    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => CheckFoodPage(
            image: image, foodData: predictedFood, user: widget.user),
      ),
    );
  }
}
