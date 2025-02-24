import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import 'package:photo_sharing_app/ui/camera/captures_screen.dart';

class PostPreviewScreen extends StatefulWidget {
  final File imageFile;
  const PostPreviewScreen({
    required this.imageFile,
  });

  @override
  _PreviewPreviewScreenState createState() => _PreviewPreviewScreenState();
}

class _PreviewPreviewScreenState extends State<PostPreviewScreen> {
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
                child: Image.file(
              widget.imageFile,
            ))
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
