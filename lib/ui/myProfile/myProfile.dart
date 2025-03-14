import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/theme/theme_manager.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/ui/myProfile/myprofile_preview_screen.dart';
import 'package:photo_sharing_app/ui/myProfile/myprofile_edit.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_sharing_app/ui/screen/home_screen.dart';
import '../../data/global.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
final User? user = _auth.currentUser;

final AuthServices authServices = locator.get();
final ProfileServices profileServices = ProfileServices();

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});
  @override
  _MyProfileScreen createState() => _MyProfileScreen();
}

class _MyProfileScreen extends State<MyProfileScreen> {
  bool isShowAll = true;
  List<String> allFileListPath = [];
  List<String> list = <String>['public', 'private'];
  List<File> allFileList = [];
  String myMainProfileURL = mainURL;
  List<Reference> firstHalf = [];
  List<Reference> secondHalf = [];

  String email = 'default@gmail.com',
      name = 'ローディング...',
      username = 'ローディング...',
      uid = 'default';
  bool isToggled = false;
  String myProfileImagePath = '';
  File? myProfileImage;
  bool switchResult = ThemeManager.readTheme();
  @override
  void initState() {
    super.initState();
    _setProfileInitiate();
    fetchURLs();
  }

  Future<void> _setProfileInitiate() async {
    while (globalData.myEmail == 'default@gmail.com' ||
        globalData.myUid == '1234567890') {
      await Future.delayed(Duration(milliseconds: 100));
    }
    if (mounted)
      setState(() {
        email = globalData.myEmail;
        uid = globalData.myUid;
        name = globalData.myName;
        username = globalData.myUserName;
      });
  }

  Future<void> fetchURLs() async {
    while (globalData.myEmail == 'default@gmail.com' ||
        globalData.myUid == '1234567890') {
      await Future.delayed(Duration(milliseconds: 100));
    }
    final fetchedUrl = await getMainProfileUrl(uid);
    if (mounted)
      setState(() {
        myMainProfileURL = fetchedUrl;
      });
  }

  Future<void> deleteFileWithConfirmation(
      BuildContext context, String imageName) async {
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
        await removeImage(uid, imageName);
        await deleteProfile(uid, imageName);
        if (mounted) {
          showDialog(
              context: context,
              builder: (context) {
                return const Center(child: CircularProgressIndicator());
              });
          setState(() {
            _setProfileInitiate();
          });
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('ファイルの削除に失敗しました: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: SafeArea(
                child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Column(children: [
                      const SizedBox(height: 10),
//===========================================================                         customized app bar       =====================================

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen()));
                              }),
                          Expanded(
                              child: Text(
                            username,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 20),
                          )),
                          IconButton(
                              onPressed: () async {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    });
                                if (!mounted) return;
                                Navigator.pop(context);
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => MyProfileEdit(
                                            whichImage: 'myProfileImage')));
                              },
                              icon: Icon(
                                Icons.border_color_rounded,
                                size: 20,
                              ))
                        ],
                      ),

//===========================================================                         main profile image       =====================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProfilePreviewScreen(
                                    imageURL: myMainProfileURL,
                                    imageName: 'profileImage'),
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundImage:
                                  CachedNetworkImageProvider(myMainProfileURL),
                              radius: MediaQuery.of(context).size.width * 0.26,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
//============================================================                       name    ======================================

                      Text(name, style: TextStyle(fontSize: 30)),

                      const SizedBox(height: 10),
//================================================          my images         ===============================================
                      Expanded(
                          child: StreamBuilder<
                                  Map<String, List<Map<String, dynamic>>>>(
                              stream: getImageNames(uid),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text("Error: ${snapshot.error}"));
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data?['latest'] == null ||
                                    snapshot.data!['latest']!.isEmpty) {
                                  return Center(child: Text(""));
                                }

                                final imagesData = snapshot.data!;
                                final latestImages = imagesData["latest"] ?? [];
                                final otherImages = imagesData["others"] ?? [];

                                return Row(children: [
                                  Expanded(
                                      child: ListView(
                                    children: latestImages.map((image) {
                                      return _buildImageTile(image['url'],
                                          image['name'], image['status']);
                                    }).toList(),
                                  )),
                                  SizedBox(width: 1),
                                  Expanded(
                                      child: ListView(
                                    children: otherImages.map((image) {
                                      return _buildImageTile(image['url'],
                                          image['name'], image['status']);
                                    }).toList(),
                                  )),
                                ]);
                              })),
                    ])))));
  }

  Widget _buildImageTile(String imageURL, String imageName, bool status) {
    print(imageURL);
    print('image url ==========================');
    return GestureDetector(
        onTap: () {
          // imageCache.clear();
          // imageCache.clearLiveImages();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProfilePreviewScreen(
                  imageURL: imageURL, imageName: imageName),
            ),
          );
        },
        child: Stack(children: [
          Padding(
              padding: EdgeInsets.all(1),
              child: CachedNetworkImage(
                width: MediaQuery.of(context).size.width * 0.5 - 6,
                fit: BoxFit.fitWidth,
                height: MediaQuery.of(context).size.height * 0.33 + 10,
                imageUrl: imageURL,
                errorWidget: (context, url, error) => Icon(Icons.error),
              )),
          Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    deleteFileWithConfirmation(context, imageName);
                    setState(() {
                      _setProfileInitiate();
                    });
                  })),
          Positioned(
              bottom: 0,
              right: 0,
              child: IconButton(
                  icon: Icon(status ? Icons.lock_open : Icons.lock),
                  color: Colors.green,
                  onPressed: () async {
                    await saveOrUpdateImage(uid, imageName, !status);
                    if (mounted) {
                      setState(() {
                        _setProfileInitiate();
                      });
                    }
                  }))
        ]));
  }
}
