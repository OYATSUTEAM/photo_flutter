import 'package:flutter/material.dart';
import 'package:testing/DI/service_locator.dart';
import 'package:testing/services/auth/auth_service.dart';
import 'package:testing/services/chat/chat_services.dart';
import 'package:testing/ui/camera/camera_screen.dart';
import 'package:testing/ui/screen/home_screen.dart';
import 'package:testing/ui/myProfile/myProfile.dart';
import 'package:testing/ui/screen/search_user_screen.dart';
import 'package:testing/widgets/my_drawer.dart';
import 'package:firebase_storage/firebase_storage.dart';

final ChatService _chatService = locator.get();
final AuthServices _authServices = locator.get();

String? username;
late String fromWhere;
final Future<Map<String, dynamic>?> userDetail =
    AuthServices(locator.get(), locator.get()).getUserDetail(uid!);
String? uid;
String? email;
String? myProfileURL;
String _myProfileURL =
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTqafzhnwwYzuOTjTlaYMeQ7hxQLy_Wq8dnQg&s";

class BannerScreen extends StatefulWidget {
  const BannerScreen({super.key});

  @override
  // State<MyProfile> createState() => _BannerScreen();
  _BannerScreen createState() => _BannerScreen();
}

class _BannerScreen extends State<BannerScreen> {
// String userDetailData = '';

  @override
  void initState() {
    super.initState();
    fetchUsername();
    _setProfileInitiate();
  }

  Future<String?> getProfileUrl(String userUid) async {
    try {
      final profileRef =
          FirebaseStorage.instance.ref().child("images/$uid/mainProfileImage");
      String profileUrl = await profileRef.getDownloadURL();

      return profileUrl;
    } catch (e) {
      print('Error getting profile URL: $e');
      return null; // Return null in case of error
    }
  }

  Future<void> _setProfileInitiate() async {
    uid = _authServices.getCurrentuser()!.uid;
    email = _authServices.getCurrentuser()!.email;
    String? fetchedUrl = await getProfileUrl(uid!);

    if (mounted) {
      setState(() {
        myProfileURL = fetchedUrl; // Update the state after fetching URL
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: MyDrawer(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.grey,
          elevation: 0,
          title: const Text("バナー"),
          centerTitle: true,
        ),
        body: Stack(children: [
          Positioned(
            bottom: 30, // 30 pixels from the bottom
            left: 0,
            right: 0,
            child: Container(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    30.0,
                    8.0,
                    30.0,
                    8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ///  home button
                      IconButton(
                        onPressed: () async {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                        },
                        iconSize: 40,
                        icon: const Icon(
                          Icons.home_outlined,
                          color: Colors.white,
                          weight: 100,
                        ),
                      ),
                      //// post button
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
                        iconSize: 40,
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                      /////////////////////////////////////////////////////////////////// //// search button /////////////////////////////////////////////////////////////
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
                          if (!mounted) return;

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
                      ////

                      FloatingActionButton(
                        backgroundColor: Colors.transparent,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(myProfileURL != null
                              ? myProfileURL!
                              : _myProfileURL),
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
                          Navigator.pop(context);

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                // print(userDetail);
                                return MyProfile();
                              },
                            ),
                          );
                        },
                      ),

                      ///   transfer button
                    ],
                  )
                  //   ],
                  // ),
                  ),
            ),
          )
        ]));
  }
}
