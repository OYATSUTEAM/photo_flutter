import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'dart:io';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/ui/auth/reset_password.dart';
import 'package:photo_sharing_app/ui/camera/profile_camera_screen.dart';
import 'package:photo_sharing_app/ui/myProfile/myProfile.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:photo_sharing_app/widgets/my_button.dart';
import '../../data/global.dart';

final AuthServices authServices = locator.get();
final ProfileServices profileServices = ProfileServices();
// File? _imageFile;
File? _selectImage;
UploadTask? uploadTask;
List<File> allFileList = [];

class MyProfileEdit extends StatefulWidget {
  final String whichImage;
  const MyProfileEdit({super.key, required this.whichImage});
  @override
  _MyProfileEdit createState() => _MyProfileEdit();
}

class _MyProfileEdit extends State<MyProfileEdit> {
  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  String myMainProfileURL = profileServices.mainURL;
  String editProfileURL = profileServices.mainURL;

  String myProfileImage = '', editProfileImage = '';
  String email = globalData.myEmail;
  String uid = globalData.myUid;
  String username = globalData.myUserName;
  String name = globalData.myName;

  final currentUser = authServices.getCurrentuser();
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  bool isLoading = true;
  @override
  void initState() {
    _setUpInitial();
    fetchUsername();
    super.initState();
  }

  Future<void> _setUpInitial() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      setState(() {
        myProfileImage = '${directory.path}/$uid/myProfileImage';
        editProfileImage = '${directory.path}/$uid/editProfileImage';
      });
    } catch (e) {
      print('$e this error occurred in my profile.');
    }
  }

  Future<void> fetchUsername() async {
    try {
      final fetchedMainURL = await profileServices.getMainProfileUrl(uid);
      final fetchedEditURL = await profileServices.getEditProfileUrl(uid);
      Map<String, dynamic>? user = await authServices.getUserDetail(uid);
      final currentPassword = await profileServices.getUserPassword(uid);
      setState(() {
        username = user?['username'];
        name = user?['name'];
        myMainProfileURL = fetchedMainURL;
        editProfileURL = fetchedEditURL;
        nameController.text = name;
        usernameController.text = username;
        isLoading = false;
      });
    } catch (e) {
      print('$e this error occurred in my profile.');
      if (mounted)
        setState(() {
          username = "Error fetching username";
          name = "Error fetching username";
        });
    }
  }

  Future<void> _uploadFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      File imageFile = File(editProfileImage);

      await imageFile.copy('${directory.path}/$uid/myProfileImage.jpg');

      DateTime now = DateTime.now();
      String timestamp = now.toIso8601String();
      SettableMetadata metadata = SettableMetadata(customMetadata: {
        'timestamp': timestamp,
      });
      if (!await imageFile.exists()) {
        print("The file does not exist.");
        return;
      }
      List<int> imageData = await imageFile.readAsBytes();
      Uint8List uint8ImageData = Uint8List.fromList(imageData);

      final targetRef =
          FirebaseStorage.instance.ref().child("images/$uid/mainProfileImage");

      final uploadTask = targetRef.putData(uint8ImageData, metadata);
      await uploadTask.whenComplete(() => null);
      final snapshot = await uploadTask.whenComplete(() => null);
    } catch (e) {
      print('Error sharing image: $e');
    }
  }

  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Form(
          key: _formKey, // Attach form key to the Form widget
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 36),
                  // Profile Image
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: CircleAvatar(
                            backgroundImage:
                                widget.whichImage == 'myProfileImage'
                                    ? FileImage(File(myProfileImage))
                                    : FileImage(File(editProfileImage)),
                            radius:
                                MediaQuery.of(context).size.width * 0.5 * 0.5,
                          ),
                        ),
                        Positioned(
                          bottom: -8,
                          right: MediaQuery.of(context).size.width * 0.27,
                          child: IconButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => ProfileCameraScreen(),
                                ),
                              );
                            },
                            iconSize: 40,
                            icon: const Icon(
                              Icons.add_a_photo,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Name Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0),
                        child: Text('名前', style: TextStyle(fontSize: 20)),
//=========================================================                           name  =========================================
                      ),
                      SizedBox(
                        width: 200,
                        child: TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 20.0),
                          textAlign: TextAlign.center,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '名前を空にすることはできない';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Username Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text('ユーザーネーム', style: TextStyle(fontSize: 20)
// =========================================================                           username =============================================================
                            ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 20.0),
                          textAlign: TextAlign.center,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'ユーザーネームを空にすることはできません。';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
//=====================================================================                  reset password ==================================
                  MyButton(
                      text: "パスワード変更",
                      onTap: () async {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  ResetPasswordScreen(email: email, uid: uid)),
                        );
                      })
                ],
              ),
//=======================================================================                Cancel Button ==================================
              Positioned(
                top: 0,
                left: 8,
                child: TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MyProfileScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'キャンセル',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
//=======================================================================                 edit profile ===============================
              Positioned(
                left: MediaQuery.of(context).size.width * 0.3,
                top: 0,
                child: Text(
                  'プロフィールを編集',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
//=======================================================================                 Save Button
              Positioned(
                top: 0,
                right: 8,
                child: TextButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      // If all fields are valid, proceed
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );
                      if (mounted) {
                        await profileServices.updateProfile(
                          uid,
                          nameController.text.trim(),
                          usernameController.text.trim(),
                          email,
                        );
                      }
                      if (mounted) {
                        _uploadFile();
                        Navigator.pop(context);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => MyProfileScreen(),
                          ),
                        );
                      }
                    }
                    ;
                  },
//==============================================================================  save   ======================================================================
                  child: const Text(
                    '保存',
                    style: TextStyle(fontSize: 16, color: Colors.white),
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
