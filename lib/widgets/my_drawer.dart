import 'package:flutter/material.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/ui/auth/login_screen.dart';
import 'package:photo_sharing_app/ui/other/blocked_users.dart';
import 'package:photo_sharing_app/ui/screen/cookie_screen.dart';
import 'package:photo_sharing_app/ui/screen/follow_follower_screen.dart';
import 'package:photo_sharing_app/ui/screen/home_screen.dart';
import 'package:photo_sharing_app/ui/screen/manager_screen.dart';
import 'package:photo_sharing_app/ui/screen/settings_screen.dart';
import 'package:photo_sharing_app/ui/screen/terms_screen.dart';
import 'package:photo_sharing_app/widgets/my_button.dart';
import 'package:photo_sharing_app/ui/other/other_users.dart';
import 'package:firebase_auth/firebase_auth.dart';

ProfileServices profileServices = ProfileServices();

class MyDrawer extends StatefulWidget {
  final String email, uid;
  const MyDrawer({super.key, required this.email, required this.uid});
  @override
  _MyDrawer createState() => _MyDrawer();
}

class _MyDrawer extends State<MyDrawer> {
  @override
  Future<void> deleteFileWithConfirmation(
    BuildContext context,
  ) async {
    bool isMounted = mounted;
    User? user = FirebaseAuth.instance.currentUser;
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('削除確認'),
          content: const Text('本当にこのアカウントを削除しますか？'),
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
              child: const Text(
                '削除',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
    if (shouldDelete == true) {
      try {
        showDialog(
            context: context,
            builder: (context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            });
        await deleteAccount(widget.uid);
        if (user != null) {
          await user.delete();
          print("Account deleted successfully");
        } else {
          print("No user is currently signed in.");
        }
        await AuthServices(locator.get(), locator.get()).signOut();
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }

  Widget build(BuildContext context) {
    return SafeArea(
        child: Drawer(
            width: MediaQuery.of(context).size.width * 0.9,
            // backgroundColor: const Color.fromARGB(255, 29, 29, 29),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 20),
                  Stack(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ));
                          },
                          icon: Icon(Icons.arrow_back)),
                      Align(
                        alignment: Alignment.center,
                        child: Text("設定",
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
                      )
                    ],
                  ),
                  SizedBox(height: 5),
                  MyButton(
                    text: "利用規約", //terms of service
                    onTap: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => TermsOfUsePage()),
                      );
                    },
                  ),
                  SizedBox(height: 15),
                  MyButton(
                    text: "公開設定", //public setting
                    onTap: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => SettingsScreen()),
                      );
                    },
                  ),
                  SizedBox(height: 15),
                  MyButton(
                    text: "プライバシーポリシー", //privacy policy
                    onTap: () async {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CookieScreen()));
                    },
                  ),
                  SizedBox(height: 15),
                  MyButton(
                    text: "他のユーザー", //others
                    onTap: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => OtherUsers()),
                      );
                    },
                  ),
                  SizedBox(height: 15),
                  MyButton(
                    text: "フォローとフォロワー",
                    onTap: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => FollowAndFollower()),
                      );
                    },
                  ),
                  SizedBox(height: 15),
                  MyButton(
                    text: "ブロックとブロックされた",
                    onTap: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlockedUsers(),
                        ),
                      );
                    },
                  ),
                  if (widget.email == 'topadminmanager123456@gmail.com')
                    SizedBox(
                      height: 15,
                    ),
                  if (widget.email == 'topadminmanager123456@gmail.com')
                    MyButton(
                      text: "ステータス管理",
                      onTap: () async {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ManagerScreen(),
                          ),
                        );
                      },
                    ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                  MyButton(
                      text: "ログアウト",
                      color: Colors.red,
                      onTap: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            });
                        await AuthServices(locator.get(), locator.get())
                            .signOut();
                        if (mounted) {
                          // Navigator.pop(context);
                          // Navigator.pop(context);
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return LoginScreen();
                          }));
                        }
                      }),
                  SizedBox(height: 15),
                  MyButton(
                    text: "アカウント削除",
                    color: Colors.red,
                    onTap: () async {
                      deleteFileWithConfirmation(context);
                    },
                  ),
                ],
              ),
            )));
  }
}
