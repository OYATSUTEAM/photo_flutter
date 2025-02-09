import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:photo_sharing_app/data/global.dart';

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

  Future<List<Map<String, dynamic>>> getRecentFilesFromAllUsers(
      String myUid) async {
    try {
      final List<Map<String, dynamic>> recentFiles = [];
      final DateTime threeDaysAgo = DateTime.now().subtract(Duration(days: 3));
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('Users').get();

      for (QueryDocumentSnapshot<Object?> userDoc in usersSnapshot.docs) {
        String userUid = userDoc.get('uid');
        bool isPublic = userDoc.get('public');
        if (userUid == myUid) continue;
        if (isPublic) {
          try {
            final ListResult profileRef = await FirebaseStorage.instance
                .ref()
                .child("images/$userUid")
                .listAll();

            for (final fileRef in profileRef.items) {
              final metadata = await fileRef.getMetadata();
              final timestampString = metadata.customMetadata?['timestamp'];

              if (timestampString != null) {
                try {
                  final DateTime timestamp = DateTime.parse(timestampString);
                  if (timestamp.isAfter(threeDaysAgo)) {
                    recentFiles.add({"fileRef": fileRef, "uid": userUid});
                  }
                } catch (e) {
                  print(
                      'Error parsing timestamp for file: $fileRef, error: $e');
                }
              }
            }
          } catch (e) {
            print('Error listing files for user: $userUid, error: $e');
          }
        }
      }

      return recentFiles;
    } catch (e) {
      print('Error fetching recent files: $e');
      return [];
    }
  }

  // Future<List<String>> getRecentFollowFiles(String uid) async {
  //   List<String> otherUidList = [];
  //   try {
  //     final firestoreRef =
  //         FirebaseFirestore.instance.collection("Users").doc(uid);

  //     final DocumentSnapshot userDoc = await firestoreRef.get();
  //     if (userDoc.exists && userDoc.data() != null) {
  //       final data = userDoc.data() as Map<String, dynamic>;
  //       otherUidList = (data['follow'] as List<dynamic>?)?.cast<String>() ?? [];
  //     } else {
  //       return [];
  //     }
  //     // final List<Map<String, dynamic>> recentFiles = [];
  //     print('$otherUidList=======');
  //     List<String> recentFiles = [];
  //     // final DateTime threeDaysAgo = DateTime.now().subtract(Duration(days: 3));
  //     for (final otherUid in otherUidList) {
  //       final ListResult profileRef = await FirebaseStorage.instance
  //           .ref()
  //           .child("images/$otherUid/profileImages/")
  //           .listAll();
  //       for (final fileRef in profileRef.items) {
  //         recentFiles.add(await fileRef.getDownloadURL());
  //       }
  //     }
  //     print('$recentFiles ================ this is recent Files');
  //     return recentFiles;
  //   } catch (e) {
  //     return [];
  //   }
  // }
  Future<List<String>> getRecentFollowFiles(String uid) async {
    print('sdfsdafsdfsd========');

    try {
      final firestoreRef =
          FirebaseFirestore.instance.collection("Users").doc(uid);

      // Fetch follow list
      final DocumentSnapshot userDoc = await firestoreRef.get();
      if (!userDoc.exists || userDoc.data() == null) {
        print("User document not found.");
        return [];
      }

      final Map<String, dynamic> userData =
          userDoc.data() as Map<String, dynamic>;
      List<String> followList =
          (userData["follow"] as List<dynamic>?)?.cast<String>() ?? [];

      if (followList.isEmpty) {
        print("Follow list is empty.");
        return [];
      }

      List<String> allImageUrls = [];

      for (String otherUid in followList) {
        final publicImagesRef =
            FirebaseFirestore.instance.collection("PublicImages").doc(otherUid);
        final DocumentSnapshot docSnapshot = await publicImagesRef.get();

        if (!docSnapshot.exists || docSnapshot.data() == null) {
          print("No public images found for $otherUid.");
          continue;
        }

        final Map<String, dynamic> imageData =
            docSnapshot.data() as Map<String, dynamic>;
        List<String> publicImageNames = [];

        imageData.forEach((imageName, isPublic) {
          if (isPublic == true) {
            publicImageNames.add(imageName);
          }
        });

        if (publicImageNames.isEmpty) {
          print("No public images available for $otherUid.");
          continue;
        }

        List<Map<String, dynamic>> imagesWithMetadata = [];

        for (final imageName in publicImageNames) {
          try {
            final fileRef = FirebaseStorage.instance
                .ref("images/$otherUid/profileImages/$imageName");
            final metadata = await fileRef.getMetadata();

            // Convert created time to a comparable format
            final createdTime = metadata.timeCreated != null
                ? DateTime.parse(metadata.timeCreated!.toIso8601String())
                    .millisecondsSinceEpoch
                : 0; // Default to epoch if null

            imagesWithMetadata.add({
              "name": imageName,
              "createdAt": createdTime,
              "storagePath": "images/$otherUid/profileImages/$imageName"
            });
          } catch (e) {
            print("Error fetching metadata for $imageName: $e");
          }
        }

        // Sort images by created time (newest first)
        imagesWithMetadata
            .sort((a, b) => b["createdAt"].compareTo(a["createdAt"]));

        for (var image in imagesWithMetadata) {
          try {
            String imageUrl = await FirebaseStorage.instance
                .ref(image["storagePath"])
                .getDownloadURL();
            allImageUrls.add(imageUrl);
          } catch (e) {
            print("Error fetching URL for ${image["name"]}: $e");
          }
        }
      }

      return allImageUrls;
    } catch (e) {
      print("Error fetching profile URLs: $e");
      return [];
    }
  }

  // Future<List<String>> getOtherProfileURLs(String otherUid) async {
  //   print('sdfsdafsdfsd========');
  //   try {
  //     final storageRef = FirebaseStorage.instance
  //         .ref()
  //         .child("images/$otherUid/profileImages/");
  //     final firestoreRef =
  //         FirebaseFirestore.instance.collection("PublicImages").doc(otherUid);

  //     final DocumentSnapshot docSnapshot = await firestoreRef.get();

  //     if (!docSnapshot.exists || docSnapshot.data() == null) {
  //       print("No public images found for $otherUid.");
  //       return [];
  //     }

  //     final Map<String, dynamic> imageData =
  //         docSnapshot.data() as Map<String, dynamic>;

  //     List<String> publicImageNames = [];
  //     imageData.forEach((imageName, isPublic) {
  //       if (isPublic == true) {
  //         publicImageNames.add(imageName);
  //       }
  //     });

  //     if (publicImageNames.isEmpty) {
  //       print("No public images available for $otherUid.");
  //       return [];
  //     }

  //     List<Map<String, dynamic>> imagesWithMetadata = [];

  //     for (final imageName in publicImageNames) {
  //       try {
  //         final fileRef = storageRef.child(imageName);
  //         final metadata = await fileRef.getMetadata();

  //         // Convert created time to a comparable format
  //         final createdTime = metadata.timeCreated != null
  //             ? DateTime.parse(metadata.timeCreated!.toIso8601String())
  //                 .millisecondsSinceEpoch
  //             : 0; // Default to epoch if null

  //         imagesWithMetadata.add({
  //           "name": imageName,
  //           "createdAt": createdTime,
  //         });
  //       } catch (e) {
  //         print("Error fetching metadata for $imageName: $e");
  //       }
  //     }

  //     // Step 3: Sort images by created time (newest first)
  //     imagesWithMetadata
  //         .sort((a, b) => b["createdAt"].compareTo(a["createdAt"]));

  //     // Step 4: Extract sorted image names
  //     List<String> sortedImageNames =
  //         imagesWithMetadata.map((img) => img["name"] as String).toList();

  //     List<String> imageUrls = [];

  //     for (String imageName in sortedImageNames) {
  //       try {
  //         String imageUrl = await FirebaseStorage.instance
  //             .ref("images/$otherUid/profileImages/$imageName")
  //             .getDownloadURL();
  //         imageUrls.add(imageUrl);
  //       } catch (e) {
  //         print("Error fetching URL for $imageName: $e");
  //         return [];
  //       }
  //     }

  //     return imageUrls;
  //   } catch (e) {
  //     print("Error fetching profile URLs for $otherUid: $e");
  //     return [];
  //   }
  //   return [];
  // }


Future<List<String>> getOtherProfileURLs(String uid) async {
  try {
    final firestoreRef = FirebaseFirestore.instance.collection("PublicImages");
    final QuerySnapshot snapshot = await firestoreRef.get();

    if (snapshot.docs.isEmpty) {
      print("No public images found.");
      return [];
    }

    List<String> allImageUrls = [];

    for (var doc in snapshot.docs) {
      String otherUid = doc.id;
      final Map<String, dynamic> imageData = doc.data() as Map<String, dynamic>;

      List<String> publicImageNames = [];
      imageData.forEach((imageName, isPublic) {
        if (isPublic == true) {
          publicImageNames.add(imageName);
        }
      });

      if (publicImageNames.isEmpty) {
        print("No public images available for $otherUid.");
        continue;
      }

      List<Map<String, dynamic>> imagesWithMetadata = [];

      for (final imageName in publicImageNames) {
        try {
          final fileRef = FirebaseStorage.instance.ref("images/$otherUid/profileImages/$imageName");
          final metadata = await fileRef.getMetadata();

          // Convert created time to a comparable format
          final createdTime = metadata.timeCreated != null
              ? DateTime.parse(metadata.timeCreated!.toIso8601String()).millisecondsSinceEpoch
              : 0; // Default to epoch if null

          imagesWithMetadata.add({
            "name": imageName,
            "createdAt": createdTime,
            "storagePath": "images/$otherUid/profileImages/$imageName"
          });
        } catch (e) {
          print("Error fetching metadata for $imageName: $e");
        }
      }

      // Sort images by created time (newest first)
      imagesWithMetadata.sort((a, b) => b["createdAt"].compareTo(a["createdAt"]));

      for (var image in imagesWithMetadata) {
        try {
          String imageUrl = await FirebaseStorage.instance.ref(image["storagePath"]).getDownloadURL();
          allImageUrls.add(imageUrl);
        } catch (e) {
          print("Error fetching URL for ${image["name"]}: $e");
        }
      }
    }

    return allImageUrls;
  } catch (e) {
    print("Error fetching all public profile URLs: $e");
    return [];
  }
}

  Future<String> getOtherMainProfileURL(String otherUid) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("images/$otherUid/mainProfile.jpg");

      // Step 1: Try to get the URL for the main profile image
      final imageUrl = await storageRef.getDownloadURL();

      return imageUrl; // Return the URL if the image exists
    } catch (e) {
      // If the image does not exist or there's an error, return null
      print("Error fetching main profile image for $otherUid: $e");
      return globalData.profileURL;
    }
  }
}
