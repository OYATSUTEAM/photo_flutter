import 'package:flutter/material.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/ui/other/other_profile_screen.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../../data/global.dart';

class OtherProfilePreviewScreen extends StatefulWidget {
  final String imageURL;

  const OtherProfilePreviewScreen({
    required this.imageURL,
  });

  @override
  _OtherPreviewScreenState createState() => _OtherPreviewScreenState();
}

ProfileServices profileServices = ProfileServices();

final AuthServices authServices = locator.get();
String email = '', uid = '', username = '', name = '';
List<dynamic> like = [], dislike = [], favourite = [];

class _OtherPreviewScreenState extends State<OtherProfilePreviewScreen> {
  ScrollController _scrollController = ScrollController();
  TextEditingController _commentController = TextEditingController();
  bool isCommenting = false; // To track if comment input is visible
  String commentText = ""; // To store the comment text
  List<Map<String, dynamic>> comments = [];

  @override
  void initState() {
    _setUpInit();
    super.initState();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        400,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _setUpInit() async {
    if (mounted) {
      setState(() {
        email = globalData.myEmail;
        uid = globalData.myUid;
        username = globalData.myUserName;
        name = globalData.myName;
      });

      // }
    }
  }

  Future<void> shareInternetImage(String imageUrl, String fileName) async {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        await Share.shareXFiles([XFile(filePath)],
            text: 'Check out this image!');
      } else {
        print('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sharing image: $e');
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return SafeArea(
          child: Scaffold(
              body: Column(children: [
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                  // Navigator.of(context).pushReplacement(MaterialPageRoute(
                  //     builder: (context) =>
                  //         OtherProfile(otherUid: globalData.otherUid)));
                }),
            Expanded(
                child: Text(
              globalData.otherName,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 20),
            )),
            // IconButton(

            MyMenuButton()
          ],
        ),
        SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: MediaQuery.of(context).size.width * 0.97,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.grey,
                    image: DecorationImage(
                        image: NetworkImage(widget.imageURL),
                        fit: BoxFit.cover))),
          ],
        ),
      ])));
    } catch (e) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'Error loading image: $e',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }
  }

  Widget MyMenuButton() {
    return SizedBox(
        width: 55,
        child: PopupMenuButton<String>(
          offset: Offset(0, 30),
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          menuPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          position: PopupMenuPosition.over,
          child: TextButton(
            onPressed: null,
            child: Text(
              ". . .",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          constraints: BoxConstraints(
            maxHeight: 100,
            maxWidth: 80,
          ),
          onSelected: (value) async {
            if (value == "report") {
              setState(() {});
              print("Report selected");
            } else if (value == "share") {
              await shareInternetImage(widget.imageURL, 'widget.whichProfile');
              Future.delayed(Duration(seconds: 1), () {
                Navigator.pop(context);
              });
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                value: "report",
                child: Container(
                  alignment: Alignment.center,
                  width: 100,
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: Text("報告", style: TextStyle(fontSize: 15)),
                ),
              ),
              PopupMenuItem(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                value: "share",
                child: Container(
                  alignment: Alignment.center,
                  width: 100,
                  padding: EdgeInsets.symmetric(
                      vertical: 6, horizontal: 0), // Add padding
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: Text("投稿", style: TextStyle(fontSize: 15)),
                ),
              )
            ];
          },
        ));
  }
}
