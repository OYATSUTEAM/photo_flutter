// import 'dart:io';

// import 'package:path_provider/path_provider.dart';

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

  String otherEmail = "default@gmail.com";
  String otherUid = '1234567890';
  String otherUserName = 'defaultUserName';
  String otherName = 'defaultName';

  bool isAccountPublic = false;
  String postText = '';

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

  updataPublic(bool _isAccountPublic) async {
    isAccountPublic = _isAccountPublic;
  }

  updatePostText(String _postText) async {
    postText = _postText;
  }
}

// Create a single instance
final globalData = GlobalData();
