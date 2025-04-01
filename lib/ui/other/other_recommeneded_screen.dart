import 'package:flutter/material.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:photo_sharing_app/ui/other/other_profile_screen.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../../data/global.dart';

class OtherRecommendedScreen extends StatefulWidget {
  final String imageURL;
  final String otherUid;
  final String otherName;
  final String otherUserName;
  final String otherEmail;
  final String postText;

  const OtherRecommendedScreen(
      {required this.imageURL,
      required this.postText,
      required this.otherUid,
      required this.otherName,
      required this.otherUserName,
      required this.otherEmail});

  @override
  _OtherRecommendedScreenState createState() => _OtherRecommendedScreenState();
}

ProfileServices profileServices = ProfileServices();

final AuthServices authServices = locator.get();
String email = '', uid = '', username = '', name = '';
List<dynamic> like = [], dislike = [], favourite = [];

class _OtherRecommendedScreenState extends State<OtherRecommendedScreen> {
  ScrollController _scrollController = ScrollController();
  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    _setUpInit();
    super.initState();
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
        appBar: AppBar(
          centerTitle: true,
          title: Expanded(
              child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                OtherProfile(otherUid: widget.otherUid)));
                  },
                  child: Text(
                    widget.otherName,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20),
                  ))),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.97,
                    height: MediaQuery.of(context).size.height * 0.8,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.grey,
                        image: DecorationImage(
                            image: NetworkImage(widget.imageURL),
                            fit: BoxFit.cover)))),
            Expanded(
                child: Text(widget.postText, style: TextStyle(fontSize: 20)))
          ],
        ),
      ));
    } catch (e) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text('Error loading image: $e',
              style: const TextStyle(color: Colors.white, fontSize: 16)),
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
