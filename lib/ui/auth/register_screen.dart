import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testing/DI/service_locator.dart';
import 'package:testing/services/auth/auth_service.dart';
import 'package:testing/services/chat/chat_services.dart';
import 'package:testing/widgets/my_button.dart';
import 'package:testing/widgets/my_textfield.dart';

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

class _RegisterScreenState extends State<RegisterScreen> {
  Future<void> signUp(
    String email,
    String name,
    String username,
    String password,
    String passwordConfirm,
  ) async {
    // bool isDialogShown = false;

    if (password == passwordConfirm) {
      showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
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

        final result = await authUser.signUp(email, password, name, username);
        if (mounted) {
          Navigator.pop(context);
          print(
              "$result!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!this is sign up result!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        }
      } on Exception catch (ex) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        print("$ex!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
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

  @override
  Widget build(BuildContext context) {
    var emailController = TextEditingController();
    var nameController = TextEditingController();
    var userNameController = TextEditingController();
    var passwordController = TextEditingController();
    var pwConfirmController = TextEditingController();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
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
      ),
    );
  }
}
