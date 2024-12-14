import 'package:flutter/material.dart';

// final OtherService otherService;
class Posttile extends StatelessWidget {
  const Posttile({
    super.key,
    required this.image_provider,
    required this.onTap,
    required this.onDeletePressed,
  });
  final Image image_provider;
  final void Function()? onTap;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    // final FirebaseAuth user = locator.get();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Stack(
          children: [
            Image(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height * 0.5,
              image: image_provider.image,
              // fit: BoxFit.fitWidth,
            ),
            Positioned(
              top: 0, // 20 pixels from the top
              right: 0, // 20 pixels from the left
              child: IconButton(
                onPressed: onDeletePressed,
                icon: const Icon(
                  Icons.delete_forever,
                  color: Color.fromARGB(174, 158, 158, 158),
                  size: 25,
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }
}
