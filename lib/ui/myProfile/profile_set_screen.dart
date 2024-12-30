import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/upload_service.dart';
import 'package:photo_sharing_app/ui/camera/captures_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/ui/myProfile/myProfile.dart';
import 'package:photo_sharing_app/ui/screen/banner_screen.dart';
import 'package:photo_sharing_app/widgets/imagetile.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final AuthServices _authServices = locator.get();
UploadService uploadService = UploadService();
BannerScreen bannerScreen = BannerScreen();

class ProfileSetScreen extends StatefulWidget {
  final String whichProfile;

  const ProfileSetScreen({required this.whichProfile, super.key});
  @override
  _ProfileSetScreenState createState() => _ProfileSetScreenState();
}

class _ProfileSetScreenState extends State<ProfileSetScreen> {
  String uid = 'default';
  String email = 'default@gmail.com';
  bool? shouldDelete = false;
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
    final fetchedUid = _authServices.getCurrentuser()!.uid;
    final fetchedEmail = _authServices.getCurrentuser()!.email;
    if (mounted)
      setState(() {
        uid = fetchedUid;
        email = fetchedEmail!;
      });
  }

  Future<void> _loadImages() async {
    final directory = await getApplicationDocumentsDirectory();

    final fileList = directory.listSync();
    allFileListPath
      ..clear()
      ..addAll(fileList
          .where((file) => file.path.endsWith('.jpg'))
          .map((e) => e.path)
          .toList())
      ..sort((a, b) => b.compareTo(a));

    setState(() {
      _selectImage = XFile(allFileListPath.first);
      isLoading = false;
    });
  }

  Future _uploadFile() async {
    DateTime now = DateTime.now();
    String timestamp = now.toIso8601String();
    SettableMetadata metadata = SettableMetadata(customMetadata: {
      'timestamp': timestamp,
    });
    final ref = FirebaseStorage.instance
        .ref()
        .child("images/$uid/${widget.whichProfile}");

    uploadTask = ref.putFile(File(_selectImage!.path), metadata);
    final snapshot = await uploadTask!.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();
    print(
        '$downloadUrl!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!this is upload which profile');
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ファイルは正常に削除されました！')),
          );
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
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // User pressed Delete
              },
              child: const Text(
                '削除',
                style: TextStyle(color: Colors.red),
              ),
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

    if (allFileListPath.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "画像が見つかりません！",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    try {
      // Main UI rendering
      return SafeArea(
          child: Scaffold(
        backgroundColor: Colors.black,
        body:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_buildImageTile(allFileListPath.first)]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        });
                    await uploadService.uploadFile(
                        uid, widget.whichProfile, _selectImage!.path);
                    if (mounted) {
                      await firestore.collection('Users').doc('$uid').update({
                        'comments-${widget.whichProfile}': FieldValue.delete(),
                      });
                      await firestore.collection('Users').doc('$uid').update({
                        'like-${widget.whichProfile}': FieldValue.delete(),
                      });
                      await firestore.collection('Users').doc('$uid').update({
                        'dislike-${widget.whichProfile}': FieldValue.delete(),
                      });
                      await firestore.collection('Users').doc('$uid').update({
                        'favourite-${widget.whichProfile}': FieldValue.delete(),
                      });

                      deleteAllFileWithConfirmation(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => MyProfile(),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.check, size: 40))
            ],
          )
        ]),
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
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 5),
            ),
            child: Imagetile(
              onDeletePressed: () => deleteAllFileWithConfirmation(context),
              // deleteFileWithConfirmation(context, File(filePath)),
              onSetPressed: () {},
              image_File: File(filePath),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CapturesScreen()),
                );
              },
            ),
          )
        ]);
  }
}
