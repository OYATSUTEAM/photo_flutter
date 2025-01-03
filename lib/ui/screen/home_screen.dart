import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/services/chat/chat_services.dart';
import 'package:photo_sharing_app/services/other/other_service.dart';
import 'package:photo_sharing_app/ui/camera/camera_screen.dart';
import 'package:photo_sharing_app/ui/myProfile/myProfile.dart';
import 'package:photo_sharing_app/ui/myProfile/profile_preview_screen.dart';
import 'package:photo_sharing_app/ui/other/other_profile_preview_screen.dart';
import 'package:photo_sharing_app/ui/screen/search_user_screen.dart';
import 'package:photo_sharing_app/widgets/my_drawer.dart';

final ChatService _chatService = locator.get();
final AuthServices _authServices = locator.get();
late String fromWhere;

String myProfileURL =
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTqafzhnwwYzuOTjTlaYMeQ7hxQLy_Wq8dnQg&s";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

OtherService otherService = OtherService();

FirebaseAuth _auth = FirebaseAuth.instance;
final User? user = _auth.currentUser;
// final otherService = OtherService(locator.get(), locator.get());

String email = 'default@gmail.com',
    name = 'ローディング...',
    username = 'ローディング...',
    uid = 'default';
List<Map<String, dynamic>> recommendedOtherUsers = [];
List<Map<String, dynamic>> recommendedFollowUsers = [];

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    uid = _authServices.getCurrentuser()!.uid;
    email = _authServices.getCurrentuser()!.email!;
    getCurrentUserUID();
    fetchRecentFiles();
    _setUpHomeScreen();
    _setProfileInitiate();
    fetchUsername();

    super.initState();
  }

  void getCurrentUserUID() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
        email = user.email!;
      });
    }
  }

  Future<void> _setProfileInitiate() async {
    try {
      email = await _authServices.getCurrentuser()!.email!;
      final profileRef =
          FirebaseStorage.instance.ref().child("images/$uid/mainProfileImage");
      // await profileRef.getMetadata();
      String fetchedUrl = await profileRef.getDownloadURL();

      if (mounted) {
        setState(() {
          myProfileURL = fetchedUrl; // Update the state after fetching URL
        });
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> fetchUsername() async {
    try {
      final users = await _chatService.getuserStream().first;

      final user = users.firstWhere(
        (userData) => userData['email'] == email,
        // orElse: () =>  userData['email'] != email,
      );

      setState(() {
        username = user['username'];
      });
    } catch (e) {
      // Handle any errors
      setState(() {
        username = "Error fetching username";
      });
      debugPrint("Error fetching username: $e");
    }
  }

  void fetchRecentFiles() async {
    final fetchedOtherFiles = await otherService.getRecentOtherFiles(uid);
    final fetchedFollowFiles = await otherService.getRecentFollowFiles(uid);
    print('$fetchedOtherFiles!!!!!!!!!!!this is other users ');
    if (mounted)
      setState(() {
        recommendedOtherUsers = fetchedOtherFiles;
        recommendedFollowUsers = fetchedFollowFiles;
      });
  }

  Future<void> _setUpHomeScreen() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            // drawer: MyDrawer(email: email, uid: uid),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.grey,
              elevation: 0,
              title: const Text(
                "ホーム",
                style: TextStyle(fontSize: 20),
              ),
              centerTitle: true,
              toolbarHeight: 30,
            ),
            body: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.74,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Column(children: [
                                TextButton(
                                  child: Text(
                                    'おすすめ',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  onPressed: () {
                                    getCurrentUserUID();
                                    fetchRecentFiles();
                                    _setUpHomeScreen();
                                    _setProfileInitiate();
                                    fetchUsername();
                                  },
                                ),
                                Expanded(
                                    child: ListView.builder(
                                  itemCount: recommendedOtherUsers.length,
                                  itemBuilder: (context, index) {
                                    final profileRef = FirebaseStorage.instance
                                        .ref()
                                        .child(
                                            "${recommendedOtherUsers[index]['fileRef'].fullPath}");

                                    return FutureBuilder<String>(
                                        future: profileRef.getDownloadURL(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                "Error: ${snapshot.error}");
                                          } else if (!snapshot.hasData) {
                                            return Text("No URL available");
                                          }
                                          final profileUrl = snapshot.data!;
                                          return InkWell(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        OtherProfilePreviewScreen(
                                                            whichProfile:
                                                                recommendedOtherUsers[
                                                                            index]
                                                                        [
                                                                        'fileRef']
                                                                    .fullPath
                                                                    .split('/')
                                                                    .last,
                                                            otherUid:
                                                                recommendedOtherUsers[
                                                                        index]
                                                                    ['uid']),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                width: 100,
                                                height: 200,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5,
                                                    horizontal: 10),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0), // Ensure the image fits within the rounded corners
                                                  child: Image.network(
                                                    profileUrl,
                                                    fit: BoxFit
                                                        .cover, // Optionally you can use fit to control how the image fills the container
                                                  ),
                                                ),
                                              ));
                                        });
                                  },
                                ))
                              ])),
                              Expanded(
                                  child: Column(
                                children: [
                         
                               

                                    TextButton(
                                  child: Text(
                                    'フォロー中',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  onPressed: () {
                                    getCurrentUserUID();
                                    fetchRecentFiles();
                                    _setUpHomeScreen();
                                    _setProfileInitiate();
                                    fetchUsername();
                                  },
                                ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: recommendedFollowUsers.length,
                                      itemBuilder: (context, index) {
                                        final profileRef = FirebaseStorage
                                            .instance
                                            .ref()
                                            .child(
                                                "${recommendedFollowUsers[index]['fileRef'].fullPath}");

                                        return FutureBuilder<String>(
                                            future: profileRef.getDownloadURL(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                    "Error: ${snapshot.error}");
                                              } else if (!snapshot.hasData) {
                                                return Text("No URL available");
                                              }
                                              final profileUrl = snapshot.data!;
                                              return InkWell(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ProfilePreviewScreen(
                                                                whichProfile:
                                                                    recommendedFollowUsers[index]
                                                                            [
                                                                            'fileRef']
                                                                        .fullPath
                                                                        .split(
                                                                            '/')
                                                                        .last,
                                                                uid: recommendedFollowUsers[
                                                                        index]
                                                                    ['uid']),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 100,
                                                    height: 200,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5,
                                                            horizontal: 10),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0), // Ensure the image fits within the rounded corners
                                                      child: Image.network(
                                                        profileUrl,
                                                        fit: BoxFit
                                                            .cover, // Optionally you can use fit to control how the image fills the container
                                                      ),
                                                    ),
                                                  ));
                                            });
                                      },
                                    ),
                                  ),
                                ],
                              )),
                            ],
                          )),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              //========================================================  home button======================================
                              IconButton(
                                onPressed: () async {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => MyDrawer(
                                        email: email,
                                        uid: uid,
                                      ),
                                    ),
                                  );
                                },
                                iconSize: 38,
                                icon: const Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                  weight: 90,
                                ),
                              ),
                              //===============================================================post button======================================
                              IconButton(
                                onPressed: () async {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      });
                                  Navigator.pop(context);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => CameraScreen()),
                                  );
                                  if (!mounted) return;
                                },
                                iconSize: 42,
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                              //=================================================== search button ============================================================
                              IconButton(
                                onPressed: () async {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      });
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                  // setState(() {});
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => SearchUser(),
                                    ),
                                  );
                                },
                                iconSize: 40,
                                icon: const Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                              ),
                              //=========================================== avatar button ======================================================

                              FloatingActionButton(
                                backgroundColor: Colors.transparent,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(myProfileURL),
                                  radius: 20,
                                ),
                                onPressed: () async {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      });
                                  _setProfileInitiate();
                                  // Navigator.pop(context);

                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return MyProfile();
                                      },
                                    ),
                                  );
                                },
                              ),

                              ///   transfer button
                            ],
                          )),
                    ],
                  )),
            )));
  }

  Widget RecommendedUsersTile(String imageURL, String whichProfile) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfilePreviewScreen(
              whichProfile: whichProfile,
              uid: uid,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.grey,
                image: DecorationImage(
                  image: NetworkImage(imageURL),
                  fit: BoxFit.cover,
                )),
          ),
        ],
      ),
    );
  }
}
