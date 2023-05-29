import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
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
    return Scaffold(
        body: Center(
      child: Column(
        children: [
          _image == null
              ? Container(
                  height: 500.0,
                  width: 500.0,
                )
              : Image.file(
                  File(_image!.path),
                  height: 500.0,
                  width: 500.0,
                ), // Image display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    getImage(true);
                  },
                  icon: Icon(Icons.camera_alt)),
              SizedBox(
                width: 10.0,
              ),
              IconButton(
                  onPressed: () {
                    getImage(false);
                  },
                  icon: Icon(Icons.insert_drive_file))
            ],
          ),
          ElevatedButton.icon(
              onPressed: AnalyseAndLogCallBack,
              icon: Icon(Icons.edit, size: 24),
              label: const Text(
                "Log it",
              )
          ),
        ],
      ),
    ),
    );
  }


  Future AnalyseAndLogCallBack() async {
    try{
      // TODO: Integrate a food recognition model
      if (_image == null) throw ArgumentError("No image selected");
      throw UnimplementedError("Has not been implemented");

    }
    on UnimplementedError catch (e) {
      Utils.showSnackBar(e.message);
    }
    on ArgumentError catch (e) {
      Utils.showSnackBar(e.message);
    }

  }
}
