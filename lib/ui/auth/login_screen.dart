// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/widgets/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_sharing_app/widgets/my_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.callBack});
  final VoidCallback callBack;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // final FirebaseAuth user = locator.get();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> signIn(
    String email,
    String password,
  ) async {
    final authUser = AuthServices(locator.get(), locator.get());
    try {
      if (mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            });
      }
      await authUser.signIn(
        email,
        password,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } on Exception catch (ex) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(ex.toString()),
          );
        },
      );
    }
  }

  reset_password() async {
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: emailController.text.trim());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // var usernameController = TextEditingController();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: SafeArea(
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 30,
              ),
              Text(
                "メールアドレス",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              MyTextField(
                hint: "",
                obsecure: false,
                controller: emailController,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "パスワード",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              MyTextField(
                hint: "",
                obsecure: true,
                controller: passwordController,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
              ),
              MyButton(
                text: "ログイン",
                onTap: () async {
                  await signIn(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );
                },
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "会員でない？ ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.callBack,
                    child: Text(
                      "今すぐ登録",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )),
      ),
    );
  }
}
