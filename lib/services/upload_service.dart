import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:http/http.dart';
import 'package:photo_sharing_app/data/global.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';

class UploadService {
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
}

Future<void> uploadFile(
    String uid, String profileURL, String imageFilePath) async {
  DateTime now = DateTime.now();
  String timestamp = now.toIso8601String();
  // Set metadata with timestamp
  SettableMetadata metadata = SettableMetadata(customMetadata: {
    'timestamp': timestamp,
    'public': 'false', // Custom flag; does not affect actual public access
  });

  final ref = FirebaseStorage.instance.ref().child("images/$uid/$profileURL");

  try {
    UploadTask uploadTask = ref.putFile(File(imageFilePath), metadata);
    await uploadTask.whenComplete(() => null);

    String downloadURL = await ref.getDownloadURL();
    print("File uploaded successfully: $downloadURL");
  } catch (e) {
    print('$e this error occurred in my profile.');
  }
}

Future<void> addToPostedImages(
    String uid, String name, String imagePath) async {
  try {
    String imageURL = await uploadImage(uid, name, imagePath);
    await addToPosted(imageURL, uid);
  } catch (e) {
    print('$e this error occurred in my profile.');
  }
}

Future<String> uploadImage(String uid, String name, String imagePath) async {
  DateTime now = DateTime.now();
  String timestamp = now.toIso8601String();
  SettableMetadata metadata =
      SettableMetadata(customMetadata: {'timestamp': timestamp, 'uid': uid});
  final ref = FirebaseStorage.instance
      .ref()
      .child("images/$uid/postedImages/$timestamp");
  try {
    UploadTask uploadTask = ref.putFile(File(imagePath), metadata);
    await uploadTask.whenComplete(() => null);
    String getDownloadURL = await ref.getDownloadURL();
    addImageUrl(getDownloadURL, uid);

    return getDownloadURL;
  } catch (e) {
    print('$e this error occurred in my profile.');
    return '';
  }
}

Future<void> addToPosted(String imageUrl, String uid) async {
  DateTime now = DateTime.now();
  String timestamp = now.toIso8601String();
  bool accoutPublic = globalData.isAccountPublic;
  try {
    CollectionReference images =
        FirebaseFirestore.instance.collection('PublicImageList');

    Map<String, dynamic> imageObject = {
      'url': imageUrl,
      'uid': uid,
      'timestamp': timestamp, // Firestore server timestamp
      'public': accoutPublic
    };

    // Add the new image object to an array
    DocumentSnapshot docSnapshot = await images.doc('imagesDoc').get();

    if (docSnapshot.exists) {
      await images.doc('imagesDoc').update(
        {
          'imageUrls': FieldValue.arrayUnion([imageObject])
        },
      );
    } else {
      await images.doc('imagesDoc').set({
        'imageUrls': [imageObject]
      }, SetOptions(merge: true));
    }

    print("Image URL added successfully!");
  } catch (e) {
    print("Error adding image URL: $e");
  }
}
