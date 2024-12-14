import 'package:flutter/material.dart';
import 'package:testing/DI/service_locator.dart';
import 'package:testing/services/other/other_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:testing/ui/other/other_profile_screen.dart';
import 'package:testing/widgets/othertile.dart';

// final OtherService otherService;
class UserTile extends StatefulWidget {
  const UserTile(
      {super.key, required this.text, required this.onTap, required this.uid});
  final String text;
  final void Function()? onTap;
  final String uid;
  @override
  _UserTileState createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  String? otherProfileURL;
  String _otherProfileURL = profileService.mainURL;
  @override
  void initState() {
    _setUpUserTile();
    super.initState();
  }

  Future<void> _setUpUserTile() async {
    String fetchedURL = await profileService.getMainProfileUrl(widget.uid);
    if (mounted)
      setState(() {
        otherProfileURL = fetchedURL;
      });
  }

  @override
  Widget build(BuildContext context) {
    final otherService = OtherService(locator.get(), locator.get());

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
            color: const Color.fromARGB(255, 17, 17, 17)),
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround, // Align elements at both ends
          children: [
            InkWell(
              child: CircleAvatar(
                backgroundImage: NetworkImage(otherProfileURL != null
                    ? otherProfileURL!
                    : _otherProfileURL),
                radius: 20,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OtherProfile(
                      otherUid: widget.uid,
                    ),
                  ),
                );
              },
            ),
            // const SizedBox(width: 1.0),
            Flexible(
              // Use Flexible to adapt text width
              child: Text(
                widget.text,
                style: TextStyle(
                  fontSize: 24, // Font size
                  fontWeight: FontWeight.bold, // Font weight (bold)
                  overflow: TextOverflow.ellipsis, // Handle long text
                ),
                maxLines: 1, // Prevent text from wrapping
              ),
            ),
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
                await otherService.updateOther(widget.uid);
                Navigator.pop(context);

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(
                          "追加された"), //////////////////////////it is added ///////////////////
                    );
                  },
                );
                final currentContext = context;

                await Future.delayed(Duration(milliseconds: 500));
                Navigator.pop(currentContext);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(12),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Text(
                  'add',
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
