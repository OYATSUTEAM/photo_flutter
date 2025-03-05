import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/services/upload_service.dart';
import 'package:photo_sharing_app/ui/camera/captures_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/ui/camera/profile_camera.dart';
import 'package:photo_sharing_app/ui/myProfile/myProfile.dart';
import '../../data/global.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final AuthServices authServices = locator.get();
UploadService uploadService = UploadService();
// BannerScreen bannerScreen = BannerScreen();

class ProfileSetScreen extends StatefulWidget {
  const ProfileSetScreen({super.key});
  @override
  _ProfileSetScreenState createState() => _ProfileSetScreenState();
}

class _ProfileSetScreenState extends State<ProfileSetScreen> {
  String uid = globalData.myUid;
  String email = globalData.myEmail;
  String username = globalData.myUserName;
  String name = globalData.myName;
  bool? shouldDelete = false;
  String myProfileImage = '';
  String imageURL = '';

  String editProfileImage = '';
  XFile? _selectImage;
  UploadTask? uploadTask;
  final List<String> allFileListPath = [];
  bool isLoading = true;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _setUpInitial();
    _loadImages();
    super.initState();
  }

  Future<void> _setUpInitial() async {
    imageCache.clear();
    imageCache.clearLiveImages();

    setState(() {
      email = globalData.myEmail;
      uid = globalData.myUid;
      username = globalData.myUserName;
      name = globalData.myName;
    });
  }

  Future<void> _loadImages() async {
    final directory = await getApplicationDocumentsDirectory();
    // final fetchedURL = await getEditProfileUrl(uid);

    setState(() {
      // imageURL = fetchedURL;
      // '${directory.path}/$uid/editProfileImage.jpg';

      editProfileImage = '${directory.path}/$uid/editProfileImage.jpg';
      myProfileImage = '${directory.path}/$uid/myProfileImage.jpg';
      _selectImage = XFile(editProfileImage);
      isLoading = false;
    });
  }

  Future<void> deleteFileWithConfirmation(
      BuildContext context, File file) async {
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
        if (await file.exists()) {
          await file.delete();
          setState(() {
            allFileListPath.remove(file.path);
          });
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ProfileCameraScreen()));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ファイルの削除に失敗しました: $e')),
        );
      }
    }
  }

  Future<void> deleteAllFileWithConfirmation(
    BuildContext context,
  ) async {
    shouldDelete = await showDialog<bool>(
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
                child: const Text('キャンセル')),
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
        for (final File file in allFileList) {
          if (await file.exists()) {
            await file.delete(); // Delete each file
            filesToRemove.add(file); // Mark the file for removal
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ファイルが存在しません。')),
            );
          }
        }
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
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    try {
      // Main UI rendering
      return SafeArea(
          child: Scaffold(
        // backgroundColor: Colors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildImageTile(editProfileImage),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    onPressed: () async {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const Center(
                                child: CircularProgressIndicator());
                          });
                      final directory =
                          await getApplicationDocumentsDirectory();
                      myProfileImage =
                          '${directory.path}/$uid/editProfileImage.jpg';
                      await uploadFile(uid, 'profileImage', myProfileImage);
                      // File imageFile = File(myProfileImage);
                      // await imageFile
                      //     .copy('${directory.path}/${uid}/myProfileImage.jpg');

                      if (mounted) {
                        // await firestore.collection('Users').doc('$uid').update({
                        //   'comments-${widget.whichProfile}': FieldValue.delete(),
                        // });

                        deleteAllFileWithConfirmation(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => MyProfileScreen()),
                        );
                      }
                    },
                    icon: Icon(Icons.check, size: 40)),
                IconButton(
                    onPressed: () {
                      deleteFileWithConfirmation(
                          context, File(editProfileImage));
                    },
                    icon: Icon(Icons.delete))
              ],
            )
          ],
        ),
        // ],
        // ),
      ));
    } catch (e) {
      // Fallback UI in case of error
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Error loading image: $e',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }
  }

  Widget _buildImageTile(String filePath) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(),
              child: Image.file(File(filePath))

              // Image.network(imageURL, fit: BoxFit.cover,
              //     loadingBuilder: (context, child, loadingProgress) {
              //   if (loadingProgress == null) return child;
              //   return Center(
              //     child: CircularProgressIndicator(),
              //   );
              // }, errorBuilder: (context, error, stackTrace) {
              //   return Center(
              //     child: Icon(Icons.error, color: Colors.red),
              //   );
              // }),
              )
        ]);
  }
}
