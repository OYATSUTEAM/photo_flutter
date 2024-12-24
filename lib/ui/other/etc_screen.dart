import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photo_sharing_app/services/other/other_service.dart';
import 'package:photo_sharing_app/ui/camera/profile_preview_screen.dart';

class EtcScreen extends StatefulWidget {
  const EtcScreen({super.key});

  @override
  State<EtcScreen> createState() => _EtcScreenState();
}

FirebaseAuth _auth = FirebaseAuth.instance;
final User? user = _auth.currentUser;
// final otherService = OtherService(locator.get(), locator.get());
OtherService otherService = OtherService();

List<Map<String, dynamic>> recommendedOtherUsers = [];
List<Map<String, dynamic>> recommendedFollowUsers = [];

class _EtcScreenState extends State<EtcScreen> {
  @override
  void initState() {
    getCurrentUserUID();
    fetchRecentFiles();
    _setUpEtcScreen();
    super.initState();
  }

  String email = 'default@gmail.com',
      name = 'ローディング...',
      username = 'ローディング...',
      uid = 'default';
  void getCurrentUserUID() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
        email = user.email!;
      });
    }
  }

  void fetchRecentFiles() async {
    final fetchedOtherFiles =
        await otherService.getRecentOtherFilesAfter3days(uid);
    final fetchedFollowFiles =
        await otherService.getRecentFollowFilesAfter3days(uid);
    if (mounted)
      setState(() {
        recommendedOtherUsers = fetchedOtherFiles;
        recommendedFollowUsers = fetchedFollowFiles;
      });
  }

  Future<void> _setUpEtcScreen() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        title: const Text(
          "その他",
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
        toolbarHeight: 30,
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                  child: Column(
                children: [
                  // SizedBox(
                  //   height: 30,
                  // ),
                  Text(
                    'おすすめ',
                    style: TextStyle(fontSize: 16),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: recommendedOtherUsers.length,
                      itemBuilder: (context, index) {
                        final profileRef = FirebaseStorage.instance.ref().child(
                            "${recommendedOtherUsers[index]['fileRef'].fullPath}");

                        return FutureBuilder<String>(
                            future: profileRef.getDownloadURL(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Text("Error: ${snapshot.error}");
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
                                                    recommendedOtherUsers[index]
                                                            ['fileRef']
                                                        .fullPath
                                                        .split('/')
                                                        .last,
                                                uid:
                                                    recommendedOtherUsers[index]
                                                        ['uid']),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 200,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
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
              Expanded(
                  child: Column(
                children: [
                  // SizedBox(
                  //   height: 30,
                  // ),
                  Text(
                    'フォロー中',
                    style: TextStyle(fontSize: 16),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: recommendedFollowUsers.length,
                      itemBuilder: (context, index) {
                        final profileRef = FirebaseStorage.instance.ref().child(
                            "${recommendedFollowUsers[index]['fileRef'].fullPath}");

                        return FutureBuilder<String>(
                            future: profileRef.getDownloadURL(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Text("Error: ${snapshot.error}");
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
                                                    recommendedFollowUsers[
                                                            index]['fileRef']
                                                        .fullPath
                                                        .split('/')
                                                        .last,
                                                uid: recommendedFollowUsers[
                                                    index]['uid']),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 200,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
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
    ));
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
