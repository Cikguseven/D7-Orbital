import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_first_flutter/user_class.dart';
import 'package:my_first_flutter/utils.dart';

class SnapperWidget extends StatefulWidget {
  final UserData user;

  SnapperWidget({Key? key, required this.user})
      : super(key: key); // TODO: this is infact not required

  @override
  State<SnapperWidget> createState() => _SnapperWidgetState();
}

class InvertedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.width * 4 / 5, // magic numbers
          height: size.width * 4 / 5))
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) =>
      true; // TODO: True for debug, set false for production
}

class _SnapperWidgetState extends State<SnapperWidget> {
  List<CameraDescription>? cameras;
  CameraController? cameraController;

  void startCamera() async {
    cameras = await availableCameras().then(
      (_cameras) {
        cameraController = CameraController(_cameras[0], ResolutionPreset.high,
            enableAudio: false)
          ..initialize().then(
            (_) {
              if (mounted) {
                print("Mounted");
                setState(() {}); // to refresh widget
              }
            },
          );
        return _cameras;
      },
    );
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    startCamera();
    // TODO: implement initState
    super.initState();
  }

  XFile? _image;

  Future<void> getImage(bool fromCamera) async {
    final ImagePicker picker = ImagePicker();
    XFile? image;
    if (fromCamera) {
      image = await picker.pickImage(source: ImageSource.camera);
    } else {
      image = await picker.pickImage(source: ImageSource.gallery);
    }
    setState(
      () {
        if (image == null) return;
        _image = image;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null) {
      print("Null");
      return const SizedBox();
    } else {
      // camera control and cameras are initialized
      print("Not null");
      return Scaffold(
          body: Stack(
        children: [
          CameraPreview(cameraController!),
          ClipPath(
            clipper: InvertedClipper(),
            child: Container(
              color: Colors.black54,
            ),
          )
        ],
      ));
    }
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text("Snap and Log"),
    //   ),
    //   body: Center(
    //     child: Column(
    //       children: [
    //         _image == null
    //             ? Container(
    //                 height: 500.0,
    //                 width: 500.0,
    //               )
    //             : Image.file(
    //                 File(_image!.path),
    //                 height: 500.0,
    //                 width: 500.0,
    //               ), // Image display
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             IconButton(
    //                 onPressed: () {
    //                   getImage(true);
    //                 },
    //                 icon: Icon(Icons.camera_alt)),
    //             SizedBox(
    //               width: 10.0,
    //             ),
    //             IconButton(
    //                 onPressed: () {
    //                   getImage(false);
    //                 },
    //                 icon: Icon(Icons.insert_drive_file))
    //           ],
    //         ),
    //         ElevatedButton.icon(
    //             onPressed: AnalyseAndLogCallBack,
    //             icon: Icon(Icons.edit, size: 24),
    //             label: const Text(
    //               "Log it",
    //             )),
    //       ],
    //     ),
    //   ),
    // );
  }

  Future AnalyseAndLogCallBack() async {
    try {
      // TODO: Integrate a food recognition model
      if (_image == null) throw ArgumentError("No image selected");
      throw UnimplementedError("Has not been implemented");
    } on UnimplementedError catch (e) {
      Utils.showSnackBar(e.message);
    } on ArgumentError catch (e) {
      Utils.showSnackBar(e.message);
    }
  }
}
