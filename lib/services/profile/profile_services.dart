import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileServices {
  FirebaseFirestore _database = FirebaseFirestore.instance;
  late final DocumentSnapshot documentSnapshot;
  final firestore = FirebaseStorage;

  String mainURL =
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTqafzhnwwYzuOTjTlaYMeQ7hxQLy_Wq8dnQg&s";
  String secondURL = "https://en.pimg.jp/079/687/576/1/79687576.jpg";
  String firstURL =
      "https://us.123rf.com/450wm/apoev/apoev1806/apoev180600156/103284749-default-placeholder-businessman-half-length-portrait-photo-avatar-man-gray-color.jpg";
  String thirdURL =
      "https://img.freepik.com/premium-photo/default-avatar-profile-icon-gray-placeholder-man-woman-isolated-white-background_660230-21610.jpg";
  String forthURL =
      "https://img.freepik.com/premium-vector/grandparents-icon-vector-image-can-be-used-child-adoption_120816-381816.jpg?semt=ais_hybrid";

  Future<void> updateProfile(String? uid, String? name, String? username,
      String? email, String? password) async {
    try {
      await _database
          .collection("Users")
          .doc(uid)
          .update({'name': name, 'username': username, 'password': password});
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  Future<void> updatePassword(String uid, String password) async {
    try {
      await _database
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
      documentSnapshot = await _database.collection("Users").doc(uid).get();

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

  Future<void> publicAccount(String uid, bool isPublic) async {
    try {
      await _database.collection("Users").doc(uid).update({'public': isPublic});
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  Future<bool> isPublicAccount(String uid) async {
    try {
      final ref = await _database.collection('Users').doc(uid).get();
      return ref.get('public');
    } catch (e) {
      print(e);
      return true;
    }
  }

  Future<String> getUserPassword(String uid) async {
    try {
      documentSnapshot = await _database.collection("Users").doc(uid).get();
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
      documentSnapshot = await _database.collection("Users").doc(uid).get();
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
      documentSnapshot = await _database.collection("Users").doc(uid).get();
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
      final ref = await _database.collection('Users').doc(uid).get();
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
          _database.collection("Users").doc(uid);

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
          _database.collection("Users").doc(uid);

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
      DocumentSnapshot userSnapshot = await _database
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
      DocumentSnapshot userSnapshot = await _database
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

  Future<bool> getCommentStatus() async {
    try {
      DocumentSnapshot userSnapshot = await _database
          .collection("Status_Manage")
          .doc('manage_status')
          .get();
      bool isCommentTrue = userSnapshot.get('comment');
      return isCommentTrue;
    } catch (e) {
      print("Error fetching document: $e");
      return false;
    }
  }

  Future<void> setBlockStatus(bool status) async {
    try {
      await _database
          .collection("Status_Manage")
          .doc('manage_status')
          .update({'block': status});
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  Future<void> setCommentStatus(bool status) async {
    try {
      await _database
          .collection("Status_Manage")
          .doc('manage_status')
          .update({'comments': status});
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  Future<void> setReportStatus(bool status) async {
    try {
      await _database
          .collection("Status_Manage")
          .doc('manage_status')
          .update({'report': status});
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  Future<void> deleteAccount(String uid) async {
    try {
      await _database.collection("Users").doc(uid).delete();
      print("Account deleted successfully");
    } catch (e) {
      print("Error deleting account: $e");
    }
  }
}
