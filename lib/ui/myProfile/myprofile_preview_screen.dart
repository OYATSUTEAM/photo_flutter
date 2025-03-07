import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/other/other_service.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/ui/camera/profile_camera.dart';
import 'package:photo_sharing_app/ui/myProfile/myProfile.dart';
import 'package:photo_sharing_app/widgets/my_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../data/global.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
final User? user = _auth.currentUser;

class ProfilePreviewScreen extends StatefulWidget {
  final String imageURL;
  final String imageName;

  const ProfilePreviewScreen(
      {super.key, required this.imageURL, required this.imageName});

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

  @override
  void dispose() {
    // Add any cleanup logic here if needed in the future.
    super.dispose();
  }

  Future<void> shareInternetImage(String imageUrl) async {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));
      imageCache.clear();
      imageCache.clearLiveImages();
      int currentUnix = DateTime.now().millisecondsSinceEpoch;
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/$currentUnix';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes).then((_) async {
          await Share.shareXFiles([XFile(filePath)],
              text: 'Check out this image!');
        });
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
      return SafeArea(
          child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  Expanded(
                      child: Text(
                    username,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20),
                  )),
                  MyMenuButton(() => setState(() {
                        _setUpProfilePreview();
                      })),
                ],
              ),
              const SizedBox(height: 10),
              Row(
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
                              image:
                                  CachedNetworkImageProvider(widget.imageURL),
                              fit: BoxFit.cover)))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.undo)),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProfileCameraScreen()));
                      },
                      icon: Icon(Icons.camera_alt))
                ],
              )
            ],
          ),
        ),
      ));
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
          constraints: BoxConstraints(maxHeight: 100, maxWidth: 80),
          onSelected: (value) async {
            if (value == "delete") {
              await deleteProfile(globalData.myUid, widget.imageName);
              setState(() {
                delete();
              });
              print("Report selected");
            } else if (value == "share") {
              await shareInternetImage(widget.imageURL);
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
                    // Background color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: Text("削除", style: TextStyle(fontSize: 15)),
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
