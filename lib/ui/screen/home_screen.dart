import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/services/other/other_service.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/ui/camera/post_camera.dart';
import 'package:photo_sharing_app/ui/myProfile/myProfile.dart';
import 'package:photo_sharing_app/ui/other/other_profile_preview_screen.dart';
import 'package:photo_sharing_app/ui/screen/search_user_screen.dart';
import 'package:photo_sharing_app/widgets/my_drawer.dart';
import '../../data/global.dart';

final AuthServices authServices = locator.get();
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
  bool isAccountPublic = false;
  List<String>? recommendedOtherUsers;
  List<String>? recommendedFollowUsers;
  final List<String> allFileListPath = [];
  final List<String> allCacheFileListPath = [];
  @override
  void initState() {
    _setUpInit();
    super.initState();
  }

  Future<void> _setUpInit() async {
    try {
      final currentUser = await authServices.getCurrentuser();
      uid = currentUser!.uid;
      email = currentUser.email!;
      Map<String, dynamic>? userDetail = await authServices.getUserDetail(uid);
      name = userDetail!['name'];
      username = userDetail['username'];
      isAccountPublic = userDetail['public'];
      globalData.updateUser(email, uid, username, name);
      globalData.updataPublic(isAccountPublic);
      final fetchedFollowFiles = await otherService.getRecentFollowImages(uid);
      final fetchedOtherFiles = await otherService.getRecentImageUrls();

      if (mounted && userDetail != null) {
        setState(() {
          recommendedOtherUsers = fetchedOtherFiles;
          recommendedFollowUsers = fetchedFollowFiles;
        });
      }
    } catch (e) {
      print(e);
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
            )
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
            // appBar: AppBar(
            //   backgroundColor: Colors.transparent,
            //   foregroundColor: Colors.grey,
            //   elevation: 0,
            //   title: TextButton(
            //     child: Text("ホーム", style: TextStyle(fontSize: 20)),
            //     onPressed: () {
            //       setState(() {
            //         _setUpInit();
            //       });
            //     },
            //   ),
            //   centerTitle: true,
            //   toolbarHeight: 30,
            // ),
            body: SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.74,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Column(children: [
                            Text('おすすめ'),
                            Expanded(
                              child: recommendedOtherUsers == null
                                  ? Center(child: CircularProgressIndicator())
                                  : GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1,
                                        crossAxisSpacing: 1.0,
                                        mainAxisSpacing: 1.0,
                                        childAspectRatio: 0.7,
                                      ),
                                      itemCount: recommendedOtherUsers!.length,
                                      itemBuilder: (context, index) {
                                        return _buildImageTile(
                                            recommendedOtherUsers!, index);
                                      },
                                    ),
                            ),
                          ]),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text('フォロー'),
                              Expanded(
                                child: recommendedFollowUsers == null
                                    ? Center(
                                        child:
                                            CircularProgressIndicator()) // Show loader until data arrives
                                    : GridView.builder(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 1,
                                          crossAxisSpacing: 1.0,
                                          mainAxisSpacing: 1.0,
                                          childAspectRatio: 0.7,
                                        ),
                                        itemCount:
                                            recommendedFollowUsers!.length,
                                        itemBuilder: (context, index) {
                                          return _buildImageTile(
                                              recommendedFollowUsers!, index);
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ])),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
//===================================================                             home button======================================

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
                      // _show();
                    },
                    iconSize: 38,
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      weight: 90,
                    ),
                  ),

//===================================================                             post button======================================

                  IconButton(
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            });
                        List<File> filesToRemove = [];

                        for (final String filePath in allCacheFileListPath) {
                          File file = File(filePath);
                          if (await file.exists()) {
                            await file.delete();
                            filesToRemove.add(file);
                          }
                        }
                        globalData.updatePostText('');
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                PostCameraScreen(isDelete: true)));
                        if (!mounted) return;
                      },
                      iconSize: 42,
                      icon: const Icon(Icons.add, color: Colors.white)),

//===================================================                             search button ===================================

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
//===================================================                             avatar button ===================================

                  IconButton(
                    icon: CircleAvatar(
                      backgroundImage: AssetImage('assets/avatar.png'),
                      // radius: 20,
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          });

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) {
                            return MyProfileScreen();
                          },
                        ),
                      );
                    },
                  ),
                ],
                // )
              )
            ],
          )),
    )));
  }

  Widget _buildImageTile(List<String> imageFiles, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtherProfilePreviewScreen(
              imageURL: imageFiles[index],
            ),
          ),
        );
      },
      child: Padding(
          padding: EdgeInsets.all(2),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: NetworkImage(imageFiles[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Text('')
              // Positioned(
              //   bottom: 0,
              //   right: 0,
              //   child: IconButton(
              //     icon: Icon(Icons.lock), // Change the icon if needed
              //     color: Colors.green,
              //     onPressed: () async {
              //       // Implement lock/unlock functionality
              //     },
              //   ),
              // ),
            ],
          )),
    );
  }
}
