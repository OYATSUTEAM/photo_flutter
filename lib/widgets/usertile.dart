import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_sharing_app/data/global.dart';
import 'package:photo_sharing_app/services/other/other_service.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/ui/other/other_profile_screen.dart';

ProfileServices profileServices = ProfileServices();
// final otherService = OtherService(locator.get(), locator.get());
OtherService otherService = OtherService();

// final OtherService otherService;
class UserTile extends StatefulWidget {
  const UserTile(
      {super.key,
      required this.text,
      required this.onTap,
      required this.otherUserName,
      required this.otherName,
      required this.otherEmail,
      required this.otherUid});
  final String text;
  final void Function()? onTap;
  final String otherUid;
  final String otherUserName;
  final String otherName;
  final String otherEmail;
  @override
  _UserTileState createState() => _UserTileState();
}

bool isMeBlocked = false;

String email = 'default@gmail.com',
    name = 'ローディング...',
    username = 'ローディング...',
    uid = 'default';
bool isUserBlocked = false;
bool I_am_blocked = false;

class _UserTileState extends State<UserTile> {
  String? otherProfileURL;
  String _otherProfileURL = globalData.profileURL;
  @override
  void initState() {
    _setUpUserTile();
    getCurrentUserUID();

    super.initState();
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

  Future<void> _setUpUserTile() async {
    String fetchedURL = await getMainProfileUrl(widget.otherUid);
    final fetchedIsUserBlocked =
        await profileServices.isUserBlocked(uid, widget.otherUid);
    final fetchedIsMeBlocked =
        await profileServices.isMeBlocked(uid, widget.otherUid);
    if (mounted)
      setState(() {
        otherProfileURL = fetchedURL;
        isMeBlocked = fetchedIsMeBlocked;

        isUserBlocked = fetchedIsUserBlocked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: const Color.fromARGB(255, 129, 124, 124)),
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Align elements at both ends
              children: [
                IconButton(
                    icon: CircleAvatar(
                        backgroundImage: NetworkImage(otherProfileURL != null
                            ? otherProfileURL!
                            : _otherProfileURL),
                        radius: 25),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                OtherProfile(otherUid: widget.otherUid)),
                      );
                    }),
                Flexible(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis),
                    maxLines: 1, 
                  ),
                ),
                isUserBlocked
                    ? TextButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                          );
                          await otherService.unBlockThisUser(widget.otherUid);
                          Navigator.pop(context);

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                  content: Text("このユーザーのブロックを解除した"));
                            },
                          );
                          final currentContext = context;
                          setState(() {
                            _setUpUserTile();
                          });
                          await Future.delayed(Duration(milliseconds: 800));
                          Navigator.pop(currentContext);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            child: Text('unblock',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold))),
                      )
                    : TextButton(
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              });
                          await otherService.addUser(widget.otherUid);
                          Navigator.pop(context);
//==============================================================                 it is added
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(content: Text("追加された"));
                            },
                          );
                          final currentContext = context;

                          await Future.delayed(Duration(milliseconds: 500));
                          if (mounted) {
                            Navigator.pop(currentContext);
                          }
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            child: Text('add',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)))),
                if (isMeBlocked)
                  Text('blocked',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold))
              ],
            ),
          )),
    );
  }
}
