import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/services/chat/chat_services.dart';
import 'package:photo_sharing_app/ui/auth/login_screen.dart';
import 'package:photo_sharing_app/widgets/my_button.dart';

final ChatService chatService = locator.get();
final AuthServices authService = locator.get();
final FirebaseFirestore database = FirebaseFirestore.instance;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final auth = FirebaseAuth.instance;
  final authUser = AuthServices(locator.get(), locator.get());
  bool isLoading = true;
  bool isDialogShown = true;
  String uid = 'default@gmail.com';
  User? user = FirebaseAuth.instance.currentUser;
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
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '登録されたメールアドレスに確認メールが届いています。アカウントを確認し、再度ログインしてください。',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return LoginScreen();
                }),
              );
            }
            await authUser.register(email, password, name, username);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('お客様のアカウントは既に登録されていますので、ログインをお試しください。')),
            );
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return LoginScreen();
            }));
          }
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
            return AlertDialog(content: Text('${ex.toString()}'));
          },
        );
      }
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(content: Text("パスワードが一致しない"));
          });
    }
  }

  String selectedGender = '男';
  bool notvisible = true;
  bool notVisiblePassword = true;
  Icon passwordIcon = const Icon(Icons.visibility);
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void passwordVisibility() {
    if (notVisiblePassword) {
      passwordIcon = const Icon(Icons.visibility);
    } else {
      passwordIcon = const Icon(Icons.visibility_off);
    }
  }

  setGender(String? value) async {
    setState(() {
      selectedGender = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            // physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 35),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
// =========================================================  Sign Up Title =====================================================
                  Text("登録",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Form(
                      key: _formKey,
                      child: Column(
                        children: [
// =========================================================  Email ID  =====================================================
                          TextFormField(
                            decoration: InputDecoration(
                                icon: const Icon(Icons.alternate_email_outlined,
                                    color: Colors.grey),
                                labelText: "メールアドレス"),
                            controller: emailController,
                          ),
                          const SizedBox(height: 10),

// =========================================================  Name and Gender  =====================================================
                          Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: TextFormField(
                                  decoration: InputDecoration(
                                    icon: const Icon(Icons.account_circle,
                                        color: Colors.grey),
                                    labelText: "名前",
                                  ),
                                  controller: nameController,
                                )),

// // =========================================================  Gender Dropdown Button =================================================

                                DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    alignment: AlignmentDirectional.center,
                                    value: selectedGender,
                                    onChanged: (value) {
                                      if (value != null) {
                                        setGender(value);
                                      }
                                    },
                                    items: [
                                      DropdownMenuItem<String>(
                                          value: "男", child: Text("男")),
                                      DropdownMenuItem<String>(
                                          value: "女", child: Text("女")),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
// =========================================================  Username  =====================================================
                          TextFormField(
                            decoration: InputDecoration(
                                icon: const Icon(
                                  Icons.alternate_email_outlined,
                                  color: Colors.grey,
                                ),
                                labelText: "ユーザーネーム"),
                            controller: userNameController,
                          ),
// // =========================================================  Password  =====================================================
                          const SizedBox(height: 10),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "パスワードを空にすることはできません。";
                              } else if (value.length <= 5) {
                                return "パスワードは6文字以上でなければなりません。";
                              }
                              return null;
                            },
                            obscureText: notvisible,
                            decoration: InputDecoration(
                                icon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: Colors.grey,
                                ),
                                labelText: "パスワード",
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        notvisible = !notvisible;
                                        notVisiblePassword =
                                            !notVisiblePassword;
                                        passwordVisibility();
                                      });
                                    },
                                    icon: passwordIcon)),
                            controller: passwordController,
                          ),

// =========================================================  Password Confirm  =====================================================

                          const SizedBox(height: 10),
                          TextFormField(
                            obscureText: notvisible,
                            decoration: InputDecoration(
                                icon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: Colors.grey,
                                ),
                                labelText: "パスワードの確認",
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        notvisible = !notvisible;
                                        notVisiblePassword =
                                            !notVisiblePassword;
                                        passwordVisibility();
                                      });
                                    },
                                    icon: passwordIcon)),
                            controller: passwordConfirmController,
                          ),
                        ],
                      )),

                  const SizedBox(height: 50),

// =========================================================  SignUp Button =====================================================

                  MyButton(
                    text: "登録",
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        signUp(
                            emailController.text.trim(),
                            nameController.text.trim(),
                            userNameController.text.trim(),
                            passwordController.text.trim(),
                            passwordConfirmController.text.trim());
                      }
                      ;
                    },
                  ),

                  const SizedBox(height: 25),
                  Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
// =========================================================  Joined us before?  =====================================================

                      Text(
                        "会員でない？",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      ),
                      const SizedBox(width: 10),
// =========================================================  Login  =====================================================

                      GestureDetector(
                        child: Text(
                          "ログイン",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return LoginScreen();
                          }));
                        },
                      )
                    ],
                  ))
                ],
              ),
            ),
          ),
        ));
  }
}
