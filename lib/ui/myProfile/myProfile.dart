import 'package:flutter/material.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/theme/theme_manager.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/ui/camera/preview_screen.dart';
import 'package:photo_sharing_app/ui/myProfile/profile_preview_screen.dart';
import 'package:photo_sharing_app/ui/myProfile/myprofile_edit.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
final User? user = _auth.currentUser;

final AuthServices _authServices = locator.get();
final ProfileServices profileServices = ProfileServices();
bool isShowAll = true;
bool firstImage = false;

class MyProfile extends StatefulWidget {
  const MyProfile({
    super.key,
  });
  @override
  _MyProfile createState() => _MyProfile();
}

class _MyProfile extends State<MyProfile> {
  List<String> allFileListPath = [];
  List<String> list = <String>['public', 'private'];
  List<File> allFileList = [];
  String myMainProfileURL = profileServices.mainURL;

  String email = 'default@gmail.com',
      name = 'ローディング...',
      username = 'ローディング...',
      uid = 'default';
  final fetchedEmail = _authServices.getCurrentuser()!.email;
  final fetchedUid = _authServices.getCurrentuser()!.uid;
  bool isToggled = false;

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
    refreshAlreadyCapturedImages();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> toggleIcon(BuildContext context) async {
    setState(() {
      isToggled = !isToggled;
    });
  }

  Future<void> fetchURLs() async {
    final fetchedUrl = await profileServices.getMainProfileUrl(uid);

    if (mounted)
      setState(() {
        myMainProfileURL = fetchedUrl;
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

  refreshAlreadyCapturedImages() async {
    final directory = await getApplicationDocumentsDirectory();

    final fileList = directory.listSync();
    allFileListPath
      ..clear()
      ..addAll(fileList
          .where((file) => file.path.endsWith('.jpg'))
          .map((e) => e.path)
          .toList())
      ..sort((a, b) => a.compareTo(b));
  }

  Future<void> _setThisImage(String whichProfile) async {
    setIsShowAll(false, whichProfile);
    setState(() {
      if (whichProfile == 'firstProfileImage') {
        firstImage = true;
      } else if (whichProfile == 'secondProfileImage') {
        firstImage = false;
      } else if (whichProfile == 'thirdProfileImage') {
        firstImage = false;
      } else if (whichProfile == 'forthProfileImage') {
        firstImage = false;
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
          setState(() {
            // allFileListPath.remove(file.path);
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
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.62,
                    height: 36,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(username,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ))
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
                                whichProfile: 'myMainProfileURL')));
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
                      builder: (context) => ProfilePreviewScreen(
                          whichProfile: 'mainProfileImage', uid: uid),
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
          const SizedBox(height: 5),
          Text(name, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 10),
//================================================          my images         ===============================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5 - 10,
                      height: MediaQuery.of(context).size.height -
                          40 -
                          MediaQuery.of(context).size.width * 0.5 -
                          80,
                      child: SingleChildScrollView(
                        child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1, // Number of columns
                                    crossAxisSpacing: 2.0,
                                    mainAxisSpacing: 1.0, // Space between rows
                                    childAspectRatio: 0.7),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: latestImages.length,
                            itemBuilder: (context, index) {
                              return Container(
                                  child: _buildImageTile(latestImages,
                                      latestImages.length - index - 1, list));
                            }),
                      ))
                ],
              ),
              Column(
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5 - 10,
                      height: MediaQuery.of(context).size.height -
                          40 -
                          MediaQuery.of(context).size.width * 0.5 -
                          80,
                      child: SingleChildScrollView(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1, // Number of columns
                                  crossAxisSpacing: 1.0,
                                  mainAxisSpacing: 1.0, // Space between rows
                                  childAspectRatio: 0.7),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: oldestImages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              child: _buildImageTile(oldestImages, index, list),
                            );
                          },
                        ),
                      ))
                ],
              )
            ],
          ),
        ]),
      )),
    );
  }

  Widget _buildImageTile(List<String> filelist, int index, List<String> list) {
    String dropdownValue = list.first;

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
                image: FileImage(
                    File(filelist[index])), // Displaying image from file
                fit: BoxFit.cover,
              ),
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
              icon: Icon(isToggled ? Icons.lock_open : Icons.lock),
              color: Colors.green,
              onPressed: () {
                toggleIcon(context);
              },
            ),
          ),
        ]));
  }
}
