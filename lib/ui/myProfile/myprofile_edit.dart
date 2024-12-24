import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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

final AuthServices _authServices = locator.get();
final ProfileServices profileServices = ProfileServices();
// File? _imageFile;
File? _selectImage;
UploadTask? uploadTask;
List<File> allFileList = [];

class MyProfileEdit extends StatefulWidget {
  const MyProfileEdit({
    super.key,
    required this.whichProfile,
  });
  final String whichProfile;
  @override
  _MyProfileEdit createState() => _MyProfileEdit();
}

class _MyProfileEdit extends State<MyProfileEdit> {
  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  String myMainProfileURL = profileServices.mainURL;
  String editProfileURL = profileServices.mainURL;
  String email = 'default@gmail.com',
      uid = 'default',
      username = 'ローディング...',
      name = 'ローディング...',
      password = '``````';
  final currentUser = _authServices.getCurrentuser();
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
      final fetchedUid = _authServices.getCurrentuser()!.uid;
      final fetchedEmail = _authServices.getCurrentuser()!.email;
      setState(() {
        uid = fetchedUid;
        email = fetchedEmail!;
      });
    } catch (e) {
      print('$e this error occurred in my profile.');
    }
  }

  Future<void> fetchUsername() async {
    try {
      final fetchedMainURL = await profileServices.getMainProfileUrl(uid);
      final fetchedEditURL = await profileServices.getEditProfileUrl(uid);
      Map<String, dynamic>? user = await _authServices.getUserDetail(uid);
      final currentPassword = await profileServices.getUserPassword(uid);
      setState(() {
        username = user?['username'];
        name = user?['name'];
        myMainProfileURL = fetchedMainURL;
        editProfileURL = fetchedEditURL;
        password = currentPassword;
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
      final sourceRef =
          FirebaseStorage.instance.ref().child('images/$uid/editProfileImage');
      DateTime now = DateTime.now();
      String timestamp = now.toIso8601String();
      SettableMetadata metadata = SettableMetadata(customMetadata: {
        'timestamp': timestamp,
      });
      final downloadUrl = await sourceRef.getDownloadURL();
      print('Source download URL: $downloadUrl');

      final http.Response response = await http.get(Uri.parse(downloadUrl));

      if (response.statusCode == 200) {
        final Uint8List imageData = response.bodyBytes;

        final targetRef = FirebaseStorage.instance
            .ref()
            .child("images/$uid/mainProfileImage");

        final uploadTask = targetRef.putData(imageData, metadata);
        final snapshot = await uploadTask.whenComplete(() => null);
        final newDownloadUrl = await snapshot.ref.getDownloadURL();

        print('Re-upload complete. New download URL: $newDownloadUrl');
      } else {
        print('Failed to download image: ${response.statusCode}');
      }
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
                            backgroundImage: NetworkImage(
                                widget.whichProfile == 'myMainProfileURL'
                                    ? myMainProfileURL
                                    : editProfileURL),
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
                                  builder: (context) => ProfileCameraScreen(
                                      whichProfile: 'editProfile'),
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
                        child: Text(
                          '名前', ////////////////////////////////////////////////////////////////////////        name
                          style: TextStyle(fontSize: 20),
                        ),
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
                        child: Text(
                          'ユーザーネーム', /////////////////////////////////////////////////////////////////// username
                          style: TextStyle(fontSize: 20),
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

                  MyButton(
                      text: "ログイン",
                      onTap: () async {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => ResetPasswordScreen(
                                  whichProfile: widget.whichProfile,
                                  email: email,
                                  uid: uid)),
                        );
                      })
                ],
              ),
              // Cancel Button
              Positioned(
                top: 0,
                left: 8,
                child: TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => MyProfile(),
                      ),
                    );
                  },
                  child: const Text(
                    'キャンセル',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width * 0.3,
                top: 0,
                child: Text(
                  'プロフィールを編集',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              // Save Button
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
                          password,
                        );
                      }
                      if (!mounted) return;
                      if (mounted) {
                        widget.whichProfile != 'myMainProfileURL'
                            ? _uploadFile().then((_) {
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => MyProfile(),
                                  ),
                                );
                              })
                            : null;
                      }
                    }
                    ;
                  },
//==============================================================================  save   ======================================================================
                  child: const Text(
                    '保存',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
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
