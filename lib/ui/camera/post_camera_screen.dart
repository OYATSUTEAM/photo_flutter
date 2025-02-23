import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_sharing_app/ui/auth/register_screen.dart';
// import 'package:photo_sharing_app/ui/camera/captures_screen.dart';
import 'package:photo_sharing_app/ui/camera/post_preview_screen.dart';
// import 'package:photo_sharing_app/ui/camera/preview_screen.dart';
// import 'package:photo_sharing_app/ui/camera/profile_set_screen.dart';
// import 'package:photo_sharing_app/ui/screen/post_screen.dart';

import '../../main.dart';

class PostCameraScreen extends StatefulWidget {
  final bool isDelete;
  const PostCameraScreen({super.key, required this.isDelete});
  @override
  _PostCameraScreenState createState() => _PostCameraScreenState();
}

class _PostCameraScreenState extends State<PostCameraScreen>
    with WidgetsBindingObserver {
  final List<String> allPostFileList = [];
  CameraController? controller;
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isRearCameraSelected = true;
  FlashMode? _currentFlashMode;

  List<File> allFileList = [];

  final resolutionPresets = ResolutionPreset.ultraHigh;

  ResolutionPreset currentResolutionPreset = ResolutionPreset.ultraHigh;

  getPermissionStatus() async {
    await Permission.camera.request();
    await refreshAlreadyCapturedImages();
    var status = await Permission.camera.status;

    if (status.isGranted) {
      log('Camera Permission: GRANTED');
      setState(() {
        _isCameraPermissionGranted = true;
      });
      // Set and initialize the new camera
      onNewCameraSelected(cameras[1]);
      refreshAlreadyCapturedImages();
    } else {
      log('Camera Permission: DENIED');
    }
  }

  refreshAlreadyCapturedImages() async {
    // final directory = await getApplicationDocumentsDirectory();
    // final subDir = Directory('${directory.path}/$uid/postImages');

    // if (await subDir.exists()) {
    //   try {
    //     for (final file in subDir.listSync()) {
    //       if (file is File) {
    //         await file.delete();
    //       }
    //     }
    //     print("All files deleted successfully.");
    //   } catch (e) {
    //     print("Error deleting files: $e");
    //   }
    // } else {
    //   print("Directory does not exist: ${subDir.path}");
    // }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<void> _toggleFlashMode(FlashMode mode) async {
    if (controller == null || !controller!.value.isInitialized) return;

    try {
      await controller!.setFlashMode(mode);
      setState(() => _currentFlashMode = mode);
    } catch (e) {
      log('Error setting flash mode: $e');
    }
  }

  void resetCameraValues() async {}

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    resetCameraValues();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();

      _currentFlashMode = controller!.value.flashMode;
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  void initStateCamera() async {
    final directory = await getApplicationDocumentsDirectory();
    final subDir = Directory('${directory.path}/$uid/postImages');
    if (widget.isDelete) {
      if (await subDir.exists()) {
        try {
          for (final file in subDir.listSync()) {
            if (file is File) {
              await file.delete();
            }
          }
          print("All files deleted successfully.");
        } catch (e) {
          print("Error deleting files: $e");
        }
      } else {
        print("Directory does not exist: ${subDir.path}");
      }
    }
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller!.setExposurePoint(offset);
    controller!.setFocusPoint(offset);
  }

//==================================================================     initstate   =================================================
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer
    getPermissionStatus();
    initStateCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    if (controller != null) {
      controller?.dispose();
      controller = null; // Nullify the controller reference for safety.
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          // backgroundColor: Colors.grey,

          body: _isCameraPermissionGranted
              ? _isCameraInitialized
                  ? Stack(children: [
                      Column(
                        children: [
                          SizedBox(
                            height: 15,
                            width: MediaQuery.of(context).size.width,
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.78,
                            width: MediaQuery.of(context).size.width * 0.99,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(340.0),
                              color: Colors.black,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(38.0),
                              child: CameraPreview(controller!),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton<FlashMode>(
                                        value: _currentFlashMode,
                                        icon: const SizedBox.shrink(),
                                        alignment: Alignment.topLeft,
                                        dropdownColor: const Color.fromARGB(
                                            99, 21, 22, 21),
                                        onChanged: (FlashMode? newMode) {
                                          if (newMode != null) {
                                            _toggleFlashMode(newMode);
                                          }
                                        },
                                        items: [
                                          DropdownMenuItem<FlashMode>(
                                            value: FlashMode.off,
                                            child: Icon(Icons.flash_off,
                                                size: 30,
                                                color: _currentFlashMode ==
                                                        FlashMode.off
                                                    ? Colors.yellow
                                                    : Colors.white),
                                          ),
                                          DropdownMenuItem<FlashMode>(
                                            value: FlashMode.auto,
                                            child: Icon(
                                              Icons.flash_auto,
                                              size: 30,
                                              color: _currentFlashMode ==
                                                      FlashMode.auto
                                                  ? Colors.yellow
                                                  : Colors.white,
                                            ),
                                          ),
                                          DropdownMenuItem<FlashMode>(
                                            value: FlashMode.always,
                                            child: Icon(
                                              size: 30,
                                              Icons.flash_on,
                                              color: _currentFlashMode ==
                                                      FlashMode.always
                                                  ? Colors.yellow
                                                  : Colors.white,
                                            ),
                                          ),
                                          DropdownMenuItem<FlashMode>(
                                            value: FlashMode.torch,
                                            child: Icon(
                                              Icons.highlight,
                                              size: 30,
                                              color: _currentFlashMode ==
                                                      FlashMode.torch
                                                  ? Colors.yellow
                                                  : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        XFile? rawImage = await takePicture();
                                        File imageFile = File(rawImage!.path);

                                        int currentUnix = DateTime.now()
                                            .millisecondsSinceEpoch;

                                        final directory =
                                            await getApplicationDocumentsDirectory();
                                        final subDir = Directory(
                                            '${directory.path}/$uid/postImages');
                                        if (!(await subDir.exists())) {
                                          await subDir.create(recursive: true);
                                        }
                                        String fileFormat =
                                            imageFile.path.split('.').last;

                                        await imageFile.copy(
                                          '${directory.path}/$uid/postImages/$currentUnix.$fileFormat',
                                        );

                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PostPreviewScreen()),
                                        );
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          const Icon(
                                              Icons.radio_button_unchecked,
                                              size: 60,
                                              color: Colors.white),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _isCameraInitialized = false;
                                        });
                                        onNewCameraSelected(cameras[
                                            _isRearCameraSelected ? 1 : 0]);
                                        setState(() {
                                          _isRearCameraSelected =
                                              !_isRearCameraSelected;
                                        });
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Icon(
                                              _isRearCameraSelected
                                                  ? Icons.camera_front
                                                  : Icons.camera_rear,
                                              color: Colors.white,
                                              size: 30)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.red, size: 34),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ])
                  : Center(
                      child:
                          Text('読み込み中', style: TextStyle(color: Colors.white)))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(),
                    Text('Permission denied',
                        style: TextStyle(color: Colors.white, fontSize: 24)),
                    SizedBox(height: 24),
                    ElevatedButton(
                        onPressed: () {
                          getPermissionStatus();
                        },
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Give permission',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 24))))
                  ],
                )),
    );
  }
}
