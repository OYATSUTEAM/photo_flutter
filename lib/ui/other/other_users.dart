// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testing/DI/service_locator.dart';
import 'package:testing/services/auth/auth_service.dart';
import 'package:testing/services/chat/chat_services.dart';
import 'package:testing/ui/other/other_profile_screen.dart';
import 'package:testing/widgets/othertile.dart';

final ChatService chatService = locator.get();
final AuthServices authServices = locator.get();

class OtherUsers extends StatefulWidget {
  @override
  _OtherUsersScreenState createState() => _OtherUsersScreenState();
}

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
      appBar: AppBar(title: Text("他のユーザー")),
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
                    title: Othertile(
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
