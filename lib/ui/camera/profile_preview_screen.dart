// import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testing/services/auth/auth_service.dart';
import 'package:testing/DI/service_locator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:testing/services/other/other_service.dart';
import 'package:testing/ui/camera/profile_camera_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:testing/widgets/othertile.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
final User? user = _auth.currentUser;

class ProfilePreviewScreen extends StatefulWidget {
  final String whichProfile;
  final String uid;
  const ProfilePreviewScreen({required this.whichProfile, required this.uid});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

final otherService = OtherService(locator.get(), locator.get());
ScrollController _scrollController = ScrollController();

final AuthServices _authServices = locator.get();
String? imageURL;
String _firstURL =
    "https://us.123rf.com/450wm/apoev/apoev1806/apoev180600156/103284749-default-placeholder-businessman-half-length-portrait-photo-avatar-man-gray-color.jpg";
String _secondURL = "https://en.pimg.jp/079/687/576/1/79687576.jpg";
String _thirdURL =
    "https://img.freepik.com/premium-photo/default-avatar-profile-icon-gray-placeholder-man-woman-isolated-white-background_660230-21610.jpg";
String _forthURL =
    "https://img.freepik.com/premium-vector/grandparents-icon-vector-image-can-be-used-child-adoption_120816-381816.jpg?semt=ais_hybrid";

bool isCommenting = false; // To track if comment input is visible
List<Map<String, dynamic>> comments = [];
List<dynamic> like = [], dislike = [], favourite = [];
String email = 'default@gmail.com',
    name = 'ローディング...',
    username = 'ローディング...',
    uid = 'default';
var otherUser, otherUserName;

class _PreviewScreenState extends State<ProfilePreviewScreen> {
  @override
  void initState() {
    getCurrentUserUID();
    print(
        '${widget.whichProfile}!!!!!!!!!!this is important!!!${widget.whichProfile}');
    _setUpProfilePreview();
    super.initState();
  }

  void getCurrentUserUID() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
        email = user.email!;
        isCommenting = false;
      });
    }
  }

  Future<void> _setUpProfilePreview() async {
    final fetchedURL = await getWhichProfileUrl();
    var user = await _authServices.getDocument(uid);
    List<Map<String, dynamic>> fetchedComments =
        await otherService.getAllComments(uid, widget.whichProfile);
    if (mounted) {
      setState(() {
        comments = fetchedComments;
        imageURL = fetchedURL;
      });
      if (user != null) {
        setState(() {
          username = user['username'];
          name = user['name'];
          final favouriteWhichProfile = 'favourite-${widget.whichProfile}';
          final likeWhichProfile = 'like-${widget.whichProfile}';
          final disLikeWhichProfile = 'dislike-${widget.whichProfile}';
          like = user[likeWhichProfile] ?? [];
          dislike = user[disLikeWhichProfile] ?? [];
          favourite = user[favouriteWhichProfile] ?? [];
        });
        setState(() {
          imageURL = fetchedURL;
        });
      }
    }
  }

  @override
  void dispose() {
    // Add any cleanup logic here if needed in the future.
    super.dispose();
  }

  Future<void> shareInternetImage(String imageUrl, String fileName) async {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        await Share.shareXFiles([XFile(filePath)],
            text: 'Check out this image!');
      } else {
        print('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sharing image: $e');
    }
  }

  @override
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        400,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  Future<String> getWhichProfileUrl() async {
    try {
      final profileRef = FirebaseStorage.instance
          .ref()
          .child("images/${widget.uid}/${widget.whichProfile}");
      String profileUrl = await profileRef.getDownloadURL();
      return profileUrl;
    } catch (e) {
      if (widget.whichProfile == 'firstProfileImage')
        return _firstURL;
      else if (widget.whichProfile == 'secondProfileImage')
        return _secondURL;
      else if (widget.whichProfile == 'thirdProfileImage') return _thirdURL;
      return _forthURL;
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      // Main UI rendering
      return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            toolbarHeight: 36,
            title: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    child: MyMenuButton(() => setState(() {
                          _setUpProfilePreview();
                        })),
                  )
                ],
              ),
            ),
          ),
          body: Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width * 0.97,
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0),
                                    color: Colors.grey,
                                    image: DecorationImage(
                                      image: NetworkImage(imageURL!),
                                      fit: BoxFit.cover,
                                    ))),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(width: 35),
                            IconButton(
                              onPressed: () async {
                                Map<String, dynamic>? user =
                                    await _authServices.getUserDetail(uid);
                                if (mounted)
                                  setState(() {
                                    _scrollToBottom();
                                    isCommenting = !isCommenting;
                                    username = user?['username'];
                                  });
                              },
                              icon: Icon(Icons.chat_bubble_outline),
                            ),
                            Text(comments.length.toString()),
                            SizedBox(width: 20),
                            Icon(Icons.thumb_up),
                            SizedBox(width: 20),
                            Text(like.length.toString()),
                            SizedBox(width: 20),
                            Icon(Icons.thumb_down),
                            SizedBox(width: 20),
                            Text(dislike.length.toString()),
                            SizedBox(width: 20),
                            Icon(Icons.favorite_outline),
                            SizedBox(width: 20),
                            Text(favourite.length.toString()),
                          ],
                        ),
                        isCommenting
                            ? SizedBox(
                                height: 0,
                              )
                            : SizedBox(
                                height: 50,
                              ),
                        if (isCommenting)
                          Container(
                            height: 300,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors
                                    .white, // Set the border color to white
                                width: 2.0, // Set the width of the border
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(
                                  8.0)), // Optional: Add rounded corners
                            ),
                            child: ListView.builder(
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                var comment = comments[index];
                                var timestamp = comment['timestamp'];
                                var otherUid = comment['uid'];

                                String formattedTimestamp = timestamp != null
                                    ? timestamp
                                        .toDate()
                                        .toString() // Format the timestamp if not null
                                    : 'No timestamp available';

                                return FutureBuilder(
                                  future: _authServices.getDocument(otherUid),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return ListTile(
                                        title: Text(comment['comment']),
                                        subtitle: Text(
                                            'ユーザー: ローディング...'), ///////////////////loading
                                        trailing: Text(formattedTimestamp),
                                      );
                                    }
                                    if (snapshot.hasError) {
                                      return ListTile(
                                        title: Text(comment['comment']),
                                        subtitle:
                                            Text('ユーザー: Error loading user'),
                                        trailing: Text(formattedTimestamp),
                                      );
                                    }

                                    var otherUser = snapshot.data;
                                    var otherUserName =
                                        otherUser?['username'] ??
                                            'Unknown User';

                                    return ListTile(
                                      title: Text(comment['comment']),
                                      subtitle: Text('ユーザー: $otherUserName'),
                                      trailing: Text(formattedTimestamp),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                      bottom: -6,
                      left: 0, // Adjusted to account for padding
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.undo))),
                  Positioned(
                      bottom: -6,
                      right: 0, // Adjusted to account for padding
                      child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => ProfileCameraScreen(
                                  whichProfile: widget.whichProfile,
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.camera_alt))),
                ],
              )));
    } catch (e) {
      // Fallback UI in case of error
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'Error loading image: $e',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }
  }

  Widget MyMenuButton(VoidCallback delete) {
    return SizedBox(
        width: 55,
        child: PopupMenuButton<String>(
          // color: Color.fromRGBO(0, 0, 0, 0),
          offset: Offset(0, 30),
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          menuPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          position: PopupMenuPosition.over,
          child: TextButton(
            onPressed: null,
            child: Text(
              ". . .",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          constraints: BoxConstraints(
            maxHeight: 100,
            maxWidth: 80,
          ),
          onSelected: (value) async {
            if (value == "delete") {
              await profileService.deleteProfile(
                  widget.uid, widget.whichProfile);
              setState(() {
                delete();
              });
              print("Report selected");
            } else if (value == "share") {
              await shareInternetImage(imageURL!, widget.whichProfile);
              Future.delayed(Duration(seconds: 1), () {
                Navigator.of(context).pop();
              });
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                value: "delete",
                child: Container(
                  alignment: Alignment.center,
                  width: 100, // Set width here
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(149, 0, 0, 0),

                    // Background color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: Text(
                    "削除",
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
              PopupMenuItem(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                value: "share",
                child: Container(
                  alignment: Alignment.center,
                  width: 100, // Set width here
                  padding: EdgeInsets.symmetric(
                      vertical: 6, horizontal: 0), // Add padding
                  decoration: BoxDecoration(
                    color:
                        const Color.fromARGB(149, 5, 4, 4), // Background color

                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: Text(
                    "投稿",
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              )
            ];
          },
        ));
  }
}
