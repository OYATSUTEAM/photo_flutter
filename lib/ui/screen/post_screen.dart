import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_sharing_app/data/global.dart';
import 'package:photo_sharing_app/services/upload_service.dart';
import 'package:photo_sharing_app/ui/camera/post_camera.dart';
import 'package:photo_sharing_app/ui/camera/post_preview_screen.dart';
import 'package:photo_sharing_app/home_screen.dart';
import 'package:photo_sharing_app/ui/myProfile/myProfile.dart';
import 'package:path/path.dart' as p;

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  _PostScreenState createState() => _PostScreenState();
}

const MethodChannel _channel = MethodChannel('app/share');

class _PostScreenState extends State<PostScreen> {
  final FocusNode focusNode = FocusNode();
  final TextEditingController textController = TextEditingController();
  final List<String> allPostFileList = [];
  final List<String> allPostFileListBackground = [];
  String uid = '', email = '', username = '', name = '';
  bool isLoading = true;
  bool sharing = true;

  @override
  void initState() {
    super.initState();
    _initState();
    _loadImages();
    _loadImagesBack();
  }

  void _initState() async {
    setState(() {
      uid = globalData.myUid;
      username = globalData.myUserName;
      name = globalData.myName;
      email = globalData.myEmail;
    });
  }

  void deleteAllFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final subDir = Directory('${directory.path}/$uid/postImages');
    if (await subDir.exists()) {
      try {
        for (final file in subDir.listSync()) {
          if (file is File) {
            await file.delete();
          }
        }
      } catch (e) {
        print("Error deleting files: $e");
      }
    } else {
      print("Directory does not exist: ${subDir.path}");
    }
  }

  Future<void> _loadImages() async {
    print(uid);
    final directory = await getApplicationDocumentsDirectory();
    final subDir = Directory('${directory.path}/$uid/postImages');
    setState(() {
      textController.text = globalData.postText;
    });
    if (await subDir.exists()) {
      final fileList = subDir
          .listSync()
          .where((file) => file.path.endsWith('.jpg')) // Filter only .jpg files
          .map((file) => file.path)
          .toList()
        ..sort();

      setState(() {
        allPostFileList
          ..clear()
          ..addAll(fileList);
        isLoading = false;
      });
    }
  }

  Future<void> _loadImagesBack() async {
    print(uid);
    final directory = await getApplicationDocumentsDirectory();
    final subDirBack = Directory('${directory.path}/$uid/postImagesBack');
    setState(() {
      textController.text = globalData.postText;
    });
    if (await subDirBack.exists()) {
      final fileListBack = subDirBack
          .listSync()
          .where((file) => file.path.endsWith('.jpg')) // Filter only .jpg files
          .map((file) => file.path)
          .toList()
        ..sort();
      setState(() {
        allPostFileListBackground
          ..clear()
          ..addAll(fileListBack);
        isLoading = false;
      });
    }
  }

  Future<void> deleteAllFileWithConfirm(
    BuildContext context,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('投稿確認'),
          content: const Text('投稿しますか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('はい', style: TextStyle(color: Colors.red)))
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        List<File> filesToRemove = [];
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return const Center(child: CircularProgressIndicator());
            });

        for (var path in allPostFileList) {
          await addToPostedImages(
              uid, globalData.postText, path, p.basenameWithoutExtension(path));
        }

        for (final String filePath in allPostFileList) {
          File file = File(filePath);
          if (await file.exists()) {
            await file.delete();
            filesToRemove.add(file);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ファイルが存在しません。')),
            );
          }
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MyProfileScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ファイルの削除に失敗しました: $e')),
        );
      }
    }
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
            allPostFileList.remove(file.path);
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

  Future<void> shareImage() async {
    await deleteAllFileWithConfirm(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {}
    if (allPostFileList.isEmpty) {
      return Scaffold(
        appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => MyProfileScreen()));
                },
                icon: Icon(Icons.abc))),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("画像が見つかりません！", style: TextStyle(color: Colors.white)),
            const SizedBox(height: 50),
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) =>
                            PostCameraScreen(isDelete: false)),
                  );
                },
                icon: const Icon(Icons.add_circle_sharp, size: 50))
          ],
        )),
      );
    }

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                title: Text('投稿'),
                centerTitle: true,
                leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => HomeScreen(),
                      ));
                    },
                    icon: BackButtonIcon())),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                  child: Center(
                      child: Column(children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: MediaQuery.of(context).size.width,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns
                      crossAxisSpacing: 8.0, // Space between columns
                      mainAxisSpacing: 8.0, // Space between rows
                      childAspectRatio: 0.7, // Aspect ratio of each grid item
                    ),
                    itemCount: allPostFileList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        child: _buildImageTile(index, allPostFileList.length),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: TextField(
                    focusNode: focusNode,
                    controller: textController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 1.0, horizontal: 18.0),
                      labelText: '投稿文',
                    ),
                    minLines: 1,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    onChanged: (text) {
                      globalData.updatePostText(text.trim());
                    },
                  ),
                ),
                const SizedBox(height: 10),

// ==========================================================        post file   =====================================================
// ==========================================================        post file   =====================================================
// ==========================================================        post file   =====================================================
// ==========================================================        post file   =====================================================
// ==========================================================        post file   =====================================================

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35.0),
                        child: TextButton(
                            onPressed: () async {
                              await shareImage();
                            },
                            child: const Text('投稿',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)))),
                  ],
                )
              ]))),
            )));
  }

  Widget _buildImageTile(int index, int count) {
    return Container(
        child: DecoratedBox(
            decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(16),
                ),
            child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PostPreviewScreen(
                        imageFile: File(allPostFileList[index]),
                      ),
                    ),
                  );
                },
                child: Stack(children: [
                  // Image Container
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: FileImage(File(allPostFileList[
                            index])), // Displaying image from file
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Delete Button (Top-right)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        deleteFileWithConfirmation(
                            context, File(allPostFileList[index]));
                      },
                    ),
                  ),
                  if (index == count - 1)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.add_circle),
                        color: Colors.green,
                        onPressed: () {
                          // globalData.updatePostText(textController.text.trim());
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => PostCameraScreen(
                                isDelete: false,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ]))));
  }
}
