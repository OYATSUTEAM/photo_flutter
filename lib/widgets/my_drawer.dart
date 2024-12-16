import 'package:flutter/material.dart';
import 'package:testing/DI/service_locator.dart';
import 'package:testing/services/auth/auth_service.dart';
import 'package:testing/ui/screen/follow_follower_screen.dart';
import 'package:testing/ui/other/etc_screen.dart';
import 'package:testing/ui/screen/settings_screen.dart';
import 'package:testing/widgets/my_button.dart';
import 'package:testing/ui/other/other_users.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Drawer(
            width: MediaQuery.of(context).size.width * 0.9,
            backgroundColor: const Color.fromARGB(255, 14, 12, 12),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                        onTap: () async {},
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
                        onTap: () async {},
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      MyButton(
                        text: "その他", //others
                        onTap: () async {
                          // final finalContext = context;

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
                        height: 175,
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
                ])));
  }
}
