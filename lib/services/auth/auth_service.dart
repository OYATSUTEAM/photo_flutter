import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth user;
  final FirebaseFirestore _database;
  late DocumentSnapshot documentSnapshot;

  AuthServices(this._database, this.user);

  User? getCurrentuser() {
    return FirebaseAuth.instance.currentUser;
  }

  Future<Map<String, dynamic>?> getDocument(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();

    if (documentSnapshot.exists) {
      print('Document data: ${documentSnapshot.data()}');
      return documentSnapshot.data();
    } else {
      print('Document does not exist');
      return null;
    }
  }

  Future<String> getCurrentUserUID() async {
    User? user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    return 'default@gmail.com';
  }

  Future<Map<String, dynamic>?> getUserDetail(String uid) async {
    // final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      documentSnapshot = await _database.collection("Users").doc(uid).get();
      if (documentSnapshot.exists && documentSnapshot.data() != null) {
        return documentSnapshot.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      print("Error fetching document: $e");
      return null;
    }
  }

  Future<UserCredential?> signIn(
    String email,
    password,
  ) async {
    try {
      final UserCredential userCredential = await user
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (error) {
      String errorMessage = "";

      // Handle specific Firebase errors and translate them into Japanese
      if (error.code == 'user-not-found') {
        errorMessage = "ユーザーが見つかりませんでした"; // User not found
      } else if (error.code == 'wrong-password') {
        errorMessage = "パスワードが間違っています"; // Wrong password
      } else if (error.code == 'invalid-email') {
        errorMessage = "無効なメールアドレスです"; // Invalid email address
      } else if (error.code == 'email-already-in-use') {
        errorMessage = "このメールアドレスはすでに使用されています"; // Email already in use
      } else if (error.code == 'network-request-failed') {
        errorMessage = "ネットワークエラーが発生しました"; // Network error
      } else {
        errorMessage = "ログイン中にエラーが発生しました"; // Generic error message
      }
      // Throw a new exception with the translated message
      throw Exception(errorMessage);
    } catch (e) {
      print("Error fetching document: $e");
      return null;
    }
    // }
  }

  Future<void> signOut() async {
    try {
      print("Sign out initiated...");
      // Check if the user is already signed in
      await user.signOut();
      print("Sign out successful.");
    } catch (e) {
      print("Error during sign out: $e");
    }
  }

  Future<UserCredential?> register(
      String email, String password, String name, String username) async {
    try {
      final UserCredential userCredential =
          await user.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _database.collection("Users").doc(userCredential.user?.uid).set({
        "uid": userCredential.user?.uid,
        "email": email,
        "password": password,
        'name': name,
        'username': username,
        'other': [],
        'follow': [],
        'follower': [],
        'isShowAll': true,
        'public': true,
      });
      return await signIn(email, password);
    } on FirebaseAuthException {
      return null;
    } catch (e) {
      return null;
      // Handle other exceptions
    }
  }
}
