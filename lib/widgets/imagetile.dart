import 'dart:io';

import 'package:flutter/material.dart';

class Imagetile extends StatelessWidget {
  const Imagetile({
    super.key,
    required this.image_File,
    required this.onTap,
    required this.onDeletePressed,
    required this.onSetPressed,
  });

  final File image_File;
  final void Function()? onTap;
  final VoidCallback onDeletePressed;
  final VoidCallback onSetPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Setting width using MediaQuery and maintaining 4:5 aspect ratio
          Center(
            child: Padding(
                padding:
                    const EdgeInsets.all(9.0), // Add padding around the image
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Image.file(
                    image_File,
                  ),
                )),
          ),
          // Positioned delete icon
          Positioned(
            top: 0, // Adjusted to account for padding
            right: -10, // Adjusted to account for padding
            child: IconButton(
              onPressed: onDeletePressed,
              icon: const Icon(
                Icons.delete_forever,
                color: Colors.white,
                size: 35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
