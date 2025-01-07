import 'package:flutter/material.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/theme/theme_manager.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/ui/myProfile/profile_preview_screen.dart';
import 'package:photo_sharing_app/ui/myProfile/myprofile_edit.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
final User? user = _auth.currentUser;

final AuthServices _authServices = locator.get();
final ProfileServices profileServices = ProfileServices();
bool isShowAll = true;
bool firstImage = false,
    secondImage = false,
    thirdImage = false,
    forthImage = false;

class MyProfile extends StatefulWidget {
  const MyProfile({
    super.key,
  });
  @override
  _MyProfile createState() => _MyProfile();
}

class _MyProfile extends State<MyProfile> {
  String myMainProfileURL = profileServices.mainURL;
  String myFirstProfileURL = '';
  String mySecondProfileURL = '';
  String myThirdProfileURL = '';
  String myForthProfileURL = '';
  String email = 'default@gmail.com',
      name = 'ローディング...',
      username = 'ローディング...',
      uid = 'default';
  final fetchedEmail = _authServices.getCurrentuser()!.email;
  final fetchedUid = _authServices.getCurrentuser()!.uid;

  // File? _imageFile;
  File? myProfileImage;
  final currentUser = _authServices.getCurrentuser();
  bool switchResult = ThemeManager.readTheme();

  @override
  void initState() {
    super.initState();
    getCurrentUserUID();
    _setProfileInitiate();
    fetchURLs();
    fetchUsername();
  }

  void getCurrentUserUID() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
        email = user.email!;
      });
    }
  }

  Future<void> _setProfileInitiate() async {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> fetchURLs() async {
    final fetchedUrl = await profileServices.getMainProfileUrl(uid);
    final fetchedUrl1 = await profileServices.getFirstProfileUrl(uid);
    final fetchedUrl2 = await profileServices.getSecondProfileUrl(uid);
    final fetchedUrl3 = await profileServices.getThirdProfileUrl(uid);
    final fetchedUrl4 = await profileServices.getForthProfileUrl(uid);
    if (mounted)
      setState(() {
        myMainProfileURL = fetchedUrl;
        myFirstProfileURL = fetchedUrl1;
        mySecondProfileURL = fetchedUrl2;
        myThirdProfileURL = fetchedUrl3;
        myForthProfileURL = fetchedUrl4;
      });
  }

  Future<void> fetchUsername() async {
    try {
      final fetchedUid = _authServices.getCurrentuser()!.uid;

      Map<String, dynamic>? user =
          await _authServices.getUserDetail(fetchedUid);

      setState(() {
        username = user?['username'];
        name = user?['name'];
      });
    } catch (e) {
      if (mounted)
        setState(() {
          username = "ユーザー名の取得エラー";
          name = "ユーザー名の取得エラー";
        });
      debugPrint("ユーザー名の取得エラー: $e");
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
        await profileServices.deleteProfile(uid, whichProfile);
      } catch (e) {
        if (e.toString().contains('object-not-found')) {
          print("File does not exist.");
        } else {
          print("An error occurred while deleting the file: $e");
        }
      }
    }
  }

  Future<void> _setThisImage(String whichProfile) async {
    setIsShowAll(false, whichProfile);
    setState(() {
      if (whichProfile == 'firstProfileImage') {
        firstImage = true;
        secondImage = false;
        thirdImage = false;
        forthImage = false;
      } else if (whichProfile == 'secondProfileImage') {
        firstImage = false;
        secondImage = true;
        thirdImage = false;
        forthImage = false;
      } else if (whichProfile == 'thirdProfileImage') {
        firstImage = false;
        secondImage = false;
        thirdImage = true;
        forthImage = false;
      } else if (whichProfile == 'forthProfileImage') {
        firstImage = false;
        secondImage = false;
        thirdImage = false;
        forthImage = true;
      }
    });
  }

  Future<void> setIsShowAll(bool value, String whichProfile) async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      isShowAll = value;
    });

    if (user != null) {
      final userDoc =
          FirebaseFirestore.instance.collection("Users").doc(user.uid);
      try {
        await userDoc.set({"isShowAll": value}, SetOptions(merge: true));
        await userDoc
            .set({"whichIsDisplayed": whichProfile}, SetOptions(merge: true));
        print("isShowAll updated to $value for user ${user.uid}");
      } catch (e) {
        print("Error updating isShowAll: $e");
      }
    } else {
      print("No authenticated user found.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 36,
        title: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
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
              SizedBox(
                  width: 50,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: -10, vertical: 2)),
                    onPressed: () async {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          });
                      if (!mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => MyProfileEdit(
                            whichProfile: 'myMainProfileURL',
                          ),
                        ),
                      );
                    },
                    child: Text(
                      '. . .',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ))
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
                    //=========================================================================================      main profile image      =====================================
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => ProfilePreviewScreen(
                            whichProfile: 'mainProfileImage',
                            uid: uid,
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(myMainProfileURL),
                      radius: MediaQuery.of(context).size.width * 0.25,
                    ),
                  ),

                  const SizedBox(height: 10), // Spacing between image and name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 26,
                    ),
                  ),
                  SizedBox(
                    height: 10,
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
                                    height: MediaQuery.of(context).size.height *
                                        0.35,
                                    child: ProfileImageTile(
                                        myFirstProfileURL,
                                        'firstProfileImage',
                                        () => setState(() {
                                              fetchURLs();
                                            })),
                                  ),
                                if (isShowAll || secondImage)
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.43,
                                    height: MediaQuery.of(context).size.height *
                                        0.35,
                                    child: ProfileImageTile(
                                        mySecondProfileURL,
                                        'secondProfileImage',
                                        () => setState(() {
                                              fetchURLs();
                                            })),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
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
                                        myThirdProfileURL,
                                        'thirdProfileImage',
                                        () => setState(() {
                                              fetchURLs();
                                            })),
                                  ),
                                if (isShowAll || forthImage)
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.43,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.35,
                                      child: ProfileImageTile(
                                          myForthProfileURL,
                                          'forthProfileImage',
                                          () => setState(() {
                                                fetchURLs();
                                              }))),
                              ],
                            ),
                          ),
                        ],
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget ProfileImageTile(
      String imageURL, String whichProfile, VoidCallback delete) {
    return GestureDetector(
      onTap: () {
        print('sdfsdfsdf');
        print(
            '$whichProfile!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!which profile');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ProfilePreviewScreen(
              whichProfile: whichProfile,
              uid: uid,
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
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: () => isShowAll == false
                  ? setIsShowAll(true, whichProfile)
                  : _setThisImage(whichProfile),
              icon: Icon(
                Icons.content_copy,
                color: Colors.black,
                size: 25,
              ),
            ),
          ),
          Positioned(
            top: 0, // Adjusted to account for padding
            left: 0, // Adjusted to account for padding
            child: IconButton(
              onPressed: () {
                deleteFileWithConfirmation(context, whichProfile);
                delete();
              },
              icon: Icon(
                Icons.delete_forever,
                color: Colors.black,
                size: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
