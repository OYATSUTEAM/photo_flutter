// import 'package:flutter/material.dart';
// import 'package:photo_sharing_app/DI/service_locator.dart';
// import 'package:photo_sharing_app/services/auth/auth_service.dart';
// import 'package:photo_sharing_app/services/chat/chat_services.dart';
// import 'package:photo_sharing_app/ui/camera/camera_screen.dart';
// import 'package:photo_sharing_app/ui/screen/home_screen.dart';
// import 'package:photo_sharing_app/ui/myProfile/myProfile.dart';
// import 'package:photo_sharing_app/ui/screen/search_user_screen.dart';
// import 'package:photo_sharing_app/widgets/my_drawer.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// final ChatService _chatService = locator.get();
// final AuthServices authServices = locator.get();

// late String fromWhere;
// // final Future<Map<String, dynamic>?> userDetail =
// //     AuthServices(locator.get(), locator.get()).getUserDetail(uid);
// String email = 'default@gmail.com',
//     name = 'ローディング...',
//     username = 'ローディング...',
//     uid = 'default';
// String myProfileURL =
//     "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTqafzhnwwYzuOTjTlaYMeQ7hxQLy_Wq8dnQg&s";

// class BannerScreen extends StatefulWidget {
//   const BannerScreen({super.key});

//   @override
//   _BannerScreen createState() => _BannerScreen();
// }

// class _BannerScreen extends State<BannerScreen> {
//   @override
//   void initState() {
//     uid = authServices.getCurrentuser()!.uid;
//     _setProfileInitiate();
//     fetchUsername();
//     super.initState();
//   }

//   Future<void> _setProfileInitiate() async {
//     try {
//       email = await authServices.getCurrentuser()!.email!;
//       final profileRef =
//           FirebaseStorage.instance.ref().child("images/$uid/mainProfileImage");
//       // await profileRef.getMetadata();
//       String fetchedUrl = await profileRef.getDownloadURL();

//       if (mounted) {
//         setState(() {
//           myProfileURL = fetchedUrl; // Update the state after fetching URL
//         });
//       }
//     } catch (e) {
//       print(e);
//       return null;
//     }
//   }

//   Future<void> fetchUsername() async {
//     try {
//       final users = await _chatService.getuserStream().first;

//       final user = users.firstWhere(
//         (userData) => userData['email'] == email,
//         // orElse: () =>  userData['email'] != email,
//       );

//       setState(() {
//         username = user['username'];
//       });
//     } catch (e) {
//       // Handle any errors
//       setState(() {
//         username = "Error fetching username";
//       });
//       debugPrint("Error fetching username: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Scaffold(
//             drawer: MyDrawer(email: email),
//             backgroundColor: Theme.of(context).colorScheme.surface,
//             appBar: AppBar(
//               backgroundColor: Colors.transparent,
//               foregroundColor: Colors.grey,
//               elevation: 0,
//               title: const Text("バナー"),
//               centerTitle: true,
//             ),
//             body: Stack(children: [
//               Positioned(
//                 bottom: 30, // 30 pixels from the bottom
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   child: Padding(
//                       padding: const EdgeInsets.fromLTRB(30.0, 8.0, 30.0, 8.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           //========================================================  home button======================================
//                           IconButton(
//                             onPressed: () async {
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                   builder: (context) => HomeScreen(),
//                                 ),
//                               );
//                             },
//                             iconSize: 40,
//                             icon: const Icon(
//                               Icons.home_outlined,
//                               color: Colors.white,
//                               weight: 100,
//                             ),
//                           ),
//                           //===============================================================post button======================================
//                           IconButton(
//                             onPressed: () async {
//                               showDialog(
//                                   context: context,
//                                   builder: (context) {
//                                     return const Center(
//                                       child: CircularProgressIndicator(),
//                                     );
//                                   });
//                               Navigator.pop(context);
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                     builder: (context) => CameraScreen()),
//                               );
//                               if (!mounted) return;
//                             },
//                             iconSize: 40,
//                             icon: const Icon(
//                               Icons.add,
//                               color: Colors.white,
//                             ),
//                           ),
//                           //=================================================== search button ============================================================
//                           IconButton(
//                             onPressed: () async {
//                               showDialog(
//                                   context: context,
//                                   builder: (context) {
//                                     return const Center(
//                                       child: CircularProgressIndicator(),
//                                     );
//                                   });
//                               if (!mounted) return;
//                               Navigator.pop(context);
//                               // setState(() {});
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                   builder: (context) => SearchUser(),
//                                 ),
//                               );
//                             },
//                             iconSize: 40,
//                             icon: const Icon(
//                               Icons.search,
//                               color: Colors.white,
//                             ),
//                           ),
//                           //=========================================== avatar button ======================================================

//                           FloatingActionButton(
//                             backgroundColor: Colors.transparent,
//                             child: CircleAvatar(
//                               backgroundImage: NetworkImage(myProfileURL),
//                               radius: 20,
//                             ),
//                             onPressed: () async {
//                               showDialog(
//                                   context: context,
//                                   builder: (context) {
//                                     return const Center(
//                                       child: CircularProgressIndicator(),
//                                     );
//                                   });
//                               _setProfileInitiate();
//                               // Navigator.pop(context);

//                               Navigator.of(context).pushReplacement(
//                                 MaterialPageRoute(
//                                   builder: (context) {
//                                     return MyProfileScreen();
//                                   },
//                                 ),
//                               );
//                             },
//                           ),

//                           ///   transfer button
//                         ],
//                       )
//                       //   ],
//                       // ),
//                       ),
//                 ),
//               )
//             ])));
//   }
// }
