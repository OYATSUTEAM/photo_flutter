import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:testing/ui/camera/add_camera_screen.dart';
import 'package:testing/ui/camera/camera_screen.dart';
import 'package:testing/ui/camera/preview_screen.dart';
import 'package:testing/widgets/imagetile.dart';
import 'package:share_plus/share_plus.dart';

class PostPreviewScreen extends StatefulWidget {
  const PostPreviewScreen({super.key});

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
      ..sort((a, b) => b.compareTo(a));

    setState(() {
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

  Future<void> shareImage() async {
    await Share.shareXFiles(
        [XFile(allFileListPath.first), XFile(allFileListPath.last)],
        text: textController.text.trim());

    for (final path in allFileListPath) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete(); // Delete each file
      }
    }

    setState(() {});
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          allFileListPath.length == 2
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: _buildImageTile(allFileListPath.last),
                    ),
                    Expanded(
                      child: _buildImageTile(allFileListPath.first),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildImageTile(allFileListPath.first),
                    ),
                    const SizedBox(
                      width: 60,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => AddCameraScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_circle,
                          size: 40, color: Colors.white),
                    ),
                    const SizedBox(
                      width: 60,
                    ),
                  ],
                ),
          const SizedBox(height: 180),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: TextField(
              focusNode: focusNode,
              controller: textController,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 1.0, horizontal: 18.0),
                filled: true,
                fillColor: const Color.fromARGB(255, 0, 0, 0),
                hintText: '投稿文',
                hintStyle:
                    TextStyle(color: Theme.of(context).colorScheme.primary),
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
                    await shareImage();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    '投稿',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageTile(String filePath) {
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
          child: Imagetile(
            onDeletePressed: () =>
                deleteFileWithConfirmation(context, File(filePath)),
            onSetPressed: () {},
            image_File: File(filePath),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      PreviewScreen(imageFile: File(filePath)),
                ),
              );
            },
          ),
        ));
  }
}
