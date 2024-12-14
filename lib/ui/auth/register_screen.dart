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

class _RegisterScreenState extends State<RegisterScreen> {
  Future<void> signUp(
    String email,
    String name,
    String username,
  ) async {
    // bool isDialogShown = false;

    try {
      // Show loading dialog

      // Check if the email or username already exists
      final users = await chatService.getuserStream().first;
      final isExist = users.any((userData) => userData['email'] == email);
      final existingUserQuery = await _database
          .collection("Users")
          .where('username', isEqualTo: username)
          .get();

      if (isExist) {
        throw Exception(
            'ユーザは既に存在します！'); //////////////////////////////The user already exists!/////////////////////////////
      } else if (existingUserQuery.docs.isNotEmpty) {
        throw Exception(
            'ユーザー名はすでに使われています。\n別のユーザー名を選択してください。'); /////////Username is already in use. \Please select a different user name.////////
      }
      // if (mounted) {
      //   showDialog(
      //     context: context,
      //     builder: (context) {
      //       return Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     },
      //   );
      // }
      final finalContext = context;
      await authUser.signUp(email, '123456', name, username);
      if (finalContext.mounted) {
        Navigator.pop(finalContext); // Close the dialog
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

  @override
  Widget build(BuildContext context) {
    var emailController = TextEditingController();
    var nameController = TextEditingController();
    var userNameController = TextEditingController();
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
                  fontSize: 24,
                  color: Colors.white,
                  fontFamily: 'NotoSansJP',
                ),
              ),
              const SizedBox(height: 10),
              MyTextField(
                hint: "",
                obsecure: false,
                controller: emailController,
              ),
              const SizedBox(height: 10),
              Text(
                "名前",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              MyTextField(
                hint: "",
                obsecure: false,
                controller: nameController,
              ),
              const SizedBox(height: 10),
              Text(
                "ユーザー名",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              MyTextField(
                hint: "",
                obsecure: false,
                controller: userNameController,
              ),
              const SizedBox(height: 205),
              MyButton(
                text: "続ける",
                onTap: () {
                  signUp(
                    emailController.text.trim(),
                    nameController.text.trim(),
                    userNameController.text.trim(),
                  );
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
