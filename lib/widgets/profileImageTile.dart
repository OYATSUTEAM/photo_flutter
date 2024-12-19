import 'package:firebase_storage/firebase_storage.dart';
import 'package:testing/services/auth/auth_service.dart';
import 'package:testing/DI/service_locator.dart';

import 'package:flutter/material.dart';
import 'package:testing/widgets/othertile.dart';

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

String? imageURL;
final AuthServices _authServices = locator.get();

class _ProfileImageTileState extends State<ProfileImageTile> {
  String? uid = _authServices.getCurrentuser()!.uid;
  @override
  void initState() {
    _setUpProfilePreview();
    super.initState();
  }

  Future<void> _setUpProfilePreview() async {
    final fetchedURL = await getWhichProfileUrl();
    if (mounted) {
      setState(() {
        imageURL = fetchedURL;
      });
    }
  }

  Future<String> getWhichProfileUrl() async {
    try {
      final profileRef = FirebaseStorage.instance
          .ref()
          .child("images/${uid!}/${widget.whichProfile}");
      String profileUrl = await profileRef.getDownloadURL();
      _setUpProfilePreview();
      return profileUrl;
    } catch (e) {
      print(e);
      if (widget.whichProfile == 'firstProfileImage')
        return profileService.firstURL;
      else if (widget.whichProfile == 'secondProfileImage')
        return profileService.secondURL;
      else if (widget.whichProfile == 'thirdProfileImage')
        return profileService.thirdURL;
      return profileService.forthURL;
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
                      imageURL != null ? imageURL! : profileService.mainURL),
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
