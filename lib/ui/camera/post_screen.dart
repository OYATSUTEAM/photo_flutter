import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_sharing_app/data/global.dart';
import 'package:photo_sharing_app/services/upload_service.dart';
import 'package:photo_sharing_app/ui/camera/post_camera.dart';
import 'package:photo_sharing_app/ui/camera/post_preview_screen.dart';
import 'package:photo_sharing_app/ui/screen/home_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:appinio_social_share/appinio_social_share.dart';

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
  String uid = '', email = '', username = '', name = '';
  bool isLoading = true;
  bool sharing = true;

  AppinioSocialShare appinioSocialShare = AppinioSocialShare();
  @override
  void initState() {
    super.initState();
    _initState();
    _loadImages();
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
        ..sort(); // Sort the list alphabetically
      setState(() {
        allPostFileList
          ..clear()
          ..addAll(fileList);
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
          content: const Text('投稿は正しく行われましたか？'),
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
              child: const Text('はい', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        List<File> filesToRemove = [];
        showDialog(
            context: context,
            builder: (context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            });
        for (final String filePath in allPostFileList) {
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
        // globalData.updatePostText('');
        setState(() {
          _loadImages();
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
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

  Future<String> shareImage() async {
    final box = context.findRenderObject() as RenderBox?;

    List<XFile> xFiles = allPostFileList.map((path) => XFile(path)).toList();
    print('${globalData.postText}=================');
    await Share.shareXFiles(
      xFiles,
      text: globalData.postText,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    ).then((shareResult) async {
      print(shareResult.status.toString());
      if (shareResult.status.toString() == 'ShareResultStatus.success') {
        showDialog(
            context: context,
            builder: (context) {
              return const Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [CircularProgressIndicator(), Text('投稿アップロード中...')],
              ));
            });
        for (var path in allPostFileList) {
          await addToPostedImages(uid, globalData.postText, path);
        }
        if (mounted) {
          Navigator.pop(context);
        }
        await deleteAllFileWithConfirm(context);

        return shareResult.status.toString();
      }
    });

    return 'failure';
  }

  // Future<void> shareImage() async {
  //   try {
  //     final result = await _channel.invokeMethod('shareImage', {
  //       'imagePath': allPostFileList.first.toString(),
  //       'text': 'text',
  //     });

  //     if (result == 'shared') {
  //       print("Sharing started...======");
  //     }
  //   } on PlatformException catch (e) {
  //     print("Error==========: ${e.message}");
  //   }

  //   // Listen for result
  //   _channel.setMethodCallHandler((call) async {
  //     if (call.method == "shareSuccess") {
  //       print("User successfully shared the image!=============");
  //       // Perform your post-sharing logic here
  //     } else if (call.method == "shareFailed") {
  //       print("User did NOT share the image.=======");
  //       // Handle cases where the user didn't share
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (allPostFileList.isEmpty) {
      return Scaffold(
        // backgroundColor: Colors.grey,
        appBar: AppBar(),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "画像が見つかりません！",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 50),
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => PostCameraScreen(
                        isDelete: false,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.add_circle_sharp,
                  size: 50,
                ))
          ],
        )),
      );
    }

    return SafeArea(
        child: Scaffold(
            body: GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Hide keyboard when tapping outside
      },
      child: SingleChildScrollView(
          child: Center(
              child: Column(children: [
        Row(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                icon: Icon(Icons.arrow_back))
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width,
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 1.0, horizontal: 18.0),
              filled: true,
              // fillColor: const Color.fromARGB(255, 0, 0, 0),
              hintText: '投稿文',
              hintStyle:
                  TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            minLines: 1,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            onChanged: (text) {
              globalData.updatePostText(text.trim());
            },
          ),
        ),
        const SizedBox(height: 20),
// ==========================================================        post file   =====================================================
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35.0),
                child: TextButton(
                    onPressed: () async {
                      await shareImage();
                      // print(
                      // '${appinioSocialShare.getInstalledApps()}===========================');
                      // appinioSocialShare.android
                      //     .shareToTelegram('message', allPostFileList.first)
                      //     .then((result) {
                      //   print('$result==============');
                      // });
                    },
                    child: const Text('投稿',
                        style: TextStyle(color: Colors.white, fontSize: 16)))),
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
