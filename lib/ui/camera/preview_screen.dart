import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import 'package:photo_sharing_app/ui/camera/captures_screen.dart';

class PreviewScreen extends StatefulWidget {
  final String imageURL;
  const PreviewScreen({
    required this.imageURL,
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
            Container(
                width: MediaQuery.of(context).size.width * 0.97,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.grey,
                    image: DecorationImage(
                      image: NetworkImage(widget.imageURL),
                      fit: BoxFit.cover,
                    ))),
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
