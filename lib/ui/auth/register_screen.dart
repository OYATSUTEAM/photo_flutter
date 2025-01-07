import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/services/chat/chat_services.dart';
import 'package:photo_sharing_app/widgets/my_button.dart';
import 'package:photo_sharing_app/widgets/my_textfield.dart';

final ChatService chatService = locator.get();
final FirebaseFirestore _database = FirebaseFirestore.instance;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.callBack});
  final VoidCallback callBack;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

final authUser = AuthServices(locator.get(), locator.get());
bool isLoading = true;

bool isDialogShown = true;

class _RegisterScreenState extends State<RegisterScreen> {
  Future<void> signUp(
    String email,
    String name,
    String username,
    String password,
    String passwordConfirm,
  ) async {
    if (password == passwordConfirm) {
      try {
        // Check if the email or username already exists
        final users = await chatService.getuserStream().first;
        final isExist = users.any((userData) => userData['email'] == email);
        final existingUserQuery = await _database
            .collection("Users")
            .where('username', isEqualTo: username)
            .get();
//=======================================================================user is already exist=====================================================================//
        if (isExist) {
          throw Exception('ユーザは既に存在します！');
        } else if (existingUserQuery.docs.isNotEmpty) {
          throw Exception('ユーザーネームはすでに使われています。\n別のユーザーネームを選択してください。');
//=======================================================Username is already in use. \Please select a different user name.===========================================//
        }
        if (isLoading) {
          showDialog(
              context: context,
              builder: (context) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              });
        }
        final result =
            await authUser.register(email, password, name, username).then((_) {
          print('this is register later!');
          isLoading = false;
        });
        if (!isLoading) Navigator.pop(context);

        if (mounted) {
          print(
              "$result   this is register!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
          Navigator.pop(context);
        }
      } on Exception catch (ex) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(ex.toString()),
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("Passwords dont' match"),
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
                        onTap: widget.callBack,
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
