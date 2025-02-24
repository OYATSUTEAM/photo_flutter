import 'package:firebase_storage/firebase_storage.dart';
import 'package:photo_sharing_app/data/global.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';

import 'package:flutter/material.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/ui/auth/reset_password.dart';
// import 'package:photo_sharing_app/widgets/othertile.dart';

class ProfileImageTile extends StatefulWidget {
  const ProfileImageTile({
    super.key,
    required this.whichProfile,
    required this.onTap,
    required this.onDeletePressed,
    required this.onSetPressed,
    required this.isShowAll,
  });
  final String whichProfile;
  final bool isShowAll;
  final void Function()? onTap;
  final VoidCallback onDeletePressed;
  final VoidCallback onSetPressed;

  @override
  _ProfileImageTileState createState() => _ProfileImageTileState();
}

final AuthServices authServices = locator.get();

class _ProfileImageTileState extends State<ProfileImageTile> {
  String? imageURL;
  String uid = globalData.myUid;
  @override
  void initState() {
    _setUpProfilePreview();
    super.initState();
  }

  Future<void> _setUpProfilePreview() async {
    final fetchedURL = await getMainProfileUrl(uid);
    if (mounted) {
      setState(() {
        imageURL = fetchedURL;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          // Setting width using MediaQuery and maintaining 4:5 aspect ratio
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.grey,
                image: DecorationImage(
                  image: NetworkImage(
                      imageURL != null ? imageURL! : profileServices.mainURL),
                  fit: BoxFit.cover,
                )),
          ),
          // Positioned delete icon
          Positioned(
            top: 0, // Adjusted to account for padding
            right: 0, // Adjusted to account for padding
            child: IconButton(
              onPressed: widget.onSetPressed,
              icon: Icon(
                Icons.content_copy,
                color: widget.isShowAll
                    ? Color.fromARGB(255, 5, 1, 1)
                    : Colors.black,
                size: 25,
              ),
            ),
          ),
          Positioned(
            top: 0, // Adjusted to account for padding
            left: 0, // Adjusted to account for padding
            child: IconButton(
              onPressed: widget.onDeletePressed,
              icon: Icon(
                Icons.delete_forever,
                color: widget.isShowAll
                    ? Color.fromARGB(255, 0, 0, 0)
                    : Colors.black,
                size: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
