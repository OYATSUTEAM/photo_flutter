import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_sharing_app/ui/camera/post_camera_screen.dart';
import 'package:photo_sharing_app/ui/camera/camera_screen.dart';
import 'package:photo_sharing_app/ui/camera/preview_screen.dart';
import 'package:share_plus/share_plus.dart';

class PostPreviewScreen extends StatefulWidget {
  final bool isDelete;
  const PostPreviewScreen({super.key, required this.isDelete});

  @override
  _PostPreviewScreenState createState() => _PostPreviewScreenState();
}

class _PostPreviewScreenState extends State<PostPreviewScreen> {
  final FocusNode focusNode = FocusNode();
  final TextEditingController textController = TextEditingController();
  final List<String> allFileListPath = [];
  bool isLoading = true;
  bool sharing = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
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
      ..sort((a, b) => a.compareTo(b));

    setState(() {
      isLoading = false;
    });
    if (widget.isDelete) {
      if (allFileListPath.length > 0) {
        await deleteAllFileWithConfirm(context);
      }
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
        setState(() {
          _loadImages();
        });
        Navigator.pop(context);
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
            allFileListPath.remove(file.path);
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
    List<XFile> xFiles = allFileListPath
        .map((path) => XFile(path, ))
        .toList();

    await Share.shareXFiles(
      // xFiles,
      [],
      text: textController.text.trim(),
    ).then((_) async {
      // Iterate over the list in reverse to safely remove items while iterating
      // for (int i = allFileListPath.length - 1; i >= 0; i--) {
      //   final path = allFileListPath[i];
      //   final file = File(path);
      //   if (await file.exists()) {
      //     await file.delete(); // Delete the file
      //     allFileListPath.removeAt(i); // Remove the path from the list
      //   }
      // }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CameraScreen(),
        ),
      );
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // if (allFileListPath.isEmpty) {
    //   return Scaffold(
    //     backgroundColor: Colors.black,
    //     body: Center(
    //         child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         const Text(
    //           "画像が見つかりません！",
    //           style: TextStyle(color: Colors.white),
    //         ),
    //         const SizedBox(height: 50),
    //         IconButton(
    //             onPressed: () {
    //               Navigator.of(context).pushReplacement(
    //                 MaterialPageRoute(
    //                   builder: (context) => PostCameraScreen(),
    //                 ),
    //               );
    //             },
    //             icon: const Icon(
    //               Icons.add_circle_sharp,
    //               size: 50,
    //             ))
    //       ],
    //     )),
    //   );
    // }

    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.black,
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context)
                    .unfocus(); // Hide keyboard when tapping outside
              },
              child: SingleChildScrollView(
                  child: Center(
                      child: Column(children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.74,
                  width: MediaQuery.of(context).size.width,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns
                      crossAxisSpacing: 8.0, // Space between columns
                      mainAxisSpacing: 8.0, // Space between rows
                      childAspectRatio: 0.6, // Aspect ratio of each grid item
                    ),
                    itemCount: allFileListPath.length,
                    itemBuilder: (context, index) {
                      return Container(
                        child: _buildImageTile(index, allFileListPath.length),
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
                      filled: true,
                      fillColor: const Color.fromARGB(255, 0, 0, 0),
                      hintText: '投稿文',
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    minLines: 1,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35.0),
                      child: TextButton(
                        onPressed: () async {
                          // // Add post logic here
                          await shareImage().then((_) {});
                        },
                        child: const Text(
                          '投稿',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                )
              ]))),
            )));
  }

  Widget _buildImageTile(int index, int count) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 5),
          borderRadius: const BorderRadius.all(
            Radius.circular(70),
          ),
        ),
        child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PreviewScreen(
                        imageFile: File(allFileListPath[index]),
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
                        image: FileImage(File(allFileListPath[
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
                            context, File(allFileListPath[index]));
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
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => PostCameraScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                ]))));
  }
}
