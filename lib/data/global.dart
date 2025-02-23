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

  bool isAccountPublic = false;
  String postText = '';

  void updateUser(String email, String uid, String username, String name) {
    myEmail = email;
    myUid = uid;
    myUserName = username;
    myName = name;
  }

  void updataPublic(bool _isAccountPublic) {
    isAccountPublic = _isAccountPublic;
  }

  void updatePostText(String _postText) {
    postText = _postText;
  }
}

// Create a single instance
final globalData = GlobalData();
