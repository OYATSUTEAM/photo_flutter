// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testing/DI/service_locator.dart';
import 'package:testing/services/auth/auth_service.dart';
import 'package:testing/services/profile/profile_services.dart';
import 'package:testing/ui/myProfile/myprofile_edit.dart';
import 'package:testing/widgets/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testing/widgets/my_textfield.dart';
import 'package:testing/widgets/othertile.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.whichProfile,
    required this.email,
    required this.uid,
  });
  // final VoidCallback callBack;
  final String whichProfile;
  final String email;
  final String uid;
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

ProfileServices _profileServices = ProfileServices();

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  reset_password() async {
    try {
      if (user == null) {
        print("No user is signed in.");
        return;
      }
      if (user != null) {
        final currentPassword =
            await _profileServices.getUserPassword(user!.uid);
        print('${widget.email}, !!!!!, $currentPassword');
        if (currentPasswordController.text.trim() == currentPassword) {
          if (newPasswordController.text.trim() ==
              confirmPasswordController.text.trim()) {
            showDialog(
                context: context,
                builder: (context) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                });
            profileService.updatePassword(
                widget.uid, newPasswordController.text.trim());
            AuthCredential credential = await EmailAuthProvider.credential(
              email: widget.email,
              password: currentPassword,
            );
            // Re-authenticate
            print(await user?.reauthenticateWithCredential(credential));
            user?.updatePassword(newPasswordController.text.trim());
            if (mounted) {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MyProfileEdit(
                    whichProfile: widget.whichProfile,
                  ),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('your new password is not match')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('your current password is not right!')),
          );
          return;
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // var usernameController = TextEditingController();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 40,
              ),
              Text(
                "現在のパスワード",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              MyTextField(
                hint: "",
                obsecure: true,
                controller: currentPasswordController,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "新しいパスワード",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              MyTextField(
                hint: "",
                obsecure: true,
                controller: confirmPasswordController,
              ),
              const SizedBox(height: 10),
              Text(
                "パスワードの確認",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              MyTextField(
                hint: "",
                obsecure: true,
                controller: newPasswordController,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.28),
              MyButton(
                text: "パスワードリセット",
                onTap: () async {
                  reset_password();
                },
              ),
              const SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => MyProfileEdit(
                        whichProfile: widget.whichProfile,
                      ),
                    ),
                  );
                },
                child: Text(
                  "プロフィールの編集 に行く",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
