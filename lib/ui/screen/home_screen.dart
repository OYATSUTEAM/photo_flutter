import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/services/other/other_service.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/ui/camera/post_camera_screen.dart';
import 'package:photo_sharing_app/ui/camera/post_preview_screen.dart';
import 'package:photo_sharing_app/ui/myProfile/myProfile.dart';
import 'package:photo_sharing_app/ui/myProfile/profile_preview_screen.dart';
import 'package:photo_sharing_app/ui/other/other_profile_preview_screen.dart';
import 'package:photo_sharing_app/ui/screen/search_user_screen.dart';
import 'package:photo_sharing_app/widgets/my_drawer.dart';

final AuthServices _authServices = locator.get();
ProfileServices profileServices = ProfileServices();
late String fromWhere;

String myProfileURL = "";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

OtherService otherService = OtherService();

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  String email = 'default@gmail.com',
      name = 'ローディング...',
      username = 'ローディング...',
      uid = 'default';
  List<Map<String, dynamic>> recommendedOtherUsers = [];
  List<Map<String, dynamic>> recommendedFollowUsers = [];
  final List<String> allFileListPath = [];
  final List<String> allCacheFileListPath = [];
  @override
  void initState() {
    final currentUser = _authServices.getCurrentuser();
    uid = currentUser!.uid;
    email = currentUser.email!;
    _setProfileInitiate();
    _setUpInit();
    super.initState();
  }

  Future<void> _loadImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final subDir = Directory('${directory.path}/cache');
    final fileList = directory.listSync();
    final cacheFileList = subDir.listSync();
    allFileListPath
      ..clear()
      ..addAll(fileList
          .where((file) => file.path.endsWith('.jpg'))
          .map((e) => e.path)
          .toList())
      ..sort((a, b) => a.compareTo(b));

    allCacheFileListPath
      ..clear()
      ..addAll(cacheFileList
          .where((file) => file.path.endsWith('.jpg'))
          .map((e) => e.path)
          .toList())
      ..sort((a, b) => a.compareTo(b));

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _setUpInit() async {
    try {
      await _loadImages();
      final fetchedOtherFiles =
          await otherService.getRecentFilesFromAllUsers(uid);
      final fetchedFollowFiles = await otherService.getRecentFollowFiles(uid);
      Map<String, dynamic>? userDetail = await _authServices.getUserDetail(uid);

      if (mounted) if (userDetail != null) {
        setState(() {
          username = userDetail['username'];
          name = userDetail['name'];
          recommendedOtherUsers = fetchedOtherFiles;
          recommendedFollowUsers = fetchedFollowFiles;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _setProfileInitiate() async {
    try {
      myProfileURL = await profileServices.getMainProfileUrl(uid);

      final profileRef =
          FirebaseStorage.instance.ref().child("images/$uid/mainProfileImage");
      final otherFileRef =
          FirebaseStorage.instance.ref().child("images/$uid/mainProfileImage");
      // print(
      //     '=============================current uid is $uid  ===========================');
      String fetchedUrl = await profileRef.getDownloadURL();
      print(
          '=============================current profile url is ${profileRef.getDownloadURL()}  ===========================');

      if (mounted) {
        setState(() {
          myProfileURL = fetchedUrl; // Update the state after fetching URL
        });
      }
    } catch (e) {
      print('$e=======================  this is called');
      if (mounted) {
        setState(() {});
      }
      return null;
    }
  }

  Future<void> deleteAllFileWithConfirm(
    BuildContext context,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('削除の確認'),
          content: const Text('すでに撮影した画像を本当に削除しますか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // User pressed Cancel
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // User pressed Delete
              },
              child: const Text('削除', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        setState(() {});
        List<File> filesToRemove = [];
        showDialog(
            context: context,
            builder: (context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            });
        for (final String filePath in allFileListPath) {
          File file = File(filePath);
          if (await file.exists()) {
            await file.delete(); // Delete each file
            filesToRemove.add(file); // Mark the file for removal
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ファイルが存在しません。')),
            );
          }
        }
        setState(() {});
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ファイルの削除に失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            // drawer: MyDrawer(email: email, uid: uid),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.grey,
              elevation: 0,
              title: const Text(
                "ホーム",
                style: TextStyle(fontSize: 20),
              ),
              centerTitle: true,
              toolbarHeight: 30,
            ),
            body: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.74,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Column(children: [
                                TextButton(
                                  child: Text(
                                    'おすすめ',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                  onPressed: () {
                                    _setProfileInitiate();
                                  },
                                ),
                                Expanded(
                                    child: ListView.builder(
                                  itemCount: recommendedOtherUsers.length,
                                  itemBuilder: (context, index) {
                                    final profileRef = FirebaseStorage.instance
                                        .ref()
                                        .child(
                                            "${recommendedOtherUsers[index]['fileRef'].fullPath}");

                                    return FutureBuilder<String>(
                                        future: profileRef.getDownloadURL(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                "Error: ${snapshot.error}");
                                          } else if (!snapshot.hasData) {
                                            return Text("No URL available");
                                          }
                                          final profileUrl = snapshot.data!;
                                          return InkWell(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          OtherProfilePreviewScreen(
                                                              whichProfile:
                                                                  recommendedOtherUsers[
                                                                              index]
                                                                          [
                                                                          'fileRef']
                                                                      .fullPath
                                                                      .split(
                                                                          '/')
                                                                      .last,
                                                              otherUid:
                                                                  recommendedOtherUsers[
                                                                          index]
                                                                      ['uid'])),
                                                );
                                              },
                                              child: Container(
                                                width: 100,
                                                height: 200,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5,
                                                    horizontal: 10),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0), // Ensure the image fits within the rounded corners
                                                  child: Image.network(
                                                    profileUrl,
                                                    fit: BoxFit
                                                        .cover, // Optionally you can use fit to control how the image fills the container
                                                  ),
                                                ),
                                              ));
                                        });
                                  },
                                ))
                              ])),
                              Expanded(
                                  child: Column(
                                children: [
                                  TextButton(
                                    child: Text(
                                      'フォロー中',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                    onPressed: () {
                                      _setProfileInitiate();
                                    },
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: recommendedFollowUsers.length,
                                      itemBuilder: (context, index) {
                                        final profileRef = FirebaseStorage
                                            .instance
                                            .ref()
                                            .child(
                                                "${recommendedFollowUsers[index]['fileRef'].fullPath}");

                                        return FutureBuilder<String>(
                                            future: profileRef.getDownloadURL(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                    "Error: ${snapshot.error}");
                                              } else if (!snapshot.hasData) {
                                                return Text("No URL available");
                                              }
                                              final profileUrl = snapshot.data!;
                                              return InkWell(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ProfilePreviewScreen(
                                                                whichProfile:
                                                                    recommendedFollowUsers[index]
                                                                            [
                                                                            'fileRef']
                                                                        .fullPath
                                                                        .split(
                                                                            '/')
                                                                        .last,
                                                                uid: recommendedFollowUsers[
                                                                        index]
                                                                    ['uid']),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 100,
                                                    height: 200,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5,
                                                            horizontal: 10),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0), // Ensure the image fits within the rounded corners
                                                      child: Image.network(
                                                        profileUrl,
                                                        fit: BoxFit
                                                            .cover, // Optionally you can use fit to control how the image fills the container
                                                      ),
                                                    ),
                                                  ));
                                            });
                                      },
                                    ),
                                  ),
                                ],
                              )),
                            ],
                          )),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              //========================================================  home button======================================
                              IconButton(
                                onPressed: () async {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => MyDrawer(
                                        email: email,
                                        uid: uid,
                                      ),
                                    ),
                                  );
                                },
                                iconSize: 38,
                                icon: const Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                  weight: 90,
                                ),
                              ),
                              //===============================================================post button======================================
                              IconButton(
                                  onPressed: () async {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        });
                                    // if (allCacheFileListPath.length > 0) {
                                    List<File> filesToRemove = [];

                                    for (final String filePath
                                        in allCacheFileListPath) {
                                      File file = File(filePath);
                                      if (await file.exists()) {
                                        await file.delete();
                                        filesToRemove.add(file);
                                      }
                                    }

                                    print(
                                        '---------${allCacheFileListPath.length}------------------------');
                                    // }
                                    // if(allCacheFileListPath.length ==0){

                                    Navigator.pop(context);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PostCameraScreen(isDelete : true)),
                                    );
                                    // }
                                    if (!mounted) return;
                                  },
                                  iconSize: 42,
                                  icon: const Icon(Icons.add,
                                      color: Colors.white)),
                              //=================================================== search button ============================================================
                              IconButton(
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
                                  // setState(() {});
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => SearchUser(),
                                    ),
                                  );
                                },
                                iconSize: 40,
                                icon: const Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                              ),
                              //=========================================== avatar button ======================================================

                              FloatingActionButton(
                                backgroundColor: Colors.transparent,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(myProfileURL),
                                  radius: 20,
                                ),
                                onPressed: () async {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      });
                                  _setProfileInitiate();
                                  // Navigator.pop(context);

                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return MyProfile();
                                      },
                                    ),
                                  );
                                },
                              ),

                              ///   transfer button
                            ],
                          )),
                    ],
                  )),
            )));
  }

  Widget RecommendedUsersTile(String imageURL, String whichProfile) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
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
        ],
      ),
    );
  }
}
