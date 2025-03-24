// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/ui/auth/register_screen.dart';
import 'package:photo_sharing_app/home_screen.dart';
import 'package:photo_sharing_app/widgets/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool notvisible = true;
  bool notVisiblePassword = true;
  Icon passwordIcon = const Icon(Icons.visibility);



  void _loadSavedEmail() async {
    String? savedEmail = await getSavedEmail();
    if (savedEmail != null) {
      setState(() {
        emailController.text = savedEmail;
      });
    }
  }



  void isEmailVerified() {
    User user = FirebaseAuth.instance.currentUser!;
    if (user.emailVerified) {
      saveEmail(emailController.text.trim());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return HomeScreen();
        }),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('電子メールは確認されていません。')));
    }
  }
 
  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);
  }

  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_email');
  }

  Future<void> signIn() async {
    final authUser = AuthServices(locator.get(), locator.get());
    try {
      if (!RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(emailController.text.toString())) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            textAlign: TextAlign.center,
            '有効なメールアドレスを入力してください。',
          ),
          backgroundColor: const Color.fromARGB(255, 109, 209, 214),
        ));
        return;
      }
      showDialog(
          context: context,
          builder: (context) => Center(
                child: CircularProgressIndicator(),
              ));
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.toString(),
        password: passwordController.text.toString(),
      );
      if (mounted) {
        Navigator.pop(context);
      }
      isEmailVerified();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        const emailError = '有効なメールアドレスを入力してください。';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(emailError)));
      }
      if (e.code == 'wrong-password') {
        const passError = '正しいパスワードを入力してください。';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(passError)));
      }
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("登録されていません。今すぐ登録してください。")),
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

  void passwordVisibility() {
    if (notVisiblePassword) {
      passwordIcon = const Icon(Icons.visibility);
    } else {
      passwordIcon = const Icon(Icons.visibility_off);
    }
  }
@override
  void initState() {
    _loadSavedEmail();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: SafeArea(
                child: Center(
                    child: Padding(
                  padding: EdgeInsets.fromLTRB(35, 0, 35, 0),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 30),
                      Text("ログイン",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 30),
                      TextFormField(
                        decoration: InputDecoration(
                            icon: const Icon(Icons.alternate_email_outlined,
                                color: Colors.grey),
                            labelText: "メールアドレス"),
                        controller: emailController,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        obscureText: notvisible,
                        decoration: InputDecoration(
                            icon: const Icon(Icons.lock_outline_rounded,
                                color: Colors.grey),
                            labelText: "パスワード",
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    notvisible = !notvisible;
                                    notVisiblePassword = !notVisiblePassword;
                                    passwordVisibility();
                                  });
                                },
                                icon: passwordIcon)),
                        controller: passwordController,
                      ),
                      const SizedBox(height: 100),
                      MyButton(
                        text: "ログイン",
                        onTap: () async {
                          await signIn();
                        },
                      ),
                      const SizedBox(height: 15),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ))
                          ])
                    ],
                  ),
                )),
              ),
            )));
  }
}
