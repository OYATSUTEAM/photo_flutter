import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/services/chat/chat_services.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/ui/other/other_profile_screen.dart';
import 'package:photo_sharing_app/widgets/blocktile.dart';
import 'package:photo_sharing_app/widgets/othertile.dart';

final ChatService chatService = locator.get();
final AuthServices authServices = locator.get();
ProfileServices profileServices = ProfileServices();

class BlockedUsers extends StatefulWidget {
  @override
  _BlockedUsersScreenState createState() => _BlockedUsersScreenState();
}

String email = 'default@gmail.com',
    name = 'ローディング...',
    username = 'ローディング...',
    uid = 'default';

class _BlockedUsersScreenState extends State<BlockedUsers> {
  Future<List<dynamic>?>? _otherUidFuture;
  String data = "Initial Data";
  @override
  void initState() {
    super.initState();
    getCurrentUserUID();
    updateData();
  }

  void getCurrentUserUID() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
        email = user.email!;
      });
    }
  }

  Future<void> updateData() async {
    setState(() {
      data = "Updated Data";
      _otherUidFuture = getBlockedUsers(uid); // Call the function
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: Text("ブロックとブロックされた")),
      body: FutureBuilder<List<dynamic>?>(
        future: _otherUidFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("データなし"));
          } else {
            final BlockedUsers = snapshot.data!;
            return ListView.builder(
              itemCount: BlockedUsers.length,
              itemBuilder: (context, index) {
                String otherUid = BlockedUsers[index];
                return ListTile(
                    title: Blocktile(
                  onButtonPressed: () => updateData,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            OtherProfile(otherUid: otherUid)));
                    if (!mounted) return;
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
