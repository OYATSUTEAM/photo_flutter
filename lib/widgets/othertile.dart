// import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testing/services/other/other_service.dart';
import 'package:testing/services/profile/profile_services.dart';
import 'package:testing/ui/other/other_profile_screen.dart';
import 'package:testing/ui/screen/chat_screen.dart';

OtherService otherService = OtherService();

// final otherService = OtherService(locator.get(), locator.get());
ProfileServices profileServices = ProfileServices();

class OtherTile extends StatefulWidget {
  final void Function()? onTap;
  final String otherUid;
  final void Function()? onButtonPressed;
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
  String? username;
  bool isLoading = true;
  String? useremail;
  String? otherProfileURL;
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
      String fetchedURL =
          await profileServices.getMainProfileUrl(widget.otherUid);
      final fetchedIsUserBlocked =
          await profileServices.isUserBlocked(uid, widget.otherUid);
      final fetchedIsMeBlocked =
          await profileServices.isMeBlocked(uid, widget.otherUid);
      if (mounted) {
        setState(() {
          otherProfileURL = fetchedURL;
          username = fetchedUsername ?? 'unknown user';
          useremail = fetchedUserEmail ?? 'unknown user';
          isUserBlocked = fetchedIsUserBlocked;
          isMeBlocked = fetchedIsMeBlocked;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        username = 'Error loading username';

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
            // const SizedBox(width: 1),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  // backgroundColor: Colors.transparent,
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
                            child: CircularProgressIndicator(),
                          );
                        });
                    await Future.delayed(
                        Duration(seconds: 1)); // Simulating a delay
                    if (mounted) Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return OtherProfile(
                            otherUid: widget.otherUid,
                          );
                        },
                      ),
                    );
                  },
                )),
            // const SizedBox(width: 1.0),
            Flexible(
              child: Text(
                isLoading ? 'Loading...' : username!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
            ),

            if (isUserBlocked)
              TextButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                  await otherService.unBlockThisUser(widget.otherUid);
                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text(
                            "このユーザーのブロックを解除した"), //////////////////////////it is added ///////////////////
                      );
                    },
                  );
                  final currentContext = context;
                  setState(() {
                    _loadUsername();
                  });
                  await Future.delayed(Duration(milliseconds: 800));
                  Navigator.pop(currentContext);
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
                  if (mounted) {
                    widget.onButtonPressed!();
                    await otherService.deleteOther(widget.otherUid);
                    Navigator.pop(context);
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
                    'delete',
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        receiverEmail: useremail!,
                        receiverId: widget.otherUid,
                      ),
                    ),
                  );
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
                      fontSize: 14, // Font size
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
                  fontSize: 14, // Font size
                  fontWeight: FontWeight.bold, // Font weight (bold)
                ),
              ),
          ],
        ),
      ),
    );
  }
}
