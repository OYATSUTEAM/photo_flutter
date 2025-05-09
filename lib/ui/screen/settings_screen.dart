import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_sharing_app/bloc/theme_bloc.dart';
import 'package:photo_sharing_app/bloc/theme_event.dart';
import 'package:photo_sharing_app/data/global.dart';
import 'package:photo_sharing_app/services/config.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/theme/theme_manager.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.setUpInit});
  final VoidCallback setUpInit;
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

ProfileServices profileServices = ProfileServices();

FirebaseAuth _auth = FirebaseAuth.instance;
final User? user = _auth.currentUser;
bool switchResult = ThemeManager.readTheme();

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    getCurrentUserUID();
    super.initState();
  }

  String email = 'default@gmail.com',
      name = 'ローディング...',
      username = 'ローディング...',
      uid = 'default';
  void getCurrentUserUID() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profilePublic = await isPublicAccount(user.uid);
      setState(() {
        switchResult = profilePublic;
        uid = user.uid;
        email = user.email!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("公開設定")),
      body: GestureDetector(
        onTap: () async {
          context.read<ThemeBloc>().add(ThemeDarkedMode());
          setState(() {
            switchResult = !switchResult;
          });
          if (switchResult) {
            widget.setUpInit();
            ThemeManager.saveTheme(true);
            await globalData.updatePublic(true);
            await publicAccount(uid, true);
          } else {
            widget.setUpInit();
            ThemeManager.saveTheme(false);
            await publicAccount(uid, false);
            await globalData.updatePublic(false);
          }
        },
        child: Container(
          margin: const EdgeInsets.all(25.0),
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: const BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("公開"),
              CupertinoSwitch(
                value: switchResult,
                onChanged: (value) {},
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
