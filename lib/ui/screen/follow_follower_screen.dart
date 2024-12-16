import 'package:flutter/material.dart';
import 'package:testing/DI/service_locator.dart';
import 'package:testing/services/auth/auth_service.dart';
import 'package:testing/services/chat/chat_services.dart';
import 'package:testing/services/folllow_follower_services/follow_follower_service.dart';
import 'package:testing/ui/other/other_profile_screen.dart';
import 'package:testing/widgets/othertile.dart';

final ChatService chatService = locator.get();
final AuthServices authServices = locator.get();
final FollowAndFollowerService followAndfollowerService = locator.get();

class FollowAndFollower extends StatefulWidget {
  @override
  _FollowAndFollowerState createState() => _FollowAndFollowerState();
}

Future<List<dynamic>?>? _followUidFuture;
Future<List<dynamic>?>? _followerUidFuture;

class _FollowAndFollowerState extends State<FollowAndFollower>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String data = "Initial Data";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _followUidFuture = followAndfollowerService.getFollowUidArray();
    _followerUidFuture = followAndfollowerService.getFollowerUidArray();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  void updateData() {
    setState(() {
      data = "Updated Data";
      print(
          "void callBack is called !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          dividerHeight: 0,
          tabs: [
            Tab(text: "フォロー中"),
            Tab(text: "フォロワー"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FollowScreen(),
          FollowerScreen(),
        ],
      ),
    );
  }

  Widget FollowScreen() {
    return SafeArea(
        child: Scaffold(
      body: FutureBuilder<List<dynamic>?>(
        future: _followUidFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("フォローはありません"));
          } else {
            final otherArray = snapshot.data!;
            return ListView.builder(
              itemCount: otherArray.length,
              itemBuilder: (context, index) {
                String otherUid = otherArray[index];
                // print(
                //     'otherUid : $otherUid !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
                return ListTile(
                    title: Othertile(
                  onButtonPressed: updateData,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            OtherProfile(otherUid: otherUid)));
                    // if (!mounted) return;
                  },
                  otherUid: otherArray[index]!,
                ));
              },
            );
          }
        },
      ),
    ));
  }

  Widget FollowerScreen() {
    return Scaffold(
      body: FutureBuilder<List<dynamic>?>(
        future: _followerUidFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("フォロワーはいません"));
          } else {
            final otherArray = snapshot.data!;
            return ListView.builder(
              itemCount: otherArray.length,
              itemBuilder: (context, index) {
                print(otherArray[index]);
                String otherUid = otherArray[index];
                return ListTile(
                    title: Othertile(
                  onButtonPressed: updateData,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            OtherProfile(otherUid: otherUid)));
                    // if (!mounted) return;
                  },
                  otherUid: otherArray[index]!,
                ));
              },
            );
          }
        },
      ),
    );
  }
}
