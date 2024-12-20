// import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:flutter/material.dart';
import 'package:testing/DI/service_locator.dart';
import 'package:testing/services/other/other_service.dart';
import 'package:testing/services/profile/profile_services.dart';
import 'package:testing/ui/other/other_profile_screen.dart';
import 'package:testing/ui/screen/chat_screen.dart';

final otherService = OtherService(locator.get(), locator.get());
ProfileServices profileService = ProfileServices();

class Othertile extends StatefulWidget {
  final void Function()? onTap;
  final String otherUid;
  final void Function()? onButtonPressed;
  const Othertile({
    super.key,
    required this.onTap,
    required this.otherUid,
    required this.onButtonPressed,
  });

  @override
  _OthertileState createState() => _OthertileState();
}

class _OthertileState extends State<Othertile> {
  String? username;
  bool isLoading = true;
  String? useremail;
  String? otherProfileURL;
  String _otherProfileURL = profileService.mainURL;
  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    try {
      String? fetchedUsername = await otherService.getUserName(widget.otherUid);
      String? fetchedUserEmail =
          await otherService.getUserEmail(widget.otherUid);
      String fetchedURL =
          await profileService.getMainProfileUrl(widget.otherUid);
      if (mounted) {
        setState(() {
          otherProfileURL = fetchedURL;
          username = fetchedUsername ?? 'unknown user';
          useremail = fetchedUserEmail ?? 'unknown user';
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
            InkWell(
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
            ),
            const SizedBox(width: 10.0),
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
            TextButton(
              onPressed: () async {
                String safeEmail = useremail ?? "defaultemail@example.com";
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      receiverEmail: safeEmail,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 5.0),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 5.0),
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
          ],
        ),
      ),
    );
  }
}
