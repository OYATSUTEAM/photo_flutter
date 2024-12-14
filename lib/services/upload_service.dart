import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:share_plus/share_plus.dart';

class UploadService {
  FirebaseFirestore _database = FirebaseFirestore.instance;
  late DocumentSnapshot documentSnapshot;
  UploadTask? uploadTask;

  String mainURL =
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTqafzhnwwYzuOTjTlaYMeQ7hxQLy_Wq8dnQg&s";
  String secondURL = "https://en.pimg.jp/079/687/576/1/79687576.jpg";
  String firstURL =
      "https://us.123rf.com/450wm/apoev/apoev1806/apoev180600156/103284749-default-placeholder-businessman-half-length-portrait-photo-avatar-man-gray-color.jpg";
  String thirdURL =
      "https://img.freepik.com/premium-photo/default-avatar-profile-icon-gray-placeholder-man-woman-isolated-white-background_660230-21610.jpg";
  String forthURL =
      "https://img.freepik.com/premium-vector/grandparents-icon-vector-image-can-be-used-child-adoption_120816-381816.jpg?semt=ais_hybrid";

  Future uploadFile(
      String uid, String profileURL, String? imageFilePath) async {
    DateTime now = DateTime.now();
    String timestamp = now.toIso8601String();
    SettableMetadata metadata = SettableMetadata(customMetadata: {
      'timestamp': timestamp,
    });

    final ref = FirebaseStorage.instance.ref().child("images/$uid/$profileURL");
    try {
      uploadTask = ref.putFile(File(imageFilePath!), metadata);
      final snapshot = await uploadTask!.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print(
          '$imageFilePath!!!!!!!!!!!this is called and downloadurl is !!!!!!!!!!!!!!!!');
    } catch (e) {
      print('$e this error occurred in my profile.');
    }
  }
}
