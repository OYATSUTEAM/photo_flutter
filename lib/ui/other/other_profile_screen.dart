import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/theme/theme_manager.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_sharing_app/ui/other/other_profile_preview_screen.dart';
import 'package:photo_sharing_app/ui/other/report_screen.dart';
import 'package:photo_sharing_app/services/other/other_service.dart';
import '../../data/global.dart';

enum Options { option1, option2, option3 }

class OtherProfile extends StatefulWidget {
  final String otherUid;
  // final String otherUserName;
  // final String otherName;
  // final String otherEmail;
  const OtherProfile(
      {super.key,
      // required this.otherEmail,
      // required this.otherName,
      // required this.otherUserName,
      required this.otherUid});

  @override
  _OtherProfile createState() => _OtherProfile();
}

OtherService otherService = OtherService();

FirebaseAuth _auth = FirebaseAuth.instance;
final AuthServices authServices = locator.get();
ProfileServices profileServices = ProfileServices();

class _OtherProfile extends State<OtherProfile> {
  bool isLoading = true;
  final User? user = _auth.currentUser;
  bool isReportTrue = true;
  bool isBlockTrue = true;
  String email = 'default@gmail.com',
      name = 'ローディング...',
      username = 'ローディング...',
      uid = 'default';
  // File? _imageFile;
  File? otherProfileImage;
  final currentUser = authServices.getCurrentuser();
  bool switchResult = ThemeManager.readTheme();
  List<String> otherProfileImagesURL = [];
  String otherMainProfileURL = globalData.profileURL;
  @override
  void initState() {
    super.initState();
    _setProfileInitiate();
    fetchUsername();
  }

  Future<void> _setProfileInitiate() async {
    while (globalData.myUid == '1234567890') {
      await Future.delayed(Duration(milliseconds: 100));
    }
    final fetchedOtherMainProfileURL = await getMainProfileUrl(widget.otherUid);

    if (mounted)
      setState(() {
        otherMainProfileURL = fetchedOtherMainProfileURL;
      });
    final fetchedOtheProfileImagesURL =
        await otherService.getPublicImageURLs(widget.otherUid);

    if (mounted) {
      setState(() {
        otherProfileImagesURL = fetchedOtheProfileImagesURL;
        isLoading = false;
      });
    }
  }

  Future<void> fetchUsername() async {
    try {
      while (globalData.myUid == '1234567890') {
        await Future.delayed(Duration(milliseconds: 100));
      }
      var user = await authServices.getDocument(widget.otherUid);
      final fetchedBlock = await profileServices.isBlockTrue();
      if (user != null) {
        setState(() {
          username = user['username'];
          isBlockTrue = fetchedBlock;
          name = user['name'];
          globalData.updateOther(email, widget.otherUid, username, name);
        });
      }
    } catch (e) {
      // Handle any errors
      print('$e  this error is occured in other profile.');
      if (mounted)
        setState(() {
          username = "Error fetching username";
          name = "Error fetching username";
        });
      debugPrint("Error fetching username: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // int midIndex = (otherProfileImagesURL.length / 2).floor();

    // List<String> latestImages = otherProfileImagesURL.sublist(0, midIndex);
    // List<String> oldestImages = otherProfileImagesURL.sublist(midIndex);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Expanded(
              child: Text(globalData.otherUserName,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 20))),
        ),

        // drawer: ReportScreen(),
        // backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => OtherProfilePreviewScreen(
                        imageURL: otherMainProfileURL,
                        otherUid: widget.otherUid,
                        otherName: name,
                        otherUserName: username,
                        otherEmail: email,
                      ),
                    ));
                  },
                  child: CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(otherMainProfileURL),
                      radius: MediaQuery.of(context).size.width * 0.25),
                ),

                const SizedBox(height: 1),
                Text(name, style: const TextStyle(fontSize: 26)),
                SizedBox(height: 1),
//=============================================================================                  follow this user        ===========================
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 60)),
                      onPressed: () {
                        otherService.followOther(widget.otherUid).then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'お客様は「${globalData.otherUserName}」をフォローしました。')),
                          );
                        });
                      },
                      child: Text(
                        "フォロー", // follow
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      )),
                ),
                Expanded(
                    child:
                        StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
                            stream: getImageNames(widget.otherUid),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text("Error: ${snapshot.error}"));
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data?['latest'] == null ||
                                  snapshot.data!['latest']!.isEmpty) {
                                return Center(child: Text(""));
                              }

                              final imagesData = snapshot.data!;
                              final latestImages = imagesData["latest"] ?? [];
                              final otherImages = imagesData["others"] ?? [];

                              return Row(children: [
                                Expanded(
                                    child: ListView(
                                  children: latestImages.map((image) {
                                    return _buildImageTile(
                                        image['url'], );
                                  }).toList(),
                                )),
                                SizedBox(width: 1),
                                Expanded(
                                    child: ListView(
                                  children: otherImages.map((image) {
                                    return _buildImageTile(
                                        image['url'],   );
                                  }).toList(),
                                )),
                              ]);
                            })),
              ],
            ),
          ),
        ));
  }

  Widget MyMenuButton() {
    return SizedBox(
        width: 55,
        child: PopupMenuButton<String>(
          color: const Color.fromARGB(0, 180, 171, 171),
          offset: Offset(0, 30),
          child: TextButton(
            onPressed: null,
            child: Text(
              ". . .",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          constraints: BoxConstraints(maxHeight: 100, maxWidth: 80),
          onSelected: (value) async {
            if (value == "report") {
              if (isReportTrue) {
                showModalBottomSheet(
                  context: context,
                  scrollControlDisabledMaxHeightRatio: 0.9,
                  builder: (context) {
                    return ReportScreen(otherUid: widget.otherUid);
                  },
                );
              }
            } else if (value == "block") {
              if (isBlockTrue) {
                await otherService.blockThisUser(widget.otherUid);
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text('このユーザーをブロックしました'),
                      );
                    });
                Future.delayed(Duration(seconds: 1), () {
                  if (mounted) {
                    Navigator.pop(context);
                  }
                });
              }
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                  height: 20,
                  value: "report",
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("報告", style: TextStyle(fontSize: 10)),
                        ]),
                  )),
              PopupMenuItem(
                  height: 20,
                  value: "block",
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("ブロック", style: TextStyle(fontSize: 10)),
                        ],
                      )))
            ];
          },
        ));
  }

  Widget _buildImageTile(String imageURL, ) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => OtherProfilePreviewScreen(
              imageURL: imageURL,
              otherUid: widget.otherUid,
              otherName: name,
              otherUserName: username,
              otherEmail: email,
            ),
          ));
        },
        child: Padding(
          padding: EdgeInsets.all(1),
          child: CachedNetworkImage(
            width: MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).size.height / 3 + 10,
            fit: BoxFit.fitWidth,
            imageUrl: imageURL,
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ));
  }
}
