import 'dart:io';
import 'package:flutter/material.dart';
import 'package:testing/ui/camera/preview_screen.dart';
import 'package:testing/widgets/imagetile.dart';
import 'package:path_provider/path_provider.dart';

List<File> allFileList = [];

class CapturesScreen extends StatefulWidget {
  const CapturesScreen({super.key});

  @override
  _CapturesScreenState createState() => _CapturesScreenState();
}

class _CapturesScreenState extends State<CapturesScreen> {
  String initiatWord = 'captures';

  @override
  void initState() {
    super.initState();
    _setUpInitial();
  }

  @override
  void dispose() {
    // Add any additional cleanup logic if required in the future.
    super.dispose();
  }

  Future<void> _setUpInitial() async {
    final directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> fileList = await directory.list().toList();
    allFileList.clear();
    List<Map<int, dynamic>> fileNames = [];

    fileList.forEach((file) {
      if (file.path.contains('.jpg')) {
        allFileList.add(File(file.path));

        String name = file.path.split('/').last.split('.').first;
        fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
      }
    });
  }

  Future<void> deleteImage(File file) async {
    try {
      if (await file.exists()) {
        await file.delete(); // Deletes the file
        print('File deleted successfully');
      } else {
        print('File does not exist');
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  void setImage() {
    setState(() {});
  }

  Future<void> deleteFileWithConfirmation(
      BuildContext context, File file) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const Text('Are you sure you want to delete this file?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // User pressed Cancel
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // User pressed Delete
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        if (await file.exists()) {
          await file.delete();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File deleted successfully!')),
          );
          setState(() {
            allFileList.remove(file); // Remove the file from the list
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File does not exist.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                initiatWord,
                style: const TextStyle(
                  fontSize: 32.0,
                  color: Colors.white,
                ),
              ),
            ),
            if (allFileList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No captures found!',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              )
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                children: allFileList.map((imageFile) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      ),
                    ),
                    child: Imagetile(
                      onDeletePressed: () =>
                          deleteFileWithConfirmation(context, imageFile),
                      onSetPressed: setImage,
                      image_File: imageFile,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => PreviewScreen(
                              // fileList: allFileList,
                              imageFile: imageFile,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
