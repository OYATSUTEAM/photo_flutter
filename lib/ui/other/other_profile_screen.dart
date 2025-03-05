import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/theme/theme_manager.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_sharing_app/ui/camera/preview_screen.dart';
import 'package:photo_sharing_app/ui/other/other_profile_preview_screen.dart';
import 'package:photo_sharing_app/ui/other/report_screen.dart';
import 'package:photo_sharing_app/services/other/other_service.dart';
import '../../data/global.dart';

enum Options { option1, option2, option3 }

class OtherProfile extends StatefulWidget {
  final String otherUid;
  const OtherProfile({super.key, required this.otherUid});

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
    final fetchedOtheProfileImagesURL =
        await otherService.getPublicImageURLs(widget.otherUid);
    final fetchedOtherMainProfileURL = await getMainProfileUrl(widget.otherUid);

    if (mounted) {
      setState(() {
        otherProfileImagesURL = fetchedOtheProfileImagesURL;
        otherMainProfileURL = fetchedOtherMainProfileURL;
        isLoading = false;
      });
    }
  }

  Future<void> fetchUsername() async {
    try {
      var user = await authServices.getDocument(widget.otherUid);
      final fetchedBlock = await profileServices.isBlockTrue();
      if (user != null) {
        setState(() {
          username = user['username'];
          isBlockTrue = fetchedBlock;
          name = user['name'];
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

  Future<void> deleteFileWithConfirmation(
      BuildContext context, String whichProfile) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('本当にこのファイルを削除しますか？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('キャンセル')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        final ref =
            FirebaseStorage.instance.ref().child("images/${whichProfile}");

        // Attempt to delete the file
        await ref.delete();
        print("File deleted successfully.");
      } catch (e) {
        if (e.toString().contains('object-not-found')) {
          print("File does not exist.");
        } else {
          print("An error occurred while deleting the file: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    int midIndex = (otherProfileImagesURL.length / 2).floor();

    List<String> latestImages = otherProfileImagesURL.sublist(0, midIndex);
    List<String> oldestImages = otherProfileImagesURL.sublist(midIndex);
    return Scaffold(
        // drawer: ReportScreen(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          toolbarHeight: 36,
          title: SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.576,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                      ],
                    )),
                MyMenuButton()
              ],
            ),
          ),
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Stack(children: [
                  SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                              builder: (context) => OtherProfilePreviewScreen(
                                  imageURL: otherMainProfileURL),
                            ));
                          },
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(otherMainProfileURL),
                            radius: MediaQuery.of(context).size.width * 0.25,
                          ),
                        ),

                        const SizedBox(height: 1),
                        Text(
                          name,
                          style: const TextStyle(fontSize: 26),
                        ),
                        SizedBox(height: 1),
//=============================================================================                  follow this user        ===========================
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 60)),
                              onPressed: () {
                                otherService
                                    .followOther(widget.otherUid)
                                    .then((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'お客様は「${globalData.otherUserName}」をフォローしました。')),
                                  );
                                });
                              },
                              child: Text(
                                "フォロー", // follow
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                              )),
                        ),
                        FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
                            future: getImageNames(widget.otherUid),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text("Error: ${snapshot.error}"));
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!['latest']!.isEmpty) {
                                return Center(child: Text(""));
                              }

                              final imagesData = snapshot.data!;
                              final latestImages = imagesData["latest"]!;
                              final otherImages = imagesData["others"]!;
                              return Row(children: [
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                            0.5 -
                                        6,
                                    height: MediaQuery.of(context).size.height -
                                        40 -
                                        MediaQuery.of(context).size.width *
                                            0.5 -
                                        80,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ...latestImages.map((image) {
                                            return FutureBuilder<String>(
                                                future: FirebaseStorage.instance
                                                    .ref(
                                                        'images/${widget.otherUid}/profileImages/${image['name']}')
                                                    .getDownloadURL(),
                                                builder:
                                                    (context, urlSnapshot) {
                                                  if (!urlSnapshot.hasData)
                                                    return Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  return _buildImageTile(
                                                      urlSnapshot.data!,
                                                      image['status']);
                                                });
                                          }).toList(),
                                        ],
                                      ),
                                    )),
                                SizedBox(width: 2),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                            0.5 -
                                        6,
                                    height: MediaQuery.of(context).size.height -
                                        40 -
                                        MediaQuery.of(context).size.width *
                                            0.5 -
                                        80,
                                    child: SingleChildScrollView(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ...otherImages.map((image) {
                                          return FutureBuilder<String>(
                                              future: FirebaseStorage.instance
                                                  .ref(
                                                      'images/$uid/profileImages/${image['name']}')
                                                  .getDownloadURL(),
                                              builder: (context, urlSnapshot) {
                                                if (!urlSnapshot.hasData)
                                                  return Center(
                                                      child:
                                                          CircularProgressIndicator());
                                                return _buildImageTile(
                                                    urlSnapshot.data!,
                                                    image['status']);
                                              });
                                        }).toList(),
                                      ],
                                    )))
                              ]);
                            }),
                      ],
                    ),
                  ),
                ]))));
  }

  TextEditingController spamController = TextEditingController();
  TextEditingController sexController = TextEditingController();
  TextEditingController otherHaressmentController = TextEditingController();
  TextEditingController scamController = TextEditingController();
  TextEditingController otherController = TextEditingController();
  TextEditingController impersonationController = TextEditingController();

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

  Widget _buildImageTile(String imageURL, String status) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PreviewScreen(imageURL: imageURL),
            ),
          );
        },
        child: Stack(children: [
          CachedNetworkImage(
            imageUrl: imageURL,
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ]));
  }
}
