import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testing/services/auth/auth_page.dart';
import 'package:testing/ui/screen/banner_screen.dart';
// import 'package:testing/ui/home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return BannerScreen();
        } else {
          return AuthPage();
        }
      },
    );
  }
}
