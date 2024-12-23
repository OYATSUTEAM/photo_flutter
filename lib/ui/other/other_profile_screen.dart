import 'package:flutter/material.dart';
import 'package:testing/DI/service_locator.dart';
import 'package:testing/services/profile/profile_services.dart';
import 'package:testing/theme/theme_manager.dart';
import 'package:testing/services/auth/auth_service.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testing/ui/other/other_profile_preview_screen.dart';
import 'package:testing/ui/other/report_screen.dart';
import 'package:testing/services/other/other_service.dart';

enum Options { option1, option2, option3 }

class OtherProfile extends StatefulWidget {
  final String otherUid;
  const OtherProfile({super.key, required this.otherUid});

  @override
  _OtherProfile createState() => _OtherProfile();
}

OtherService otherService = OtherService();

FirebaseAuth _auth = FirebaseAuth.instance;
final AuthServices _authServices = locator.get();
// final otherService = OtherService(locator.get(), locator.get());
ProfileServices profileServices = ProfileServices();

class _OtherProfile extends State<OtherProfile> {
  bool isLoading = true;
  final User? user = _auth.currentUser;
  String whichProfileShow = 'showAll';
  String otherMainProfileURL = profileServices.mainURL;
  String otherFirstProfileURL = profileServices.firstURL;
  String otherSecondProfileURL = profileServices.secondURL;
  String otherThirdProfileURL = profileServices.thirdURL;
  String otherForthProfileURL = profileServices.forthURL;
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
    final fetchedIsShowAll =
        await profileServices.profileShowAll(widget.otherUid);
    String fetchedUrl =
        await profileServices.getMainProfileUrl(widget.otherUid);
    String fetchedUrl1 =
        await profileServices.getFirstProfileUrl(widget.otherUid);
    String fetchedUrl2 =
        await profileServices.getSecondProfileUrl(widget.otherUid);
    String fetchedUrl3 =
        await profileServices.getThirdProfileUrl(widget.otherUid);
    String fetchedUrl4 =
        await profileServices.getForthProfileUrl(widget.otherUid);
    if (mounted) {
      setState(() {
        whichProfileShow = fetchedIsShowAll;
        otherMainProfileURL = fetchedUrl;
        otherFirstProfileURL = fetchedUrl1;
        otherSecondProfileURL = fetchedUrl2;
        otherThirdProfileURL = fetchedUrl3;
        otherForthProfileURL = fetchedUrl4;
        isLoading = false;
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
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      // drawer: ReportScreen(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 36,
        title: SizedBox(
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
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => OtherProfilePreviewScreen(
                            whichProfile: 'mainProfileImage',
                            otherUid: widget.otherUid,
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(otherMainProfileURL),
                      radius: MediaQuery.of(context).size.width * 0.25,
                    ),
                  ),

                  const SizedBox(height: 5), // Spacing between image and name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 26,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 60)),
                        onPressed: () {
                          otherService.followOther(widget.otherUid).then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('お客様は「${otherUsername}」をフォローしました。')),
                            );
                          });
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
                                if (whichProfileShow == 'firstProfileImage' ||
                                    whichProfileShow == 'showAll')
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.43,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.35,
                                      child: ProfileImageTile(
                                          otherFirstProfileURL,
                                          'firstProfileImage')),
                                if (whichProfileShow == 'secondProfileImage' ||
                                    whichProfileShow == 'showAll')
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
                                if (whichProfileShow == 'thirdProfileImage' ||
                                    whichProfileShow == 'showAll')
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.43,
                                    height: MediaQuery.of(context).size.height *
                                        0.35,
                                    child: ProfileImageTile(
                                        otherThirdProfileURL,
                                        'thirdProfileImage'),
                                  ),
                                if (whichProfileShow == 'forthProfileImage' ||
                                    whichProfileShow == 'showAll')
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
// }

// _OtherProfile _otherProfile = _OtherProfile();

// class MyMenuButton extends StatefulWidget {
//   @override
//   _MyMenuButtonStatus createState() => _MyMenuButtonStatus();
// }

// class _MyMenuButtonStatus extends State<MyMenuButton> {
  TextEditingController spamController = TextEditingController();
  TextEditingController sexController = TextEditingController();
  TextEditingController otherHaressmentController = TextEditingController();
  TextEditingController scamController = TextEditingController();
  TextEditingController otherController = TextEditingController();
  TextEditingController impersonationController = TextEditingController();

  Widget MyMenuButton() {
    // return GestureDetector(

    // @override
    // Widget build(BuildContext context) {
    return SizedBox(
        width: 55,
        child: PopupMenuButton<String>(
          color: const Color.fromARGB(0, 180, 171, 171),
          offset: Offset(0, 30),
          child: TextButton(
            onPressed: null,
            child: Text(
              ". . .",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          constraints: BoxConstraints(maxHeight: 100, maxWidth: 80),
          onSelected: (value) async {
            if (value == "report") {
              // if (_otherProfile.widget != null) {
              showModalBottomSheet(
                context: context,
                scrollControlDisabledMaxHeightRatio: 0.9,
                builder: (context) {
                  return ReportScreen(otherUid: widget.otherUid);
                },
              );
              // }
            } else if (value == "block") {
              await otherService.blockThisUser(widget.otherUid);
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Text('このユーザーをブロックしました'),
                    );
                  });
              Future.delayed(Duration(seconds: 1), () {
                if (mounted) {
                  Navigator.pop(context);
                }
              });
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                  height: 20,
                  value: "report",
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("報告", style: TextStyle(fontSize: 10)),
                        ]),
                  )),
              PopupMenuItem(
                  height: 20,
                  value: "block",
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("ブロック", style: TextStyle(fontSize: 10)),
                        ],
                      )))
            ];
          },
        ));
  }
}
