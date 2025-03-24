import 'package:flutter/material.dart';

class PasswordTextfield extends StatefulWidget {
  final String hint;
  final bool obsecure;
  final TextEditingController controller;
  final FocusNode? focusNode;
  const PasswordTextfield(
      {super.key,
      required this.hint,
      required this.obsecure,
      required this.controller,
      this.focusNode});
  @override
  _PasswordTextfield createState() => _PasswordTextfield();
}

class _PasswordTextfield extends State<PasswordTextfield> {
  Icon passwordIcon = const Icon(Icons.visibility);

  bool notvisible = true;
  bool notVisiblePassword = true;

  void passwordVisibility() {
    if (notVisiblePassword) {
      passwordIcon = const Icon(Icons.visibility);
    } else {
      passwordIcon = const Icon(Icons.visibility_off);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: SizedBox(
          height: 40,
          child: TextField(
            focusNode: widget.focusNode,
            controller: widget.controller,
            obscureText: notvisible,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      notvisible = !notvisible;
                      notVisiblePassword = !notVisiblePassword;
                      passwordVisibility();
                    });
                  },
                  icon: passwordIcon),
              contentPadding: EdgeInsets.symmetric(
                vertical: 10.0, // Adjust the vertical padding
                horizontal: 18.0, // Adjust the horizontal padding if needed
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                borderRadius:
                    BorderRadius.circular(15.0), // Set the border radius here
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
                borderRadius:
                    BorderRadius.circular(15.0), // Set the border radius here
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.secondary,
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ));
  }
}
