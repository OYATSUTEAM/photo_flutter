import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:photo_sharing_app/services/chat/chat_services.dart';
import 'package:photo_sharing_app/services/config.dart';
import 'package:photo_sharing_app/services/notification_service.dart';
import 'package:photo_sharing_app/services/other/other_service.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/ui/camera/post_camera.dart';
import 'package:photo_sharing_app/ui/myProfile/myProfile.dart';
import 'package:photo_sharing_app/ui/other/other_profile_preview_screen.dart';
import 'package:photo_sharing_app/ui/screen/following_screeen.dart';
import 'package:photo_sharing_app/ui/screen/recommended_screen.dart';
import 'package:photo_sharing_app/ui/screen/search_user_screen.dart';
import 'package:photo_sharing_app/widgets/my_drawer.dart';
import 'data/global.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

OtherService otherService = OtherService();
ChatService chatService = locator.get();
final AuthServices authServices = locator.get();
ProfileServices profileServices = ProfileServices();
late String fromWhere;

String myProfileURL = "";

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _pageController;
  late TabController _tabController;
  bool isLoading = true;
  String email = 'default@gmail.com',
      name = 'ローディング...',
      username = 'ローディング...',
      postText = '',
      uid = 'default';
  bool isAccountPublic = false;
  bool loading = true;
  List<Map<String, dynamic>>? recommendedOtherUsers;
  List<Map<String, dynamic>>? recommendedFollowUsers;
  final List<String> allFileListPath = [];
  final List<String> allCacheFileListPath = [];

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.jumpToPage(_tabController.index);
        setState(() {}); // Force rebuild
      }
    });
    _setUpInit();
    _isAndroidPermissionGranted();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    _tabController.dispose();
  }

  bool _notificationsEnabled = false;

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
      setState(() {
        _notificationsEnabled = granted;
      });
    }
  }

  void listenForNewMessages(String currentUserID) {
    try {
      chatService.getAllMessages(currentUserID).listen((snapshot) {
        if (!globalData.isChatScreenOpen) {
          for (var doc in snapshot.docs) {
            var message = doc.data() as Map<String, dynamic>;
            if (message['receiverId'] == currentUserID) {
              NotificationService().showNotification();
            }
          }
        }
      });
    } catch (e, stack) {
      print("Error: $e");
      print(stack);
    }
  }

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
      listenForNewMessages(currentUser!.uid);
      final fetchedFollowFiles = await otherService.getRecentFollowImages(uid);
      final fetchedOtherFiles = await otherService.getRecentImageUrls();
      if (mounted && (userDetail != null)) {
        setState(() {
          isAccountPublic = userDetail['public'];
          name = userDetail['name'];
          username = userDetail['username'];
          uid = currentUser.uid;
          email = currentUser.email!;
          recommendedOtherUsers = fetchedOtherFiles;
          recommendedFollowUsers = fetchedFollowFiles;
          loading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteAllFileWithConfirm(
    BuildContext context,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('削除の確認'),
          content: const Text('すでに撮影した画像を本当に削除しますか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // User pressed Cancel
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // User pressed Delete
              },
              child: const Text('削除', style: TextStyle(color: Colors.red)),
            )
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        setState(() {});
        List<File> filesToRemove = [];
        showDialog(
            context: context,
            builder: (context) {
              return const Center(child: CircularProgressIndicator());
            });
        for (final String filePath in allFileListPath) {
          File file = File(filePath);
          if (await file.exists()) {
            await file.delete(); // Delete each file
            filesToRemove.add(file); // Mark the file for removal
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ファイルが存在しません。')),
            );
          }
        }
        setState(() {});
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ファイルの削除に失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      key: _scaffoldKey,
      drawer: MyDrawer(email: email, uid: uid, setUpInit: _setUpInit),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: TabBar(
          dividerHeight: 0,
          unselectedLabelStyle: TextStyle(color: Colors.grey),
          labelStyle: TextStyle(color: Colors.white),
          controller: _tabController,
          tabs: [
            Tab(
                height: 50,
                child: TabCard(
                    isSelected: _tabController.index == 0, title: 'おすすめ')),
            Tab(
                height: 50,
                child: TabCard(
                    isSelected: _tabController.index == 1, title: 'フォロー'))
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            Expanded(
                child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _tabController.index = index;
                  _setUpInit();
                });
              },
              children: [
                RecommendedScreen(
                    recommendedOtherUsers: recommendedOtherUsers == null
                        ? []
                        : recommendedOtherUsers!,
                    setUpInit: _setUpInit),
                FollowingScreeen(setUpInit: _setUpInit, recommendedFollowUsers: recommendedFollowUsers == null
                        ? []
                        : recommendedFollowUsers!)
              ],
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
//===================================================                             home button======================================

                IconButton(
                  onPressed: () async {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  iconSize: 38,
                  icon: const Icon(Icons.settings,
                      color: Colors.white, weight: 90),
                ),

//===================================================                             post button======================================

                IconButton(
                    onPressed: () async {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const Center(
                                child: CircularProgressIndicator());
                          });
                      List<File> filesToRemove = [];

                      for (final String filePath in allCacheFileListPath) {
                        File file = File(filePath);
                        if (await file.exists()) {
                          await file.delete();
                          filesToRemove.add(file);
                        }
                      }
                      if (!mounted) return;
                      globalData.updatePostText('');
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              PostCameraScreen(isDelete: true)));
                    },
                    iconSize: 42,
                    icon: const Icon(Icons.add, color: Colors.white)),

//===================================================                             search button      ===================================

                IconButton(
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const Center(
                              child: CircularProgressIndicator());
                        });
                    if (!mounted) return;
                    // await NotificationService().showNotification();

                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SearchUser(),
                      ),
                    );
                  },
                  iconSize: 40,
                  icon: const Icon(Icons.search, color: Colors.white),
                ),
//===================================================   avatar button ===================================

                IconButton(
                    icon: CircleAvatar(
                      backgroundImage: AssetImage('assets/avatar.png'),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      BuildContext dialogContext = context;
                      showDialog(
                          context: dialogContext,
                          barrierDismissible: false,
                          builder: (context) {
                            return const Center(
                                child: CircularProgressIndicator());
                          });
                      await Future.delayed(Duration(milliseconds: 50));
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return MyProfileScreen();
                          },
                        ),
                      );
                    }),
              ],
            )
          ],
        ),
      ),
    ));
  }
}

class TabCard extends StatelessWidget {
  final bool isSelected;
  final String title;
  const TabCard({super.key, required this.isSelected, required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(fontSize: 20));
  }
}
