import 'package:flutter/material.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/theme/theme_manager.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/ui/camera/preview_screen.dart';
import 'package:photo_sharing_app/ui/camera/profile_add_camera_screen.dart';
import 'package:photo_sharing_app/ui/myProfile/profile_preview_screen.dart';
import 'package:photo_sharing_app/ui/myProfile/myprofile_edit.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/global.dart';
import 'package:path/path.dart' as path;

FirebaseAuth _auth = FirebaseAuth.instance;
final User? user = _auth.currentUser;

final AuthServices authServices = locator.get();
final ProfileServices profileServices = ProfileServices();
bool isShowAll = true;
bool firstImage = false;

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});
  @override
  _MyProfileScreen createState() => _MyProfileScreen();
}

class _MyProfileScreen extends State<MyProfileScreen> {
  List<String> allFileListPath = [];
  List<String> list = <String>['public', 'private'];
  List<File> allFileList = [];
  String myMainProfileURL = profileServices.mainURL;
  String email = 'default@gmail.com',
      name = 'ローディング...',
      username = 'ローディング...',
      uid = 'default';
  bool isToggled = false;
  File? myProfileImage;
  final currentUser = authServices.getCurrentuser();
  bool switchResult = ThemeManager.readTheme();

  @override
  void initState() {
    super.initState();
    _setProfileInitiate();
    fetchURLs();
  }

  Future<void> _setProfileInitiate() async {
    refreshAlreadyCapturedImages();
    if (mounted) {
      setState(() {
        email = globalData.myEmail;
        uid = globalData.myUid;
        name = globalData.myName;
        username = globalData.myUserName;
      });
    }
  }

  Future<void> fetchURLs() async {
    final fetchedUrl = await profileServices.getMainProfileUrl(uid);
    if (mounted)
      setState(() {
        myMainProfileURL = fetchedUrl;
      });
  }

  refreshAlreadyCapturedImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final subDir = Directory('${directory.path}/$uid/profileImages');
    if (await subDir.exists()) {
      final fileList = subDir.listSync();
      allFileListPath
        ..clear()
        ..addAll(fileList
            .where((file) => file.path.endsWith('.jpg'))
            .map((e) => e.path)
            .toList())
        ..sort((a, b) => a.compareTo(b));
    }
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

  Future<void> deleteFileWithConfirmation(
      BuildContext context, String filePath) async {
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
        if (await File(filePath).exists()) {
          await File(filePath).delete();
          await profileServices.deleteThisImage(
              uid, path.basenameWithoutExtension(filePath));
          setState(() {
            refreshAlreadyCapturedImages();
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('ファイルは正常に削除されました！'),
              duration: const Duration(milliseconds: 600),
            ));
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ファイルの削除に失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    allFileListPath.sort((a, b) {
      DateTime aCreationTime = File(a).lastModifiedSync();
      DateTime bCreationTime = File(b).lastModifiedSync();
      return aCreationTime.compareTo(bCreationTime);
    });

    int midIndex = allFileListPath.length ~/ 2;
    List<String> oldestImages = allFileListPath.sublist(0, midIndex);
    List<String> latestImages = allFileListPath.sublist(midIndex);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 36,
        title: Container(
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Stack(children: [
// =========================================================================         username   ============================
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 36,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(username,
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white)),
                        ])),
                Positioned(
                    top: 0,
                    right: 0,
                    child: TextButton(
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            });
                        if (!mounted) return;
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => MyProfileEdit(
                                  whichImage: 'myProfileImage',
                                )));
                      },
                      child: Text(
                        '. . .',
                        style:
                            const TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ))
              ])),
        ),
      ),
      body: SafeArea(
          child: Padding(
              padding: EdgeInsets.all(5),
              child: SingleChildScrollView(
                child: Column(children: [
//=================================================     main profile image       =====================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => ProfilePreviewScreen(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(myMainProfileURL),
                          radius: MediaQuery.of(context).size.width * 0.25,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
//======================================================================     name    ======================================
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Stack(children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [
                              Spacer(), // Pushes the text to the center
                              Text(
                                username,
                                style: const TextStyle(
                                    fontSize: 22, color: Colors.white),
                              ),
                              Spacer(), // Pushes the button to the end
                            ],
                          ),
                        ),
//========================================================================       +     ======================
                        Positioned(
                          top: -6,
                          right: 0,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileAddCameraScreen(),
                                ),
                              );
                            },
                            child: Text(
                              '+',
                              style: const TextStyle(
                                  fontSize: 24, color: Colors.white),
                            ),
                          ),
                        )
                      ])),
                  const SizedBox(height: 10),
//================================================          my images         ===============================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 0.5 - 8,
                              height: MediaQuery.of(context).size.height -
                                  40 -
                                  MediaQuery.of(context).size.width * 0.5 -
                                  80,
                              child: SingleChildScrollView(
                                child: GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount:
                                                1, // Number of columns
                                            crossAxisSpacing: 1.0,
                                            mainAxisSpacing:
                                                1.0, // Space between rows
                                            childAspectRatio: 0.7),
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: latestImages.length,
                                    itemBuilder: (context, index) {
                                      return FutureBuilder<bool>(
                                          future:
                                              profileServices.getDirPathStatus(
                                                  uid,
                                                  path.basenameWithoutExtension(
                                                      latestImages[
                                                          latestImages.length -
                                                              index -
                                                              1])),
                                          builder: (context, snapshot) {
                                            // if (snapshot.connectionState ==
                                            //     ConnectionState.waiting) {
                                            //   return CircularProgressIndicator(); // Show loading indicator while waiting
                                            // }
                                            if (snapshot.hasError) {
                                              return Text(
                                                  "Error loading status"); // Handle errors
                                            }

                                            bool status =
                                                snapshot.data ?? false;
                                            return Container(
                                                child: _buildImageTile(
                                                    latestImages,
                                                    latestImages.length -
                                                        index -
                                                        1,
                                                    status));
                                          });
                                    }),
                              ))
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 0.5 - 8,
                              height: MediaQuery.of(context).size.height -
                                  40 -
                                  MediaQuery.of(context).size.width * 0.5 -
                                  80,
                              child: SingleChildScrollView(
                                  child: GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount:
                                                  1, // Number of columns
                                              crossAxisSpacing: 1.0,
                                              mainAxisSpacing: 1.0,
                                              childAspectRatio: 0.7),
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: oldestImages.length,
                                      itemBuilder: (context, index) {
                                        return FutureBuilder<bool>(
                                          future:
                                              profileServices.getDirPathStatus(
                                                  uid,
                                                  path.basenameWithoutExtension(
                                                      oldestImages[index])),
                                          builder: (context, snapshot) {
                                            // if (snapshot.connectionState ==
                                            //     ConnectionState.waiting) {
                                            //   return CircularProgressIndicator(); // Show loading indicator while waiting
                                            // }
                                            if (snapshot.hasError) {
                                              return Text(
                                                  "Error loading status"); // Handle errors
                                            }

                                            bool status =
                                                snapshot.data ?? false;
                                            return Container(
                                              child: _buildImageTile(
                                                  oldestImages, index, status),
                                            );
                                          },
                                        );
                                      })))
                        ],
                      )
                    ],
                  ),
                ]),
              ))),
    );
  }

  Widget _buildImageTile(List<String> filelist, int index, bool status) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PreviewScreen(
                imageFile: File(filelist[index]),
              ),
            ),
          );
        },
        child: Stack(children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                  image: FileImage(File(filelist[index])), fit: BoxFit.cover),
            ),
          ),
          Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    deleteFileWithConfirmation(context, filelist[index]);
                  })),
          Positioned(
              bottom: 0,
              right: 0,
              child: IconButton(
                  icon: Icon(status ? Icons.lock_open : Icons.lock),
                  color: Colors.green,
                  onPressed: () async {
                    await profileServices.publicThisImage(
                        uid,
                        path.basenameWithoutExtension(filelist[index]),
                        !status);
                    setState(() {
                      _setProfileInitiate();
                    });
                  }))
        ]));
  }
}
