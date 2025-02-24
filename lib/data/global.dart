// import 'dart:io';

// import 'package:path_provider/path_provider.dart';

import 'dart:io';

import 'package:path_provider/path_provider.dart';

class GlobalData {
  static final GlobalData _instance = GlobalData._internal();
  factory GlobalData() {
    return _instance;
  }

  GlobalData._internal();

  String myEmail = "default@gmail.com";
  String myUid = '1234567890';
  String myUserName = 'defaultUserName';
  String myName = 'defaultName';
  String profileURL =
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTqafzhnwwYzuOTjTlaYMeQ7hxQLy_Wq8dnQg&s";

  String postText = "default";
  String otherEmail = "default@gmail.com";
  String otherUid = '1234567890';
  String otherUserName = 'defaultUserName';
  String otherName = 'defaultName';
  bool isAccountPublic = false;

  Directory appDir = Directory('');
  updateUser(String email, String uid, String username, String name) async {
    myEmail = email;
    myUid = uid;
    myUserName = username;
    myName = name;
  }

  updateOther(String email, String uid, String username, String name) async {
    otherEmail = email;
    otherUid = uid;
    otherUserName = username;
    otherName = name;
  }

  updatePublic(bool isAccountPublic1) async {
    isAccountPublic = isAccountPublic1;
  }

  updatePostText(String text) async {
    postText = text;
  }

  getAppDir() async {
    appDir = await getApplicationDocumentsDirectory();
  }
}

// Create a single instance
final globalData = GlobalData();
