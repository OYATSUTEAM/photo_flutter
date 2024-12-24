import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:photo_sharing_app/data/model/message.dart';

class FollowAndFollowerService {
  final FirebaseFirestore database;
  final FirebaseAuth _auth;

  FollowAndFollowerService(this._auth, this.database);

  Future<List<dynamic>?>? getFollowUidArray() async {
    final String uid = _auth.currentUser!.uid; // Get the current user's UID
    try {
      DocumentReference documentReference =
          database.collection("Users").doc(uid);

      DocumentSnapshot documentSnapshot = await documentReference.get();

      if (documentSnapshot.exists) {
        List<dynamic>? otherArray = documentSnapshot.get('follow');

        if (otherArray != null) {
          return otherArray;
        } else {
          print("'other' field is null or not an array.");
          return null;
        }
      } else {
        print("Document does not exist.");
        return null;
      }
    } catch (e) {
      print("Failed to get 'other' array: $e");
      return null;
    }
  }

  Future<List<dynamic>?>? getFollowerUidArray() async {
    final String uid = _auth.currentUser!.uid; // Get the current user's UID
    try {
      DocumentReference documentReference =
          database.collection("Users").doc(uid);

      DocumentSnapshot documentSnapshot = await documentReference.get();

      if (documentSnapshot.exists) {
        List<dynamic>? otherArray = documentSnapshot.get('follower');

        if (otherArray != null) {
          return otherArray;
        } else {
          print("'other' field is null or not an array.");
          return null;
        }
      } else {
        print("Document does not exist.");
        return null;
      }
    } catch (e) {
      print("Failed to get 'other' array: $e");
      return null;
    }
  }
}
