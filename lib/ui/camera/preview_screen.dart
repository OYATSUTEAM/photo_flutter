import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import 'package:testing/ui/camera/captures_screen.dart';

class PreviewScreen extends StatefulWidget {
  final File imageFile;
  // final List<File> fileList;

  const PreviewScreen({
    required this.imageFile,
    // required this.fileList,
  });

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  @override
  void dispose() {
    // Add any cleanup logic here if needed in the future.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      // Main UI rendering
      return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.file(widget.imageFile,
                  cacheWidth: 300, cacheHeight: 500),
            )
          ],
        ),
      );
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
}
