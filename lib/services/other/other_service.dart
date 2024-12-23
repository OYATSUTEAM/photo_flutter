import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseStorage _storage = FirebaseStorage.instance;

class OtherService {
  final FirebaseAuth user = FirebaseAuth.instance;
  // final FirebaseAuth user;
  final FirebaseFirestore database = FirebaseFirestore.instance;

  // OtherService(this.database, this.user);

  User? getCurrentuser() {
    print(user.currentUser);
    return user.currentUser;
  }

  Future<void> addUser(String otherUid) async {
    final String uid = user.currentUser!.uid;
    try {
      // Get a reference to the Firestore document
      DocumentReference documentReference =
          database.collection("Users").doc(uid);
      // DocumentSnapshot documentSnapshot = await documentReference.get();
      await documentReference.update({
        'other': FieldValue.arrayUnion([otherUid]) // Add value to the array
      });
    } catch (e) {
      print("Failed to update 'other' field: $e");
    }
  }

  Future<void> deleteOther(String otherUid) async {
    final String uid = user.currentUser!.uid; // Get the current user's UID
    try {
      // Reference to the Firestore document
      DocumentReference documentReference =
          database.collection("Users").doc(uid);

      // Remove the specified `otherUid` from the 'other' array
      await documentReference.update({
        'other': FieldValue.arrayRemove(
            [otherUid]), // Remove the value from the array
      });
      await documentReference.update({
        'follow': FieldValue.arrayRemove(
            [otherUid]), // Remove the value from the array
      });
      await documentReference.update({
        'follower': FieldValue.arrayRemove(
            [otherUid]), // Remove the value from the array
      });
      // print("Successfully removed '$otherUid' from 'other' array.");
    } catch (e) {
      // print("Failed to remove '$otherUid' from 'other' array: $e");
    }
  }

  Future<Map<String, dynamic>?> getOthers(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = database
          .collection("Users")
          .doc(uid)
          .get() as DocumentSnapshot<Object?>;

      print(documentSnapshot.data());
    } catch (e) {
      print("Failed to update 'other' field: $e");
    }
    return null;
  }

  Future<String?> getUserName(String otherUid) async {
    try {
      // final String uid = user.currentUser!.uid;
      DocumentSnapshot userSnapshot =
          await database.collection("Users").doc(otherUid).get();

      String username = userSnapshot.get('username');
      return username;
    } catch (e) {
      print("Error fetching document: $e");
      return null;
    }
  }

  Future<String?> getUserEmail(String otherUid) async {
    try {
      // final String uid = user.currentUser!.uid;
      DocumentSnapshot userSnapshot =
          await database.collection("Users").doc(otherUid).get();

      String email = userSnapshot.get('email');
      return email;
    } catch (e) {
      print("Error fetching document: $e");
      return null;
    }
  }

  Future<void> followOther(String otherUid) async {
    final String uid = user.currentUser!.uid;
    try {
      DocumentReference documentReference =
          database.collection("Users").doc(uid);
      await documentReference.update({
        'follow': FieldValue.arrayUnion([otherUid]) // Add value to the array
      });
      DocumentReference otherDocumentReference =
          database.collection("Users").doc(otherUid);
      await otherDocumentReference.update({
        'follower': FieldValue.arrayUnion([uid]) // Add value to the array
      });
    } catch (e) {
      print("Failed to update 'other' field: $e");
    }
  }

  Future<void> blockThisUser(String otherUid) async {
    final String uid = user.currentUser!.uid;
    try {
      DocumentReference documentReference =
          database.collection("Users").doc(uid);
      await documentReference.update({
        'block': FieldValue.arrayUnion([otherUid]) // Add value to the array
      });
      DocumentReference otherDocumentReference =
          database.collection("Users").doc(otherUid);
      await otherDocumentReference.update({
        'blocked': FieldValue.arrayUnion([uid]) // Add value to the array
      });
    } catch (e) {
      print("Failed to update 'other' field: $e");
    }
  }

  Future<void> unBlockThisUser(String otherUid) async {
    final String uid = user.currentUser!.uid;
    try {
      DocumentReference documentReference =
          database.collection("Users").doc(uid);
      await documentReference.update({
        'block': FieldValue.arrayRemove([otherUid]) // Add value to the array
      });
    } catch (e) {
      print("Failed to update 'other' field: $e");
    }
  }

  Future<void> increamentLike(String otherUid, String which) async {
    final String uid = user.currentUser!.uid;
    try {
      DocumentReference otherDocumentReference =
          database.collection("Users").doc(otherUid);
      await otherDocumentReference.update({
        'like-$which': FieldValue.arrayUnion([uid]) // Add value to the array
      });
      await otherDocumentReference.update({
        'dislike-$which':
            FieldValue.arrayRemove([uid]) // Add value to the array
      });
    } catch (e) {
      print("Failed to update 'other' field: $e");
    }
  }

  Future<void> decreamentLike(String otherUid, String which) async {
    final String uid = user.currentUser!.uid;
    try {
      DocumentReference otherDocumentReference =
          database.collection("Users").doc(otherUid);

      await otherDocumentReference.update({
        'like-$which': FieldValue.arrayRemove([uid]) // Add value to the array
      });
    } catch (e) {
      print("Failed to update 'other' field: $e");
    }
  }

  Future<void> increamentDislike(String otherUid, String which) async {
    final String uid = user.currentUser!.uid;
    try {
      DocumentReference otherDocumentReference =
          database.collection("Users").doc(otherUid);
      await otherDocumentReference.update({
        'dislike-$which': FieldValue.arrayUnion([uid]) // Add value to the array
      });
      await otherDocumentReference.update({
        'like-$which': FieldValue.arrayRemove([uid]) // Add value to the array
      });
    } catch (e) {
      print("Failed to update 'other' field: $e");
    }
  }

  Future<void> decreamentDislike(String otherUid, String which) async {
    final String uid = user.currentUser!.uid;
    try {
      DocumentReference otherDocumentReference =
          database.collection("Users").doc(otherUid);

      await otherDocumentReference.update({
        'dislike-$which':
            FieldValue.arrayRemove([uid]) // Add value to the array
      });
    } catch (e) {
      print("Failed to update 'other' field: $e");
    }
  }

  Future<void> increamentFavourite(String otherUid, String which) async {
    final String uid = user.currentUser!.uid;
    try {
      DocumentReference otherDocumentReference =
          database.collection("Users").doc(otherUid);
      await otherDocumentReference.update({
        'favourite-$which':
            FieldValue.arrayUnion([uid]) // Add value to the array
      });
    } catch (e) {
      print("Failed to update 'other' field: $e");
    }
  }

  Future<void> decrementFavourite(String otherUid, String which) async {
    final String uid = user.currentUser!.uid;
    try {
      DocumentReference otherDocumentReference =
          database.collection("Users").doc(otherUid);
      await otherDocumentReference.update({
        'favourite-$which':
            FieldValue.arrayRemove([uid]) // Add value to the array
      });
    } catch (e) {
      print("Failed to update 'other' field: $e");
    }
  }

  Future<void> addComment(
      String otherUid, String commentText, String whichComment) async {
    final String uid = user.currentUser!.uid;
    try {
      // Reference to the subcollection 'comments' under the user's document
      CollectionReference commentsRef = database
          .collection("Users")
          .doc(otherUid)
          .collection("comments-$whichComment");

      // Add a new document with the comment details
      await commentsRef.add({
        'comment': commentText,
        'uid': uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Comment added successfully!");
    } catch (e) {
      print("Failed to add comment: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getAllComments(
      String otherUid, String whichComment) async {
    List<Map<String, dynamic>> commentsList = [];
    try {
      // Reference to the subcollection 'comments' under the user's document
      CollectionReference commentsRef = FirebaseFirestore.instance
          .collection("Users")
          .doc(otherUid)
          .collection("comments-$whichComment");

      QuerySnapshot querySnapshot =
          await commentsRef.orderBy('timestamp', descending: true).get();

      for (var doc in querySnapshot.docs) {
        commentsList.add({
          'comment': doc['comment'],
          'uid': doc['uid'],
          'timestamp':
              doc['timestamp'], // You can format the timestamp if needed
        });
      }
      print("Comments fetched successfully!");
      return commentsList;
    } catch (e) {
      print("Failed to fetch comments: $e");
    }

    return commentsList;
  }

  Future<List<Map<String, dynamic>>> getRecentOtherFiles(String uid) async {
    List<String> otherUidList = [];
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (userDoc.exists) {
        List<dynamic> otherData = userDoc.get('other') ?? [];

        otherUidList = List<String>.from(otherData);
      } else {
        print('User document does not exist.');
        return [];
      }
      print('$otherUidList!!!!!!!!!!!!!!!!!!!! this is other uid list!!!!!!!!');

      final List<Map<String, dynamic>> recentFiles = [];
      final DateTime threeDaysAgo = DateTime.now().subtract(Duration(days: 3));
      for (final otherUid in otherUidList) {
        DocumentSnapshot userSnapshot =
            await database.collection("Users").doc(otherUid).get();

        bool isPublic = userSnapshot.get('public');

        final ListResult profileRef = await FirebaseStorage.instance
            .ref()
            .child("images/$otherUid")
            .listAll();
        for (final fileRef in profileRef.items) {
          final metadata = await fileRef.getMetadata();
          final timestampString = metadata.customMetadata?['timestamp'];

          if (timestampString != null) {
            final DateTime timestamp = DateTime.parse(timestampString);
            if (timestamp.isAfter(threeDaysAgo)) {
              if (isPublic)
                recentFiles.add({"fileRef": fileRef, "uid": otherUid});
            }
          }
        }
      }

      return recentFiles;
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecentFollowFiles(String uid) async {
    List<String> otherUidList = [];
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (userDoc.exists) {
        List<dynamic> otherData = userDoc.get('follow') ?? [];

        otherUidList = List<String>.from(otherData);
      } else {
        print('User document does not exist.');
        return [];
      }
      print('$otherUidList!!!!!!!!!!!!!!!!!!!! this is other uid list!!!!!!!!');
      final List<Map<String, dynamic>> recentFiles = [];
      final DateTime threeDaysAgo = DateTime.now().subtract(Duration(days: 3));
      for (final otherUid in otherUidList) {
        final ListResult profileRef = await FirebaseStorage.instance
            .ref()
            .child("images/$otherUid")
            .listAll();
        for (final fileRef in profileRef.items) {
          final metadata = await fileRef.getMetadata();
          final timestampString = metadata.customMetadata?['timestamp'];

          if (timestampString != null) {
            final DateTime timestamp = DateTime.parse(timestampString);
            if (timestamp.isAfter(threeDaysAgo)) {
              recentFiles.add({"fileRef": fileRef, "uid": otherUid});
            }
          }
        }
      }

      return recentFiles;
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecentOtherFilesAfter3days(
      String uid) async {
    List<String> otherUidList = [];
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (userDoc.exists) {
        List<dynamic> otherData = userDoc.get('other') ?? [];

        otherUidList = List<String>.from(otherData);
      } else {
        print('User document does not exist.');
        return [];
      }
      print('$otherUidList!!!!!!!!!!!!!!!!!!!! this is other uid list!!!!!!!!');
      final List<Map<String, dynamic>> recentFiles = [];
      final DateTime threeDaysAgo = DateTime.now().subtract(Duration(days: 3));
      for (final otherUid in otherUidList) {
        final ListResult profileRef = await FirebaseStorage.instance
            .ref()
            .child("images/$otherUid")
            .listAll();
        for (final fileRef in profileRef.items) {
          final metadata = await fileRef.getMetadata();
          final timestampString = metadata.customMetadata?['timestamp'];

          if (timestampString != null) {
            final DateTime timestamp = DateTime.parse(timestampString);
            if (timestamp.isBefore(threeDaysAgo)) {
              recentFiles.add({"fileRef": fileRef, "uid": otherUid});
            }
          }
        }
      }

      return recentFiles;
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecentFollowFilesAfter3days(
      String uid) async {
    List<String> otherUidList = [];
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (userDoc.exists) {
        List<dynamic> otherData = userDoc.get('follow') ?? [];

        otherUidList = List<String>.from(otherData);
      } else {
        print('User document does not exist.');
        return [];
      }
      print('$otherUidList!!!!!!!!!!!!!!!!!!!! this is other uid list!!!!!!!!');
      final List<Map<String, dynamic>> recentFiles = [];
      final DateTime threeDaysAgo = DateTime.now().subtract(Duration(days: 3));
      for (final otherUid in otherUidList) {
        final ListResult profileRef = await FirebaseStorage.instance
            .ref()
            .child("images/$otherUid")
            .listAll();
        for (final fileRef in profileRef.items) {
          final metadata = await fileRef.getMetadata();
          final timestampString = metadata.customMetadata?['timestamp'];

          if (timestampString != null) {
            final DateTime timestamp = DateTime.parse(timestampString);
            if (timestamp.isBefore(threeDaysAgo)) {
              recentFiles.add({"fileRef": fileRef, "uid": otherUid});
            }
          }
        }
      }

      return recentFiles;
    } catch (e) {
      return [];
    }
  }
}
