import 'package:flutter/material.dart';
import 'package:testing/DI/service_locator.dart';
import 'package:testing/services/profile/profile_services.dart';
import 'package:testing/theme/theme_manager.dart';
import 'package:testing/services/auth/auth_service.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testing/ui/other/other_profile_preview_screen.dart';
import 'package:testing/widgets/othertile.dart';
import 'package:testing/services/other/other_service.dart';

class OtherProfile extends StatefulWidget {
  final String otherUid;
  const OtherProfile({super.key, required this.otherUid});

  @override
  _OtherProfile createState() => _OtherProfile();
}

FirebaseAuth _auth = FirebaseAuth.instance;
final AuthServices _authServices = locator.get();
final otherService = OtherService(locator.get(), locator.get());
ProfileServices profileServices = ProfileServices();

class _OtherProfile extends State<OtherProfile> {
  final User? user = _auth.currentUser;
  bool isShowAll = true;
  bool firstImage = false,
      secondImage = false,
      thirdImage = false,
      forthImage = false;
  String otherMainProfileURL = profileService.mainURL;
  String otherFirstProfileURL = profileService.firstURL;
  String otherSecondProfileURL = profileService.secondURL;
  String otherThirdProfileURL = profileService.thirdURL;
  String otherForthProfileURL = profileService.forthURL;
  String email = 'default@gmail.com',
      name = 'ローディング...',
      username = 'ローディング...',
      uid = 'default';
  // File? _imageFile;
  File? otherProfileImage;
  final currentUser = _authServices.getCurrentuser();
  bool switchResult = ThemeManager.readTheme();

  @override
  void initState() {
    super.initState();
    _setProfileInitiate();
    fetchUsername();
  }

  Future<void> _setProfileInitiate() async {
    String fetchedUrl = await profileService.getMainProfileUrl(widget.otherUid);
    String fetchedUrl1 =
        await profileService.getFirstProfileUrl(widget.otherUid);
    String fetchedUrl2 =
        await profileService.getSecondProfileUrl(widget.otherUid);
    String fetchedUrl3 =
        await profileService.getThirdProfileUrl(widget.otherUid);
    String fetchedUrl4 =
        await profileService.getForthProfileUrl(widget.otherUid);
    if (mounted) {
      setState(() {
        otherMainProfileURL = fetchedUrl;
        otherFirstProfileURL = fetchedUrl1;
        otherSecondProfileURL = fetchedUrl2;
        otherThirdProfileURL = fetchedUrl3;
        otherForthProfileURL = fetchedUrl4;
      });
    }
  }

  Future<void> fetchUsername() async {
    try {
      var user = await _authServices.getDocument(widget.otherUid);
      if (user != null) {
        setState(() {
          username = user['username'];
          name = user['name'];
        });
      }
    } catch (e) {
      // Handle any errors
      print('$e  this error is occured in other profile.');
      if (mounted)
        setState(() {
          username = "Error fetching username";
          name = "Error fetching username";
        });
      debugPrint("Error fetching username: $e");
    }
  }

  Future<void> deleteFileWithConfirmation(
      BuildContext context, String whichProfile) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('本当にこのファイルを削除しますか？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('キャンセル')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        final ref =
            FirebaseStorage.instance.ref().child("images/${whichProfile}");

        // Attempt to delete the file
        await ref.delete();
        print("File deleted successfully.");
      } catch (e) {
        if (e.toString().contains('object-not-found')) {
          print("File does not exist.");
        } else {
          print("An error occurred while deleting the file: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 36,
        title: Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.576,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )),
              MyMenuButton()
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(otherMainProfileURL),
                      radius: 76,
                    ),
                  ),

                  const SizedBox(height: 10), // Spacing between image and name
                  Text(
                    name ?? 'ローディング ...',
                    style: const TextStyle(
                      fontSize: 26,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            // padding: const EdgeInsets.all(16.0),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 60)),
                        onPressed: () {
                          otherService.followOther(widget.otherUid);
                        },
                        child: Text(
                          "フォロー", // follow
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        )),
                  ),
                  SingleChildScrollView(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 6.5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (isShowAll || firstImage)
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.43,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.35,
                                      child: ProfileImageTile(
                                          otherFirstProfileURL,
                                          'firstProfileImage')),
                                if (isShowAll || secondImage)
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.43,
                                    height: MediaQuery.of(context).size.height *
                                        0.35,
                                    child: ProfileImageTile(
                                        otherSecondProfileURL,
                                        'secondProfileImage'),
                                  )
                              ],
                            ),
                          ),

                          const SizedBox(
                              height: 10), // Spacing between image and name

                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 6.5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (isShowAll || thirdImage)
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.43,
                                    height: MediaQuery.of(context).size.height *
                                        0.35,
                                    child: ProfileImageTile(
                                        otherThirdProfileURL,
                                        'thirdProfileImage'),
                                  ),
                                if (isShowAll || forthImage)
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.43,
                                    height: MediaQuery.of(context).size.height *
                                        0.35,
                                    child: ProfileImageTile(
                                        otherForthProfileURL,
                                        'forthProfileImage'),
                                  )
                              ],
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            )
            // Username at the top-center
          ],
        ),
      ),
    );
  }

  Widget ProfileImageTile(String imageURL, String whichProfile) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtherProfilePreviewScreen(
              whichProfile: whichProfile,
              otherUid: widget.otherUid,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.grey,
                image: DecorationImage(
                  image: NetworkImage(imageURL),
                  fit: BoxFit.cover,
                )),
          ),
        ],
      ),
    );
  }
}

class MyMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 55,
        child: PopupMenuButton<String>(
          color: const Color.fromARGB(0, 180, 171, 171),
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
          onSelected: (value) {
            if (value == "report") {
              print("Report selected");
            } else if (value == "block") {
              otherService.blockOther(uid!);
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Text('このユーザーをブロックしました'),
                    );
                  });
              Future.delayed(Duration(seconds: 1), () {
                Navigator.of(context).pop();
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
                  width: 100, // Set width here
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                        150, 180, 171, 171), // Background color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: Text(
                    "報告",
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
              PopupMenuItem(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                value: "block",
                child: Container(
                  alignment: Alignment.center,
                  width: 100, // Set width here
                  padding: EdgeInsets.symmetric(
                      vertical: 6, horizontal: 0), // Add padding
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                        150, 180, 171, 171), // Background color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: Text(
                    "ブロック",
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              )
            ];
          },
        ));
  }
}
