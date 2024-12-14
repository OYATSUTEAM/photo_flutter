import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testing/data/model/message.dart';

class ChatService {
  final FirebaseFirestore database;
  final FirebaseAuth _auth;

  ChatService(this._auth, this.database);
  Stream<List<Map<String, dynamic>>> getuserStream() {
    return database.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Future<void> sendMessage(String receiverID, message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timeStamp = Timestamp.now();

    Message newMessage = Message(
      message,
      receiverID,
      currentUserEmail,
      currentUserID,
      timeStamp,
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomId = ids.join("_");

    await database
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("message")
        .add(
          newMessage.toMap(),
        );
  }

  Stream<QuerySnapshot> getMessage(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    return database
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection("message")
        .orderBy("timeStamp", descending: false)
        .snapshots();
  }

  Future<List<dynamic>?>? getOtherUidArray() async {
    final String uid = _auth.currentUser!.uid; // Get the current user's UID
    try {
      DocumentReference documentReference =
          database.collection("Users").doc(uid);

      DocumentSnapshot documentSnapshot = await documentReference.get();

      if (documentSnapshot.exists) {
        List<dynamic>? otherArray = documentSnapshot.get('other');

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

  Future<List<String>?> getOtherUsernameArray() async {
    final String uid = _auth.currentUser!.uid; // Get the current user's UID
    try {
      DocumentReference documentReference =
          database.collection("Users").doc(uid);
      DocumentSnapshot documentSnapshot = await documentReference.get();

      if (documentSnapshot.exists) {
        List<dynamic>? otherArray = documentSnapshot.get('other');

        if (otherArray != null) {
          List<String> usernames = [];
          for (var otherUid in otherArray) {
            DocumentSnapshot userSnapshot =
                await database.collection("Users").doc(otherUid).get();
            if (userSnapshot.exists) {
              String? username = userSnapshot.get('username');
              if (username != null && username.isNotEmpty) {
                usernames.add(username); // Add the username to the list
              } else {}
            } else {}
          }
          // print("Usernames: $usernames");
          return usernames;
        } else {
          print("'other' field is null or not an array.");
          return null;
        }
      } else {
        print("Document does not exist.");
        return null;
      }
    } catch (e) {
      print("Failed to get usernames from 'other' array: $e");
      return null;
    }
  }
}
