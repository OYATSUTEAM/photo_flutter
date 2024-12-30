import 'package:flutter/material.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/ui/other/blocked_users.dart';
import 'package:photo_sharing_app/ui/screen/cookie_screen.dart';
import 'package:photo_sharing_app/ui/screen/follow_follower_screen.dart';
import 'package:photo_sharing_app/ui/other/etc_screen.dart';
import 'package:photo_sharing_app/ui/screen/manager_screen.dart';
import 'package:photo_sharing_app/ui/screen/report_block_screen.dart';
import 'package:photo_sharing_app/ui/screen/settings_screen.dart';
import 'package:photo_sharing_app/ui/screen/terms_screen.dart';
import 'package:photo_sharing_app/widgets/my_button.dart';
import 'package:photo_sharing_app/ui/other/other_users.dart';

class MyDrawer extends StatelessWidget {
  final String email;
  const MyDrawer({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Drawer(
            width: MediaQuery.of(context).size.width * 0.9,
            backgroundColor: const Color.fromARGB(255, 29, 29, 29),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "設定",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  MyButton(
                    text: "利用規約", //terms of service
                    onTap: () async {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TermsOfUsePage(),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  MyButton(
                    text: "公開設定", //public setting
                    onTap: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  MyButton(
                    text: "プライバシーポリシー", //privacy policy
                    onTap: () async {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CookieScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  MyButton(
                    text: "その他", //others
                    onTap: () async {
                      // Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EtcScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  MyButton(
                    text: "他のユーザー", //others
                    onTap: () async {
                      // final finalContext = context;

                      // Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => OtherUsers(),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  MyButton(
                    text: "フォローとフォロワー",
                    onTap: () async {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FollowAndFollower(),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  MyButton(
                    text: "ブロックとブロックされた",
                    onTap: () async {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlockedUsers(),
                        ),
                      );
                    },
                  ),
                  if (email == 'topadminmanager123456@gmail.com')
                    SizedBox(
                      height: 15,
                    ),
                  if (email == 'topadminmanager123456@gmail.com')
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
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.23,
                  ),
                  MyButton(
                      text: "ログアウト",
                      color: Colors.red,
                      onTap: () async {
                        print('logout is called');
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            });
                        await AuthServices(locator.get(), locator.get())
                            .signOut();
                        Navigator.pop(context);
                      }),
                ],
              ),
            )));
  }
}
