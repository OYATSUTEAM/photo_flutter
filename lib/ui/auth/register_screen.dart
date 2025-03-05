import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/services/chat/chat_services.dart';
import 'package:photo_sharing_app/ui/auth/login_screen.dart';
import 'package:photo_sharing_app/widgets/my_button.dart';
import 'package:photo_sharing_app/widgets/my_textfield.dart';

final ChatService chatService = locator.get();
final AuthServices authService = locator.get();
final FirebaseFirestore database = FirebaseFirestore.instance;

class RegisterScreen extends StatefulWidget {
  // const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

final authUser = AuthServices(locator.get(), locator.get());
bool isLoading = true;

bool isDialogShown = true;
String uid = 'default@gmail.com';

class _RegisterScreenState extends State<RegisterScreen> {
  final auth = FirebaseAuth.instance;

  void isEmailVerified() {
    User user = FirebaseAuth.instance.currentUser!;
    if (user.emailVerified) {
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Email is not verified.')));
    }
  }

  void sendVerificationEmail() {
    User user = auth.currentUser!;
    user.sendEmailVerification();
  }

  User? user = FirebaseAuth.instance.currentUser;
  Future<void> signUp(
    String email,
    String name,
    String username,
    String password,
    String passwordConfirm,
  ) async {
    if (password == passwordConfirm) {
      try {
        if (!RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        ).hasMatch(emailController.text.toString().trim())) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please enter a valid email address.'),
              backgroundColor: const Color.fromARGB(255, 109, 209, 214),
            ),
          );
          return;
        }

        final users = await chatService.getuserStream().first;
        final isExist = users.any((userData) => userData['email'] == email);

        final existingUserQuery = await database
            .collection("Users")
            .where('username', isEqualTo: username)
            .get();
//=======================================================================user is already exist=====================================================================
        // if (isExist) {
        //   throw Exception('ユーザは既に存在します！');
        // }
//=======================================================Username is already in use. Please select a different user name.==========================================
        // else if (existingUserQuery.docs.isNotEmpty) {
        //   throw Exception('ユーザーネームはすでに使われています。\n別のユーザーネームを選択してください。');
        // }
        // showDialog(
        //     context: context,
        //     builder: (context) {
        //       return const Center(
        //         child: CircularProgressIndicator(),
        //       );
        //     });
        try {
          await auth.createUserWithEmailAndPassword(
            email: emailController.text.toString().trim(),
            password: passwordController.text.toString().trim(),
          );

          if (auth.currentUser?.uid != null) {
            sendVerificationEmail();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '登録されたメールアドレスに確認メールが届いています。アカウントを確認し、再度ログインしてください。',
                ),
                duration: Duration(seconds: 2),
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return LoginScreen();
                },
              ),
            );
            await authUser.register(email, password, name, username);
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('お客様のアカウントは既に登録されていますので、ログインをお試しください。')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return RegisterScreen();
              },
            ),
          );
        }
      } on Exception catch (ex) {
        if (mounted) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('${ex.toString()}'),
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("パスワードが一致しない"),
          );
        },
      );
    }
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController pwConfirmController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context)
                .unfocus(); // Hide keyboard when tapping outside
          },
          child: SingleChildScrollView(
              child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "メールアドレス",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontFamily: 'NotoSansJP',
                    ),
                  ),
                  const SizedBox(height: 4),
                  MyTextField(
                    hint: "",
                    obsecure: false,
                    controller: emailController,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "名前",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  MyTextField(
                    hint: "",
                    obsecure: false,
                    controller: nameController,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "ユーザーネーム",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  MyTextField(
                    hint: "",
                    obsecure: false,
                    controller: userNameController,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "パスワード",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  MyTextField(
                    hint: "6文字以上のパスワードを入力して下さい。",
                    obsecure: true,
                    controller: passwordController,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "パスワードの確認",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  MyTextField(
                    hint: "パスワードの確認",
                    obsecure: true,
                    controller: pwConfirmController,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  MyButton(
                    text: "続ける",
                    onTap: () {
                      signUp(
                          emailController.text.trim(),
                          nameController.text.trim(),
                          userNameController.text.trim(),
                          passwordController.text.trim(),
                          pwConfirmController.text.trim());
                    },
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "すでにアカウントをお持ちの方?    ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return LoginScreen();
                              },
                            ),
                          );
                        },
                        child: Text(
                          "今すぐログイン",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
        ));
  }
}
