import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'alert.dart';

class DisplayPicture extends StatelessWidget {
  DisplayPicture({Key? key, required this.image, required this.context})
      : super(key: key);
  final File image;
  final BuildContext context;
  uploadImage() async {
    var res = await http
        .post(Uri.parse('https://pcc.edu.pk/ws/file_upload.php'), body: {
      "image": image.readAsBytes().toString(),
      "name": image.path.split('/').last.toString()
    });
    if (res.statusCode != 200) {
      showAlert(
          bContext: context,
          title: "Error Uploading!",
          content: "Server Side Error.");
    } else {
      var result = jsonDecode(res.body);
      showAlert(bContext: context, title: "Done!", content: result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
              Color.fromRGBO(46, 25, 96, 1),
              Color.fromRGBO(93, 16, 73, 1)
            ])),
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            backgroundColor: Colors.transparent,
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: MediaQuery.of(context).size.width / 3,
                  backgroundImage: FileImage(image),
                  backgroundColor: Colors.transparent,
                ),
                Padding(
                  padding: EdgeInsets.all(30),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(0, 0, 0, 0.1),
                      padding:
                          EdgeInsets.symmetric(vertical: 30, horizontal: 40),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      "Upload Image",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    onPressed: () => {uploadImage()},
                  ),
                )
              ],
            ))));
  }
}
