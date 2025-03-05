// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/ui/auth/register_screen.dart';
import 'package:photo_sharing_app/ui/screen/home_screen.dart';
import 'package:photo_sharing_app/widgets/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_sharing_app/widgets/my_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  void isEmailVerified() {
    User user = FirebaseAuth.instance.currentUser!;
    if (user.emailVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return HomeScreen();
        }),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Email is not verified.')));
    }
  }

  Future<void> signIn() async {
    final authUser = AuthServices(locator.get(), locator.get());
    try {
      if (!RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(emailController.text.toString())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              textAlign: TextAlign.center,
              'Please enter a valid email address.',
            ),
            backgroundColor: const Color.fromARGB(255, 109, 209, 214),
          ),
        );
        return;
      }

      // if (mounted) {
      //   showDialog(
      //       context: context,
      //       builder: (context) {
      //         return const Center(child: CircularProgressIndicator());
      //       });
      // }
      // await authUser.signIn(email, password);
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.toString(),
        password: passwordController.text.toString(),
      );
      String uid = userCredential.user!.uid;
      // globalData.updateUser(id.text.toString(), uid);
      isEmailVerified();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        const emailError = 'Enter valid email ID';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(emailError)));
      }
      if (e.code == 'wrong-password') {
        const passError = 'Enter correct password';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(passError)));
      }
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You are not registed. Sign Up now")),
        );
      }
      if (e.code == 'invalid-credential') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("正しいパスワードを入力してください。")));
      }
      setState(() {});
    }
  }

  reset_password() async {
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: emailController.text.trim());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: SafeArea(
                child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    "メールアドレス",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  MyTextField(
                      hint: "", obsecure: false, controller: emailController),
                  const SizedBox(height: 10),
                  Text(
                    "パスワード",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                      hint: "", obsecure: true, controller: passwordController),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                  ),
                  MyButton(
                    text: "ログイン",
                    onTap: () async {
                      await signIn();
                    },
                  ),
                  const SizedBox(height: 15),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(
                      "会員でない？ ",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return RegisterScreen();
                          }));
                        },
                        child: Text(
                          "今すぐ登録",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ))
                  ])
                ],
              ),
            )),
          ),
        ));
  }
}
