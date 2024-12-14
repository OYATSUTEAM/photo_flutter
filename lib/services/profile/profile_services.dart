import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileServices {
  FirebaseFirestore _database = FirebaseFirestore.instance;
  late DocumentSnapshot documentSnapshot;
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
      await _database.collection("Users").doc(uid).update({
        'name': name,
        'username': username,
      });
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
}
