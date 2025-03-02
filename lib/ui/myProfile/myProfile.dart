import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/theme/theme_manager.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/ui/camera/preview_screen.dart';
import 'package:photo_sharing_app/ui/camera/profile_add_camera.dart';
import 'package:photo_sharing_app/ui/myProfile/myprofile_preview_screen.dart';
import 'package:photo_sharing_app/ui/myProfile/myprofile_edit.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
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
  // ListResult listResult = [] as ListResult;
  @override
  void initState() {
    super.initState();
    _setProfileInitiate();
    fetchURLs();
  }

  Future<void> _setProfileInitiate() async {
    setState(() {
      email = globalData.myEmail;
      uid = globalData.myUid;
      name = globalData.myName;
      username = globalData.myUserName;
    });
  }

  Future<void> fetchURLs() async {
    final fetchedUrl = await getMainProfileUrl(uid);
    if (mounted)
      setState(() {
        myMainProfileURL = fetchedUrl;
        print(fetchedUrl);
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

        if (mounted) {
          showDialog(
              context: context,
              builder: (context) {
                return const Center(child: CircularProgressIndicator());
              });
        }

        setState(() {
          _setProfileInitiate();
        });
        if (mounted) {
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
                          Navigator.pop(context);
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                                  builder: (context) => MyProfileEdit(
                                        whichImage: 'myProfileImage',
                                      )));
                        },
                        child: Text(
                          '. . .',
                          style: const TextStyle(
                              fontSize: 24, color: Colors.white),
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
//===========================================================                         main profile image       =====================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfilePreviewScreen(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          backgroundImage:
                              CachedNetworkImageProvider(myMainProfileURL),
                          radius: MediaQuery.of(context).size.width * 0.25,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
//============================================================                       name    ======================================
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Stack(children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [
                              Spacer(), // Pushes the text to the center
                              Text(name,
                                  style: TextStyle(
                                      fontSize: 22, color: Colors.white)),
                              Spacer(), // Pushes the button to the end
                            ],
                          ),
                        ),
//========================================================================       +     ======================
                        Positioned(
                          top: -6,
                          right: 0,
                          child: IconButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProfileAddCameraScreen(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.add)),
                        ),
                      ])),
                  const SizedBox(height: 10),
//================================================          my images         ===============================================

                  FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
                      future: getImageNames(uid),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text("Error: ${snapshot.error}"));
                        }

                        if (!snapshot.hasData ||
                            snapshot.data!['latest']!.isEmpty) {
                          return Center(child: Text(""));
                        }

                        final imagesData = snapshot.data!;
                        final latestImages = imagesData["latest"]!;
                        final otherImages = imagesData["others"]!;
                        return Row(children: [
                          SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 0.5 - 6,
                              height: MediaQuery.of(context).size.height -
                                  40 -
                                  MediaQuery.of(context).size.width * 0.5 -
                                  80,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...latestImages.map((image) {
                                      return FutureBuilder<String>(
                                          future: FirebaseStorage.instance
                                              .ref(
                                                  'images/$uid/profileImages/${image['name']}')
                                              .getDownloadURL(),
                                          builder: (context, urlSnapshot) {
                                            if (!urlSnapshot.hasData)
                                              return Center(
                                                  child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  CircularProgressIndicator()
                                                ],
                                              ));
                                            return _buildImageTile(
                                                urlSnapshot.data!,
                                                image['name'],
                                                image['status']);
                                          });
                                    }).toList(),
                                  ],
                                ),
                              )),
                          SizedBox(width: 2),
                          SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 0.5 - 6,
                              height: MediaQuery.of(context).size.height -
                                  40 -
                                  MediaQuery.of(context).size.width * 0.5 -
                                  80,
                              child: SingleChildScrollView(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...otherImages.map((image) {
                                    return FutureBuilder<String>(
                                        future: FirebaseStorage.instance
                                            .ref(
                                                'images/$uid/profileImages/${image['name']}')
                                            .getDownloadURL(),
                                        builder: (context, urlSnapshot) {
                                          if (!urlSnapshot.hasData)
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          return _buildImageTile(
                                              urlSnapshot.data!,
                                              image['name'],
                                              image['status']);
                                        });
                                  }).toList(),
                                ],
                              )))
                        ]);
                      }),
                ])))));
  }

  Widget _buildImageTile(String imageURL, String imageName, String status) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PreviewScreen(imageURL: imageURL),
            ),
          );
        },
        child: Stack(children: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 1),
              child: CachedNetworkImage(
                width: MediaQuery.of(context).size.width * 0.5 - 6,
                fit: BoxFit.fitWidth,
                height: MediaQuery.of(context).size.height * 0.33,
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
                  icon: Icon(status == 'true' ? Icons.lock_open : Icons.lock),
                  color: Colors.green,
                  onPressed: () async {
                    await saveOrUpdateImage(
                        uid, imageName, status == 'true' ? 'false' : 'true');
                    setState(() {
                      _setProfileInitiate();
                    });
                  }))
        ]));
  }
}
