import 'package:camera/camera.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter/utils.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ShareFoodPage extends StatefulWidget {
  // TODO: Now, i just .popUntil(), which causes the page to go back to Snap, But i want to reset all the way back to Home Page
  XFile? image;

  ShareFoodPage({Key? key, required this.image}) : super(key: key);

  @override
  State<ShareFoodPage> createState() => _ShareFoodPageState();
}

class _ShareFoodPageState extends State<ShareFoodPage> {
  final captionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Snap and Log"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            width: 200,
            decoration: widget.image == null
                ? null
                : BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      image: XFileImage(widget.image!),
                    ),
                  ),
          ),

          // Caption
          TextFormField(
            maxLines: 4,
            minLines: 4,
            controller: captionController,
            decoration: const InputDecoration(
              labelText: "Write a caption...",
              alignLabelWithHint: true,
            ),
          ),
          Utils.createVerticalSpace(52),
          Utils.createTitleMedium("Rate your meal", context),
          // Utils.createVerticalSpace(16),
          // Rate your meal
          Center(
            child: RatingBar.builder(
              itemSize: MediaQuery.of(context).size.width / 7,
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                print(rating);
              },
            ),
          ),

          // Submit buttons
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: Theme.of(context)
                              .elevatedButtonTheme
                              .style
                              ?.copyWith(
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.white),
                                textStyle: MaterialStatePropertyAll(
                                  TextStyle(
                                      foreground: Paint()
                                        ..color =
                                            Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            Utils.showSnackBar(
                                "Not implemented yet!"); // TODO: Implement sharing
                          },
                          child: Text("Add to diary"),
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            Utils.showSnackBar(
                                "Not implemented yet!"); // TODO: Implement adding to diary
                          },
                          child: Text("Share!"),
                        ),
                      ),
                    ],
                  ),
                ),
                Utils.createVerticalSpace(52),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
