import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:photo_sharing_app/data/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileServices {
  FirebaseFirestore database = FirebaseFirestore.instance;
  late final DocumentSnapshot documentSnapshot;
  final firestore = FirebaseStorage;

  String mainURL = globalData.profileURL;
  String secondURL = "";
  String firstURL = "";
  String thirdURL = "";
  String forthURL = "";

  Future<bool> isUserBlocked(String currentUserUid, String otherUid) async {
    try {
      // Reference to the user's document
      final docRef =
          FirebaseFirestore.instance.collection('Users').doc(currentUserUid);

      // Fetch the user's document
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Get the block list
        List<dynamic> blockList = docSnapshot.data()?['block'] ?? [];

        // Check if the otherUid is in the block list
        return blockList.contains(otherUid);
      } else {
        print("User document not found.");
        return false;
      }
    } catch (e) {
      print("Error checking block list: $e");
      return false;
    }
  }

  Future<bool> isMeBlocked(String currentUserUid, String otherUid) async {
    try {
      // Reference to the user's document
      final docRef =
          FirebaseFirestore.instance.collection('Users').doc(otherUid);

      // Fetch the user's document
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Get the block list
        List<dynamic> blockList = docSnapshot.data()?['blocked'] ?? [];

        // Check if the otherUid is in the block list
        return blockList.contains(currentUserUid);
      } else {
        print("User document not found.");
        return false;
      }
    } catch (e) {
      print("Error checking block list: $e");
      return false;
    }
  }

  Future<bool> isBlockTrue() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("Status_Manage")
          .doc('manage_status')
          .get();
      bool isBlockTrue = userSnapshot.get('block');
      return isBlockTrue;
    } catch (e) {
      print("Error fetching document: $e");
      return false;
    }
  }

  Future<bool> isReportTrue() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("Status_Manage")
          .doc('manage_status')
          .get();
      bool isReportTrue = userSnapshot.get('report');
      return isReportTrue;
    } catch (e) {
      print("Error fetching document: $e");
      return false;
    }
  }

  Future<void> updateProfile(
    String? uid,
    String? name,
    String? username,
    String? email,
  ) async {
    try {
      await database.collection("Users").doc(uid).update({
        'name': name,
        'username': username,
      });
    } catch (e) {
      print("Error updating profile: $e");
    }
  }
}

Future<void> updatePassword(String uid, String password) async {
  try {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .update({'password': password});
  } catch (e) {
    print("Error updating profile: $e");
  }
}

Future<Map<String, dynamic>?> getUserDetail(String uid) async {
  // final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    final DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection("Users").doc(uid).get();

    if (documentSnapshot.exists) {
      return documentSnapshot.data() as Map<String, dynamic>?;
    } else {
      print("No document found.");
      return null;
    }
  } catch (e) {
    print("Error fetching document: $e");
    return null;
  }
}

Future<String> getEditProfileUrl(String uid) async {
  String mainURL = globalData.profileURL;

  try {
    final profileRef =
        FirebaseStorage.instance.ref().child("images/$uid/editProfileImage");
    String profileUrl = await profileRef.getDownloadURL();
    return profileUrl;
  } on FirebaseException catch (e) {
    print('Firebase Storage error: ${e.code} - ${e.message}');
    return mainURL;
  } catch (e) {
    print('General error: $e');
    return mainURL;
  }
}

Future<String> getMainProfileUrl(String uid) async {
  String mainURL = globalData.profileURL;

  try {
    final profileRef =
        FirebaseStorage.instance.ref().child("images/$uid/profileImage");
    String profileUrl = await profileRef.getDownloadURL();
    return profileUrl;
  } on FirebaseException catch (e) {
    print('Firebase Storage error: ${e.code} - ${e.message}');
    return mainURL;
  } catch (e) {
    print('General error: $e');
    return mainURL;
  }
}

Future<void> deleteProfile(String uid, String imageName) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference storageRef =
      storage.ref().child('images/$uid/postedImages/$imageName');

  try {
    // Delete the file
    await storageRef.delete();
    print('File deleted successfully!');
  } catch (e) {
    print('Error deleting file: $e');
  }
}

publicAccount(String uid, bool isPublic) async {
  // Step 1: Try to get the URL for the main profile image
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  try {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .update({'public': isPublic});

    DocumentReference docRef =
        firestore.collection("PublicImageList").doc("imagesDoc");
    DocumentSnapshot docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      List<dynamic> imageUrls = docSnapshot["imageUrls"];
      List<dynamic> updatedImageUrls = imageUrls.map((image) {
        if (image["uid"] == uid) {
          return {
            ...image, // Copy other fields
            "public": isPublic, // Update public status
          };
        }
        return image;
      }).toList();

      // Update Firestore document
      await docRef.update({"imageUrls": updatedImageUrls});
    } else {}
  } catch (e) {
    print("Error updating public status: $e");
  }
}

Future<List<String>> getRecentImageUrls() async {
  DocumentSnapshot doc = await FirebaseFirestore.instance
      .collection('PublicImageList')
      .doc('imagesDoc')
      .get();

  if (doc.exists) {
    List<dynamic> images = doc['imageUrls'];

    // Get current time and subtract 3 days
    DateTime threeDaysAgo = DateTime.now().subtract(Duration(days: 3));

    // Filter the URLs added within the last 3 days
    List<String> recentUrls = images
        .where((image) => image['timestamp'] != null) // Ensure timestamp exists
        .where((image) =>
            (image['timestamp'] as Timestamp).toDate().isAfter(threeDaysAgo))
        .map((image) => image['url'] as String)
        .toList();

    return recentUrls;
  } else {
    return [];
  }
}

// Future<ListResult> getProfileURLs(String uid) async {
//   ListResult listResult = [] as ListResult;
//   try {
//     List<String> publicImageUrls = [];

//     final storageRef =
//         FirebaseStorage.instance.ref("images/$uid/profileImages");

//     final ListResult result = await storageRef.listAll();

//     return result;
//   } catch (e) {
//     print("Error fetching public image URLs: $e");
//     return listResult;
//   }
// }

Future<bool> isPublicAccount(String uid) async {
  try {
    final ref =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    return ref.get('public');
  } catch (e) {
    print(e);
    return true;
  }
}

//================================================================================================================================
//================================================================================================================================
//================================================================================================================================
//================================================================================================================================
//================================================================================================================================
//================================================================================================================================
//================================================================================================================================
//================================================================================================================================
//================================================================================================================================
Stream<Map<String, List<Map<String, dynamic>>>> getImageNames(
    String uid) async* {
  final docRef = FirebaseFirestore.instance.collection("Users").doc(uid);

  await for (var documentSnapshot in docRef.snapshots()) {
    if (!documentSnapshot.exists) {
      yield {"latest": [], "others": []}; // Return empty if no data exists
      continue;
    }

    List<dynamic> otherArray = documentSnapshot.get('imageUrls') ?? [];

    // Safely parse timestamp
    otherArray.sort((a, b) {
      Timestamp tsA = _parseTimestamp(a['timestamp']);
      Timestamp tsB = _parseTimestamp(b['timestamp']);
      return tsB.compareTo(tsA); // Sort in descending order
    });

    List<Map<String, dynamic>> latestImages = [];
    List<Map<String, dynamic>> otherImages = [];

    for (int i = 0; i < otherArray.length; i++) {
      var imageData = {
        'url': otherArray[i]['url'],
        'status': otherArray[i]['public'],
        'name': otherArray[i]['name']
      };

      if (i < otherArray.length / 2) {
        latestImages.add(imageData);
      } else {
        otherImages.add(imageData);
      }
    }

    print('${latestImages}${otherImages}============');
    yield {
      "latest": latestImages,
      "others": otherImages,
    };
  }
}

// Helper function to safely parse timestamp
Timestamp _parseTimestamp(dynamic timestamp) {
  if (timestamp is Timestamp) {
    return timestamp;
  } else if (timestamp is String) {
    return Timestamp.fromMillisecondsSinceEpoch(
        DateTime.parse(timestamp).millisecondsSinceEpoch);
  } else if (timestamp is int) {
    return Timestamp.fromMillisecondsSinceEpoch(timestamp);
  }
  return Timestamp.now(); // Default to current time if format is unknown
}

Future<Map<String, List<Map<String, dynamic>>>> getOtherImageNames(
    String uid) async {
  final collectionRef = FirebaseFirestore.instance
      .collection("profileImages")
      .doc(uid)
      .collection("images");

  final querySnapshot =
      await collectionRef.orderBy('timestamp', descending: true).get();

  List<Map<String, dynamic>> latestImages = [];
  List<Map<String, dynamic>> otherImages = [];

  for (int i = 0; i < querySnapshot.docs.length; i++) {
    var doc = querySnapshot.docs[i];
    Map<String, dynamic> imageData = {
      'name': doc.id, // Image name (doc ID)
      'status': doc['status'], // Image status
    };

    if (i < querySnapshot.docs.length / 2) {
      latestImages.add(imageData);
    } else {
      otherImages.add(imageData);
    }
  }

  return {
    "latest": latestImages,
    "others": otherImages,
  };
}

Future<String> getUserPassword(String uid) async {
  final DocumentSnapshot documentSnapshot;
  try {
    documentSnapshot =
        await FirebaseFirestore.instance.collection("Users").doc(uid).get();
    if (documentSnapshot.exists && documentSnapshot.data() != null) {
      return documentSnapshot.get('password');
    }
    return '123456';
  } catch (e) {
    print("Error fetching document: $e");
    return '123456';
  }
}

Future<String> getUserName(String uid) async {
  final DocumentSnapshot documentSnapshot;
  try {
    documentSnapshot =
        await FirebaseFirestore.instance.collection("Users").doc(uid).get();
    if (documentSnapshot.exists && documentSnapshot.data() != null) {
      return documentSnapshot.get('name');
    }
    return 'ローディング...';
  } catch (e) {
    print("Error fetching document: $e");
    return 'ユーザー読み込みエラー';
  }
}

Future<String> getUserUsername(String uid) async {
  final DocumentSnapshot documentSnapshot;
  try {
    documentSnapshot =
        await FirebaseFirestore.instance.collection("Users").doc(uid).get();
    if (documentSnapshot.exists && documentSnapshot.data() != null) {
      return documentSnapshot.get('username');
    }
    return 'ローディング...';
  } catch (e) {
    print("Error fetching document: $e");
    return 'ユーザー読み込みエラー';
  }
}

Future<String> profileShowAll(String uid) async {
  try {
    final ref =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    final isShowAll = ref.get('isShowAll');
    if (!isShowAll) {
      return ref.get('whichIsDisplayed');
    }
    return 'showAll';
  } catch (e) {
    print(e);
    return 'first';
  }
}

Future<void> reportThisUser(
    String uid, String otherUid, String reportContent) async {
  DateTime time = DateTime.now();
  try {
    // Define the Firestore reference path
    final reportRef = FirebaseFirestore.instance
        .collection("Reports")
        .doc(uid)
        .collection("Users")
        .doc(otherUid);

    // Update the report content and time
    await reportRef.set({
      'reportContent': reportContent,
      'time': time.toIso8601String(), // Convert DateTime to a string format
    });

    print("Report updated successfully");
  } catch (e) {
    print("Error updating report: $e");
  }
}

Future<List<dynamic>?>? getBlockedUsers(String uid) async {
  try {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("Users").doc(uid);

    DocumentSnapshot documentSnapshot = await documentReference.get();

    if (documentSnapshot.exists) {
      List<dynamic>? blokedUser = documentSnapshot.get('block');

      if (blokedUser != null) {
        return blokedUser;
      } else {
        print("'blocked' field is null or not an array.");
        return null;
      }
    } else {
      print("Document does not exist.");
      return null;
    }
  } catch (e) {
    print("Failed to get 'blocked' array: $e");
    return null;
  }
}

Future<List<dynamic>?>? getBlockedMeUsers(String uid) async {
  try {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("Users").doc(uid);

    DocumentSnapshot documentSnapshot = await documentReference.get();

    if (documentSnapshot.exists) {
      List<dynamic>? blokedUser = documentSnapshot.get('blocked');

      if (blokedUser != null) {
        return blokedUser;
      } else {
        print("'blocked' field is null or not an array.");
        return null;
      }
    } else {
      print("Document does not exist.");
      return null;
    }
  } catch (e) {
    print("Failed to get 'blocked' array: $e");
    return null;
  }
}

Future<bool> getCommentStatus() async {
  try {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection("Status_Manage")
        .doc('manage_status')
        .get();
    bool isCommentTrue = userSnapshot.get('comments');
    return isCommentTrue;
  } catch (e) {
    print("Error fetching document: $e");
    return false;
  }
}

Future<void> setBlockStatus(bool status) async {
  try {
    await FirebaseFirestore.instance
        .collection("Status_Manage")
        .doc('manage_status')
        .update({'block': status});
  } catch (e) {
    print("Error updating profile: $e");
  }
}

Future<void> setCommentStatus(bool status) async {
  try {
    await FirebaseFirestore.instance
        .collection("Status_Manage")
        .doc('manage_status')
        .update({'comments': status});
  } catch (e) {
    print("Error updating profile: $e");
  }
}

Future<void> setReportStatus(bool status) async {
  try {
    await FirebaseFirestore.instance
        .collection("Status_Manage")
        .doc('manage_status')
        .update({'report': status});
  } catch (e) {
    print("Error updating profile: $e");
  }
}

Future<void> deleteAccount(String uid) async {
  try {
    await FirebaseFirestore.instance.collection("Users").doc(uid).delete();
    print("Account deleted successfully");
  } catch (e) {
    print("Error deleting account: $e");
  }
}

Future<void> publicThisImage(String uid, String dirpath) async {
  try {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child("images/$uid/profileImages/$dirpath");

    final metadata = await storageRef.getMetadata();

    String currentPublicStatus = metadata.customMetadata?['public'] ?? 'false';
    bool newStatus = currentPublicStatus == 'true' ? false : true;

    SettableMetadata updatedMetadata = SettableMetadata(
      customMetadata: {
        'timestamp': metadata.customMetadata?['timestamp'] ??
            DateTime.now().toIso8601String(),
        'public': newStatus.toString(),
      },
    );

    await storageRef.updateMetadata(updatedMetadata);

    final imageUrl = await storageRef.getDownloadURL();
    print("Image metadata updated successfully. Image URL: $imageUrl");
  } catch (e) {
    print("Error updating profile: $e");
  }
}

Future<bool> getDirPathStatus(String uid, String dirpath) async {
  try {
    // Get a reference to the image in Firebase Storage
    final storageRef = FirebaseStorage.instance
        .ref()
        .child("images/$uid/profileImages/$dirpath");

    final metadata = await storageRef.getMetadata();

    String publicStatus = metadata.customMetadata?['public'] ?? 'false';

    return publicStatus == 'true';
  } catch (e) {
    print("Error getting dirpath status: $e");
    return false; // Default to false in case of an error
  }
}

Future<void> deleteThisImage(String uid, String name) async {
  try {} catch (e) {
    print("Error updating profile: $e");
  }
}

Future<void> addImageUrl(String imageUrl, String uid) async {
  DateTime now = DateTime.now();
  String timestamp = now.toIso8601String();
  try {
    if (globalData.isAccountPublic) {
      CollectionReference images =
          FirebaseFirestore.instance.collection('PublicImageList');

      // Create an image object with URL and timestamp
      Map<String, dynamic> imageObject = {
        'url': imageUrl,
        'uid': uid,
        'timestamp': timestamp, // Firestore server timestamp
        'public': true
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

      print("Image URL added successfully! add image url");
    }
  } catch (e) {
    print("Error adding image URL: $e");
  }
}

Future<void> removeImage(String uid, String name) async {
  final docRef1 = FirebaseFirestore.instance.collection("Users").doc(uid);
  final docRef2 =
      FirebaseFirestore.instance.collection("PublicImageList").doc('imagesDoc');

  final docSnapshot1 = await docRef1.get();
  final docSnapshot2 = await docRef2.get();

  if (docSnapshot1.exists) {
    List<dynamic> imageUrls =
        List.from(docSnapshot1.data()?['imageUrls'] ?? []);

    // Filter out the image that needs to be deleted
    List<dynamic> updatedImages =
        imageUrls.where((img) => img['name'] != name).toList();

    // Update Firestore with the new list
    await docRef1.update({'imageUrls': updatedImages});

    print("Image removed successfully!");
  } else {
    print("User document does not exist.");
  }

  if (docSnapshot2.exists) {
    List<dynamic> imageUrls =
        List.from(docSnapshot2.data()?['imageUrls'] ?? []);

    // Filter out the image that needs to be deleted
    List<dynamic> updatedImages =
        imageUrls.where((img) => img['name'] != name).toList();

    // Update Firestore with the new list
    await docRef2.update({'imageUrls': updatedImages});

    print("Image removed successfully!");
  } else {
    print("User document does not exist.");
  }
}

Future<void> saveOrUpdateImage(
    String uid, String imageName, bool status) async {
  try {
    if (globalData.isAccountPublic) {
      DocumentReference publicImageDocRef = FirebaseFirestore.instance
          .collection('PublicImageList')
          .doc('imagesDoc');
      DocumentReference myPostImageDocRef =
          FirebaseFirestore.instance.collection('Users').doc(uid);

      DocumentSnapshot publicImageDocSnapshot = await publicImageDocRef.get();
      DocumentSnapshot myPostImageDocSnapshot = await myPostImageDocRef.get();

      if (publicImageDocSnapshot.exists) {
        // Explicitly cast data() to Map<String, dynamic>
        Map<String, dynamic> data =
            publicImageDocSnapshot.data() as Map<String, dynamic>;

        // Get imageUrls array safely
        List<dynamic> imageUrls = List.from(data['imageUrls'] ?? []);
        List<dynamic> imageUrls1 = List.from(data['imageUrls'] ?? []);

        bool updated1 = false;
        bool updated2 = false;

        // Modify the 'public' field of the existing image object
        for (int i = 0; i < imageUrls.length; i++) {
          Map<String, dynamic> img = imageUrls[i] as Map<String, dynamic>;
          if (img['name'] == imageName && img['uid'] == uid) {
            imageUrls[i] = {
              ...img,
              'public': status, // Update only the 'public' field
            };
            updated1 = true;
            break; // Stop looping once we find and update the image
          }
        }
        for (int i = 0; i < imageUrls1.length; i++) {
          Map<String, dynamic> img = imageUrls1[i] as Map<String, dynamic>;
          if (img['name'] == imageName && img['uid'] == uid) {
            imageUrls1[i] = {
              ...img,
              'public': status, // Update only the 'public' field
            };
            updated2 = true;
            break; // Stop looping once we find and update the image
          }
        }

        if (updated1 && updated2) {
          // Update Firestore only if an image was modified
          await publicImageDocRef.update({'imageUrls': imageUrls});
          await myPostImageDocRef.update({'imageUrls': imageUrls1});
          print("Image public status updated successfully!");
        } else {
          print("Image not found, no update performed.");
        }
      }
    }
  } catch (e) {
    print("Error updating image public status: $e");
  }
}
