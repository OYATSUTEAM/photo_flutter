// import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/data/global.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/services/chat/chat_services.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/ui/other/other_profile_screen.dart';
import 'package:photo_sharing_app/widgets/othertile.dart';

final ChatService chatService = locator.get();
final AuthServices authServices = locator.get();

class OtherUsers extends StatefulWidget {
  @override
  _OtherUsersScreenState createState() => _OtherUsersScreenState();
}

ProfileServices profileServices = ProfileServices();

class _OtherUsersScreenState extends State<OtherUsers> {
  Future<List<dynamic>?>? _otherUidFuture;
  String data = "Initial Data";
  @override
  void initState() {
    super.initState();
    _otherUidFuture = chatService.getOtherUidArray(); // Call the function
  }

  Future<void> updateData() async {
    setState(() {
      data = "Updated Data";
      _otherUidFuture = chatService.getOtherUidArray(); // Call the function
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: Text("他のユーザー"), centerTitle: true),
      body: FutureBuilder<List<dynamic>?>(
        future: _otherUidFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
                child: Text(
                    "データなし")); /////////////////////////////no data/////////////////
          } else {
            final OtherUsers = snapshot.data!;
            return ListView.builder(
              itemCount: OtherUsers.length,
              itemBuilder: (context, index) {
                String otherUid = OtherUsers[index];
                return ListTile(
                    title: OtherTile(
                  onButtonPressed: updateData,
                  onTap: () async {
                    bool isMeblocked = await profileServices.isMeBlocked(
                        globalData.myUid, otherUid);
                    final user = await authServices.getDocument(otherUid);

                    final fetchedBlock = await profileServices.isBlockTrue();
                    if (!isMeblocked) {
                      if (!mounted) return;
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              OtherProfile(otherUid: otherUid)));
                    }
                  },
                  otherUid: otherUid,
                ));
              },
            );
          }
        },
      ),
    ));
  }
}
