import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/other/other_service.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/ui/camera/profile_camera.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../data/global.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
final User? user = _auth.currentUser;

class ProfilePreviewScreen extends StatefulWidget {
  const ProfilePreviewScreen({super.key});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

OtherService otherService = OtherService();

ScrollController _scrollController = ScrollController();

final AuthServices authServices = locator.get();
String? imageURL;
String mainURL = globalData.profileURL;
bool isCommenting = false; // To track if comment input is visible
List<Map<String, dynamic>> comments = [];
List<dynamic> like = [], dislike = [], favourite = [];
String email = 'default@gmail.com',
    name = 'ローディング...',
    username = 'ローディング...',
    uid = 'default';
var otherUser, otherUserName;

class _PreviewScreenState extends State<ProfilePreviewScreen> {
  @override
  void initState() {
    _setUpProfilePreview();
    _getProfileImageURL();
    super.initState();
  }

  Future<void> _setUpProfilePreview() async {
    setState(() {
      uid = globalData.myUid;
      email = globalData.myEmail;
      name = globalData.myName;
      username = globalData.myUserName;
    });
  }

  Future<void> _getProfileImageURL() async {
    final fetchedURL = await getMainProfileUrl(uid);
    setState(() {
      imageURL = fetchedURL;
    });
  }

  @override
  void dispose() {
    // Add any cleanup logic here if needed in the future.
    super.dispose();
  }

  Future<void> shareInternetImage(String imageUrl, String fileName) async {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes).then((_) async {
          await Share.shareXFiles([XFile(filePath)],
              text: 'Check out this image!');
        });

        // await
      } else {
        print('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sharing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      // Main UI rendering
      return SafeArea(
          child: Scaffold(
              // backgroundColor: Colors.black,
              appBar: AppBar(
                toolbarHeight: 36,
                title: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 60,
                          child: MyMenuButton(() => setState(() {
                                _setUpProfilePreview();
                              })))
                    ],
                  ),
                ),
              ),
              body: SafeArea(
                  child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.97,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            color: Colors.grey,
                                            image: DecorationImage(
                                                image: NetworkImage(imageURL!),
                                                fit: BoxFit.cover)))
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.favorite_outline),
                                    SizedBox(width: 20),
                                    Text(favourite.length.toString()),
                                  ],
                                ),
                                isCommenting
                                    ? SizedBox(
                                        height: 0,
                                      )
                                    : SizedBox(
                                        height: 50,
                                      ),
                                if (isCommenting)
                                  Container(
                                    height: 300,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                    ),
                                    child: ListView.builder(
                                      itemCount: comments.length,
                                      itemBuilder: (context, index) {
                                        var comment = comments[index];
                                        var timestamp = comment['timestamp'];
                                        var otherUid = comment['uid'];

                                        String formattedTimestamp = timestamp !=
                                                null
                                            ? timestamp
                                                .toDate()
                                                .toString() // Format the timestamp if not null
                                            : 'No timestamp available';

                                        return FutureBuilder(
                                          future: authServices
                                              .getDocument(otherUid),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return ListTile(
                                                title: Text(comment['comment']),
                                                subtitle: Text(
                                                    'ユーザー: ローディング...'), ///////////////////loading
                                                trailing:
                                                    Text(formattedTimestamp),
                                              );
                                            }
                                            if (snapshot.hasError) {
                                              return ListTile(
                                                title: Text(comment['comment']),
                                                subtitle: Text(
                                                    'ユーザー: Error loading user'),
                                                trailing:
                                                    Text(formattedTimestamp),
                                              );
                                            }

                                            var otherUser = snapshot.data;
                                            var otherUserName =
                                                otherUser?['username'] ??
                                                    'Unknown User';

                                            return ListTile(
                                              title: Text(comment['comment']),
                                              subtitle:
                                                  Text('ユーザー: $otherUserName'),
                                              trailing:
                                                  Text(formattedTimestamp),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Positioned(
                              bottom: -6,
                              left: 0, // Adjusted to account for padding
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Icons.undo))),
                          Positioned(
                              bottom: -6,
                              right: 0, // Adjusted to account for padding
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProfileCameraScreen()));
                                  },
                                  icon: Icon(Icons.camera_alt))),
                        ],
                      )))));
    } catch (e) {
      // Fallback UI in case of error
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

  Widget MyMenuButton(VoidCallback delete) {
    return SizedBox(
        width: 55,
        child: PopupMenuButton<String>(
          // color: Color.fromRGBO(0, 0, 0, 0),
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
            if (value == "delete") {
              // await deleteProfile(widget.uid, widget.whichProfile);
              setState(() {
                delete();
              });
              print("Report selected");
            } else if (value == "share") {
              // await shareInternetImage(imageURL!, widget.whichProfile);
              Future.delayed(Duration(seconds: 1), () {
                // Navigator.of(context).pop();
              });
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                value: "delete",
                child: Container(
                  alignment: Alignment.center,
                  width: 100, // Set width here
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(149, 0, 0, 0),

                    // Background color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: Text(
                    "削除",
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
              PopupMenuItem(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                value: "share",
                child: Container(
                  alignment: Alignment.center,
                  width: 100, // Set width here
                  padding: EdgeInsets.symmetric(
                      vertical: 6, horizontal: 0), // Add padding
                  decoration: BoxDecoration(
                    color:
                        const Color.fromARGB(149, 5, 4, 4), // Background color

                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: Text(
                    "投稿",
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              )
            ];
          },
        ));
  }
}
