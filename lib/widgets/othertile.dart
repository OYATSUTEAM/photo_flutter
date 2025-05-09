// import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_sharing_app/services/other/other_service.dart';
import 'package:photo_sharing_app/services/profile/profile_services.dart';
import 'package:photo_sharing_app/ui/other/other_profile_screen.dart';
import 'package:photo_sharing_app/ui/other/report_screen.dart';
import 'package:photo_sharing_app/ui/screen/chat_screen.dart';

OtherService otherService = OtherService();

// final otherService = OtherService(locator.get(), locator.get());
ProfileServices profileServices = ProfileServices();

class OtherTile extends StatefulWidget {
  final void Function()? onTap;
  final String otherUid;
  final VoidCallback onButtonPressed;
  const OtherTile({
    super.key,
    required this.onTap,
    required this.otherUid,
    required this.onButtonPressed,
  });

  @override
  OtherTileState createState() => OtherTileState();
}

bool isUserBlocked = false;
bool isMeBlocked = false;

class OtherTileState extends State<OtherTile> {
  String otherName = '';
  String otherUserName = '';
  bool isLoading = true;
  String otherEmail = 'default';
  String otherProfileURL = '';
  String _otherProfileURL = profileServices.mainURL;
  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<String> getCurrentUserUID() async {
    User? user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    return 'default@gmail.com';
  }

  Future<void> _loadUsername() async {
    final uid = await getCurrentUserUID();
    try {
      String? fetchedUsername = await otherService.getUserName(widget.otherUid);
      String? fetchedUserEmail =
          await otherService.getUserEmail(widget.otherUid);
      String fetchedURL = await getMainProfileUrl(widget.otherUid);
      final fetchedIsUserBlocked =
          await profileServices.isUserBlocked(uid, widget.otherUid);
      final fetchedIsMeBlocked =
          await profileServices.isMeBlocked(uid, widget.otherUid);
      if (mounted) {
        setState(() {
          otherProfileURL = fetchedURL;
          otherUserName = fetchedUsername ?? 'unknown user';
          otherEmail = fetchedUserEmail ?? 'unknown user';
          isUserBlocked = fetchedIsUserBlocked;
          isMeBlocked = fetchedIsMeBlocked;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        otherUserName = 'Error loading username';

        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(58, 174, 182, 174),
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        // padding: const EdgeInsets.all(10.0),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(otherProfileURL != null
                        ? otherProfileURL!
                        : _otherProfileURL),
                    radius: 20,
                  ),
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const Center(
                              child: CircularProgressIndicator());
                        });
                    await Future.delayed(Duration(seconds: 1));
                    if (mounted) Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return OtherProfile(otherUid: widget.otherUid);
                        },
                      ),
                    );
                  },
                )),
            Flexible(
              child: Text(
                isLoading ? 'Loading...' : otherUserName,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis),
                maxLines: 1,
              ),
            ),
            if (isUserBlocked)
              TextButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const Center(child: CircularProgressIndicator());
                    },
                  );
                  await otherService.unBlockThisUser(widget.otherUid);
                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(content: Text("このユーザーのブロックを解除した"));
                    },
                  );
                  final currentContext = context;
                  setState(() {
                    _loadUsername();
                  });
                  await Future.delayed(Duration(milliseconds: 800));
                  if (mounted) Navigator.pop(currentContext);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  child: Text(
                    'unblock',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14, // Font size
                      fontWeight: FontWeight.bold, // Font weight (bold)
                    ),
                  ),
                ),
              ),
            if (!isUserBlocked)
              TextButton(
                onPressed: () async {
                  // if (mounted) {
                  widget.onButtonPressed();
                  await otherService.deleteOther(widget.otherUid);
                  // }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 5.0),
                  child: Text(
                    'delete',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14, // Font size
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (!isUserBlocked)
              TextButton(
                onPressed: () async {
                  if (mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          receiverUserName: otherUserName,
                          receiverName: otherName,
                          receiverEmail: otherEmail,
                          receiverId: widget.otherUid,
                        ),
                      ),
                    );
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
                      horizontal: 6.0, vertical: 5.0),
                  child: Text(
                    'chat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12, // Font size
                      fontWeight: FontWeight.bold, // Font weight (bold)
                    ),
                  ),
                ),
              ),
            if (isMeBlocked)
              Text(
                'blocked',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12, // Font size
                  fontWeight: FontWeight.bold, // Font weight (bold)
                ),
              ),
          ],
        ),
      ),
    );
  }
}
