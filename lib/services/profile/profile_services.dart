import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
// import 'package:firebase_database/firebase_database.dart';

class ProfileServices {
  FirebaseFirestore database = FirebaseFirestore.instance;
  late final DocumentSnapshot documentSnapshot;
  final firestore = FirebaseStorage;

  String mainURL =
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTqafzhnwwYzuOTjTlaYMeQ7hxQLy_Wq8dnQg&s";
  String secondURL = "";
  String firstURL = "";
  String thirdURL = "";
  String forthURL = "";

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

  Future<void> updatePassword(String uid, String password) async {
    try {
      await database
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
      documentSnapshot = await database.collection("Users").doc(uid).get();

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
    try {
      final profileRef =
          FirebaseStorage.instance.ref().child("images/$uid/mainProfileImage");
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

  Future<String> getFirstProfileUrl(String uid) async {
    try {
      final profileRef =
          FirebaseStorage.instance.ref().child("images/$uid/firstProfileImage");
      String profileUrl = await profileRef.getDownloadURL();
      return profileUrl;
    } on FirebaseException catch (e) {
      print('Firebase Storage error: ${e.code} - ${e.message}');
      return firstURL;
    } catch (e) {
      print('General error: $e');
      return firstURL;
    }
  }

  Future<String> getSecondProfileUrl(String uid) async {
    try {
      final profileRef = FirebaseStorage.instance
          .ref()
          .child("images/$uid/secondProfileImage");
      String profileUrl = await profileRef.getDownloadURL();
      return profileUrl;
    } on FirebaseException catch (e) {
      print('Firebase Storage error: ${e.code} - ${e.message}');
      return secondURL;
    } catch (e) {
      print('General error: $e');
      return secondURL;
    }
  }

  Future<String> getThirdProfileUrl(String uid) async {
    try {
      final profileRef =
          FirebaseStorage.instance.ref().child("images/$uid/thirdProfileImage");
      String profileUrl = await profileRef.getDownloadURL();
      return profileUrl;
    } on FirebaseException catch (e) {
      print('Firebase Storage error: ${e.code} - ${e.message}');
      return thirdURL;
    } catch (e) {
      print('General error: $e');
      return thirdURL;
    }
  }

  Future<String> getForthProfileUrl(String uid) async {
    try {
      final profileRef =
          FirebaseStorage.instance.ref().child("images/$uid/forthProfileImage");
      String profileUrl = await profileRef.getDownloadURL();
      return profileUrl;
    } on FirebaseException catch (e) {
      print('Firebase Storage error: ${e.code} - ${e.message}');
      return forthURL;
    } catch (e) {
      print('General error: $e');
      return forthURL;
    }
  }

  Future<void> deleteProfile(String uid, String whichProfile) async {
    // Create a reference to the Firebase Storage location where your file is stored
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference storageRef = storage.ref().child('images/$uid/$whichProfile');
    print('$storageRef!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

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

    try {
      await database.collection("Users").doc(uid).update({'public': isPublic});
      // Get the document snapshot
      final ref = await database.collection('PublicImages').doc(uid).get();
      if (ref.exists && ref.data() != null) {
        List<String> publicImageNames = [];
        final Map<String, dynamic> imageData =
            ref.data() as Map<String, dynamic>;

        imageData.forEach((image, _isPublic) async {
          if (_isPublic) {
            final storageRef = FirebaseStorage.instance
                .ref()
                .child("images/$uid/profileImages/$image");
            final imageUrl = await storageRef.getDownloadURL();
            if (isPublic) {
              addImageUrl(imageUrl);
            } else {
              removeImageUrl(imageUrl);
            }
          }
        });
      } else {
        return false;
      }
    } catch (e) {
      print("Error getting dirpath status: $e");
      return false;
    }
  }

  Future<bool> isPublicAccount(String uid) async {
    try {
      final ref = await database.collection('Users').doc(uid).get();
      return ref.get('public');
    } catch (e) {
      print(e);
      return true;
    }
  }

  Future<String> getUserPassword(String uid) async {
    try {
      documentSnapshot = await database.collection("Users").doc(uid).get();
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
    try {
      documentSnapshot = await database.collection("Users").doc(uid).get();
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
    try {
      documentSnapshot = await database.collection("Users").doc(uid).get();
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
      final ref = await database.collection('Users').doc(uid).get();
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
          database.collection("Users").doc(uid);

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
          database.collection("Users").doc(uid);

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
      DocumentSnapshot userSnapshot =
          await database.collection("Status_Manage").doc('manage_status').get();
      bool isBlockTrue = userSnapshot.get('block');
      return isBlockTrue;
    } catch (e) {
      print("Error fetching document: $e");
      return false;
    }
  }

  Future<bool> isReportTrue() async {
    try {
      DocumentSnapshot userSnapshot =
          await database.collection("Status_Manage").doc('manage_status').get();
      bool isReportTrue = userSnapshot.get('report');
      return isReportTrue;
    } catch (e) {
      print("Error fetching document: $e");
      return false;
    }
  }

  Future<bool> getCommentStatus() async {
    try {
      DocumentSnapshot userSnapshot =
          await database.collection("Status_Manage").doc('manage_status').get();
      bool isCommentTrue = userSnapshot.get('comments');
      return isCommentTrue;
    } catch (e) {
      print("Error fetching document: $e");
      return false;
    }
  }

  Future<void> setBlockStatus(bool status) async {
    try {
      await database
          .collection("Status_Manage")
          .doc('manage_status')
          .update({'block': status});
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  Future<void> setCommentStatus(bool status) async {
    try {
      await database
          .collection("Status_Manage")
          .doc('manage_status')
          .update({'comments': status});
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  Future<void> setReportStatus(bool status) async {
    try {
      await database
          .collection("Status_Manage")
          .doc('manage_status')
          .update({'report': status});
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  Future<void> deleteAccount(String uid) async {
    try {
      await database.collection("Users").doc(uid).delete();
      print("Account deleted successfully");
    } catch (e) {
      print("Error deleting account: $e");
    }
  }

  Future<void> publicThisImage(String uid, String dirpath, bool status) async {
    try {
      final publicDoc =
          await FirebaseFirestore.instance.collection("PublicImages").doc(uid);
      publicDoc.set({dirpath: status}, SetOptions(merge: true));

      final storageRef = await FirebaseStorage.instance
          .ref()
          .child("images/$uid/profileImages/$dirpath");

      // Step 1: Try to get the URL for the main profile image
      final imageUrl = await storageRef.getDownloadURL();
      if (status) {
        await addImageUrl(imageUrl);
      } else {
        await removeImageUrl(imageUrl);
      }
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  Future<bool> getDirPathStatus(String uid, String dirpath) async {
    try {
      // Get the document snapshot
      final ref = await database.collection('PublicImages').doc(uid).get();
      if (ref.exists && ref.data() != null) {
        return ref.data()!.containsKey(dirpath) ? ref.get(dirpath) : false;
      } else {
        return false;
      }
    } catch (e) {
      print("Error getting dirpath status: $e");
      return false;
    }
  }

  Future<void> deleteThisImage(String uid, String dirpath) async {
    try {
      final publicDoc =
          FirebaseFirestore.instance.collection("PublicImages").doc(uid);
      await publicDoc.update({
        dirpath: FieldValue.delete(),
      });
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  Future<String> getProfileImageUrl(String path) async {
    final FirebaseStorage _storage = FirebaseStorage.instance;

    try {
      // Get the image reference from Firebase Storage
      Reference ref = _storage.ref().child(path);

      // Get the download URL
      String imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print("Error getting image URL: $e");
      return ''; // Return empty if there's an error
    }
  }

  Future<void> addImageUrl(String imageUrl) async {
    try {
      CollectionReference images =
          FirebaseFirestore.instance.collection('PublicImageList');

      // Create an image object with URL and timestamp
      Map<String, dynamic> imageObject = {
        'url': imageUrl,
        'timestamp': FieldValue.serverTimestamp(), // Firestore server timestamp
      };

      // Add the new image object to an array
      DocumentSnapshot docSnapshot = await images.doc('imagesDoc').get();

      if (docSnapshot.exists) {
        await images.doc('imagesDoc').update({
          'imageUrls': FieldValue.arrayUnion([imageObject])
        });
      } else {
        await images.doc('imagesDoc').set({
          'imageUrls': [imageObject]
        });
      }

      print("Image URL added successfully!");
    } catch (e) {
      print("Error adding image URL: $e");
    }
  }

  Future<void> removeImageUrl(String imageUrl) async {
    await FirebaseFirestore.instance
        .collection('PublicImageList')
        .doc('imagesDoc')
        .update({
      'imageUrls': FieldValue.arrayRemove([imageUrl]) // Remove specific URL
    });
  }

  // Future<void> addImageUrl(String imageUrl) async {
  //   try {
  //     DatabaseReference ref =
  //         FirebaseDatabase.instance.ref("PublicImageList/images");

  //     // Create an image object with URL and timestamp
  //     Map<String, dynamic> imageObject = {
  //       'url': imageUrl,
  //       'timestamp':
  //           ServerValue.timestamp, // Realtime Database server timestamp
  //     };

  //     // Push new image to the list
  //     await ref.push().set(imageObject);

  //     print("Image URL added successfully!");
  //   } catch (e) {
  //     print("Error adding image URL: $e");
  //   }
  // }

  // Future<void> removeImageUrl(String imageUrl) async {
  //   try {
  //     DatabaseReference ref =
  //         FirebaseDatabase.instance.ref("PublicImageList/images");

  //     // Get all images
  //     DataSnapshot snapshot = await ref.get();

  //     if (snapshot.exists) {
  //       Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

  //       // Find the key of the image with the given URL
  //       String? keyToDelete;
  //       values.forEach((key, value) {
  //         if (value['url'] == imageUrl) {
  //           keyToDelete = key;
  //         }
  //       });

  //       // If key is found, delete the image
  //       if (keyToDelete != null) {
  //         await ref.child(keyToDelete!).remove();
  //         print("Image URL removed successfully!");
  //       } else {
  //         print("Image URL not found!");
  //       }
  //     }
  //   } catch (e) {
  //     print("Error removing image URL: $e");
  //   }
  // }
}
