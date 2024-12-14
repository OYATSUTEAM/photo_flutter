import 'dart:io';

import 'package:flutter/material.dart';

class Profileimagetile extends StatelessWidget {
  const Profileimagetile({
    super.key,
    required this.imageURL,
    required this.onTap,
    required this.onDeletePressed,
    required this.onSetPressed,
    required this.isShowAll,
  });

  final bool isShowAll;
  final String imageURL;
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
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.grey,
                image: DecorationImage(
                  image: NetworkImage(imageURL),
                  fit: BoxFit.cover,
                )),
          ),
          // Positioned delete icon
        ],
      ),
    );
  }
}
