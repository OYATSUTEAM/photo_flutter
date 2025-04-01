import 'package:flutter/material.dart';
import 'package:photo_sharing_app/data/global.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/services/chat/chat_services.dart';
import 'package:photo_sharing_app/services/other/other_service.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/ui/other/other_recommeneded_screen.dart';

class FollowingScreeen extends StatefulWidget {
  const FollowingScreeen(
      {super.key,
      required this.setUpInit,
      required this.recommendedFollowUsers});
  final VoidCallback setUpInit;
  final List<Map<String, dynamic>> recommendedFollowUsers;
  @override
  State<FollowingScreeen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreeen> {
  List<Map<String, dynamic>>? recommendedFollowUsers;

  OtherService otherService = OtherService();
  ChatService chatService = locator.get();
  final AuthServices authServices = locator.get();
  ProfileServices profileServices = ProfileServices();
  late String fromWhere;

  String myProfileURL = "";

  bool isLoading = true;
  String email = 'default@gmail.com',
      name = 'ローディング...',
      username = 'ローディング...',
      postText = '',
      uid = 'default';
  bool isAccountPublic = false;
  bool loading = true;
  Future<void> _setUpInit() async {
    try {
      final currentUser = await authServices.getCurrentuser();

      Map<String, dynamic>? userDetail =
          await authServices.getUserDetail(currentUser!.uid);
      if (userDetail != null) {
        isAccountPublic = userDetail['public'];
        name = userDetail['name'];
        username = userDetail['username'];
        uid = currentUser.uid;
        email = currentUser.email!;

        globalData.updatePostText(postText);
        globalData.updateUser(email, uid, username, name);
        globalData.updatePublic(isAccountPublic);
      }
      while (globalData.myEmail == 'default@gmail.com' ||
          globalData.myUid == '1234567890') {
        await Future.delayed(Duration(milliseconds: 100));
      }
      // listenForNewMessages(currentUser!.uid);
      final fetchedFollowFiles = await otherService.getRecentFollowImages(uid);
      final fetchedOtherFiles = await otherService.getRecentImageUrls();

      if (mounted && (userDetail != null)) {
        setState(() {
          isAccountPublic = userDetail['public'];
          name = userDetail['name'];
          username = userDetail['username'];
          uid = currentUser.uid;
          email = currentUser.email!;
          loading = false;
          recommendedFollowUsers = fetchedFollowFiles;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    setLoading();
    super.initState();
  }

  setLoading() async {
    setState(() {
      isLoading = true; // Show loading initially
    });
    await widget.setUpInit;
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      isLoading = false; // Hide loading after 3 seconds
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 1.0,
                  mainAxisSpacing: 1.0,
                  childAspectRatio: 0.7,
                ),
                itemCount: widget.recommendedFollowUsers.length,
                itemBuilder: (context, index) {
                  return _buildImageTile(widget.recommendedFollowUsers, index);
                },
              ));
  }

  Widget _buildImageTile(List<Map<String, dynamic>> imageFiles, int index) {
    return GestureDetector(
      onTap: () async {
        await globalData.updateOther(email, uid, username, name);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => OtherRecommendedScreen(
                  imageURL: imageFiles[index]['url'],
                  postText: imageFiles[index]['postText'],
                  otherUid: imageFiles[index]['uid'],
                  otherName: imageFiles[index]['name'],
                  otherUserName: imageFiles[index]['username'],
                  otherEmail: imageFiles[index]['email'],
                )));
      },
      child: Padding(
          padding: EdgeInsets.all(1),
          child: Stack(
            children: [
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                          image: NetworkImage(imageFiles[index]['url']),
                          fit: BoxFit.cover))),
            ],
          )),
    );
  }
}
