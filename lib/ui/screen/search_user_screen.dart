import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:photo_sharing_app/DI/service_locator.dart';
import 'package:photo_sharing_app/services/auth/auth_service.dart';
import 'package:photo_sharing_app/services/chat/chat_services.dart';
import 'package:photo_sharing_app/services/config.dart';
import 'package:photo_sharing_app/ui/screen/chat_screen.dart';
import 'package:photo_sharing_app/widgets/usertile.dart';

final ChatService _chatService = locator.get();
final AuthServices authServices = locator.get();

class SearchUser extends StatefulWidget {
  const SearchUser({super.key});

  @override
  _SearchUserState createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  late TextEditingController searchController;
  late FocusNode searchFocusNode;
  String query = "";

  @override
  void initState() {
    super.initState();
    requestPermission();
    query = query;
    searchController = TextEditingController(text: query);
    searchFocusNode = FocusNode();

    // Request focus on the search bar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocusNode.requestFocus();
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted permission");
    } else {
      print("User denied permission");
    }
  }

  void updateSearchQuery() {
    setState(() {
      query = searchController.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        toolbarHeight: 55,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: SizedBox(
            height: 35,
            child: TextField(
              controller: searchController,
              focusNode: searchFocusNode,
              decoration: InputDecoration(
                hintText: "検索",
                hintStyle: const TextStyle(fontSize: 13.0, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(15.0)),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(15.0)),
                filled: true,
                fillColor: Colors.grey,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
              ),
              onChanged: (searchText) {
                updateSearchQuery();
              },
            ),
          ),
        ),
      ),
      body: BuildUserList(query: query),
    ));
  }
}

class BuildUserList extends StatelessWidget {
  final String query;
  const BuildUserList({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getuserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "エラー", // Error
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary, fontSize: 20.0),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "ローディング", // Loading
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 20),
                ),
                const SizedBox(width: 5),
                SpinKitWanderingCubes(
                    color: Theme.of(context).colorScheme.primary, size: 30.0),
              ],
            ),
          );
        }

        final filteredUsers = query.isEmpty
            ? []
            : snapshot.data?.where((user) {
                  final userName =
                      (user['name'] as String?)?.toLowerCase() ?? '';
                  return userName.contains(query.toLowerCase());
                }).toList() ??
                [];

        return Column(
          children: [
            Expanded(
              child: filteredUsers.isEmpty
                  ? Center(
                      child: Text(
                        "ユーザーが見つかりません", // User not found
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return BuilduserStreamList(otherUserdata: user);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class BuilduserStreamList extends StatelessWidget {
  final Map<String, dynamic> otherUserdata;

  const BuilduserStreamList({super.key, required this.otherUserdata});

  @override
  Widget build(BuildContext context) {
    final currentUser = authServices.getCurrentuser();

    if (currentUser == null) {
      return const Center(
          child: Text("現在ログインしているユーザーはいません")); // No user is currently logged in
    }

    final otherEmail = otherUserdata['email'] ?? '';
    final otherUid = otherUserdata['uid'] ?? '';
    final otherName = otherUserdata['name'] ?? "";
    final otherUserName = otherUserdata['username'] ?? "";
    if (otherEmail != currentUser.email) {
      return Column(
        children: [
          SizedBox(height: 10),
          UserTile(
              otherEmail: otherEmail,
              otherUserName: otherUserName,
              otherName: otherName,
              text: otherName,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ChatScreen(
                      receiverName: otherUserName,
                      receiverUserName: otherUserName,
                      receiverEmail: otherEmail,
                      receiverId: otherUid);
                }));
              },
              otherUid: otherUid)
        ],
      );
    }

    return const SizedBox
        .shrink(); // Return an empty widget if the condition fails
  }
}
