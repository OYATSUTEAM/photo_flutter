import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  const MyTextField(
      {super.key,
      required this.hint,
      required this.obsecure,
      required this.controller,
      this.focusNode});
  final String hint;
  final bool obsecure;
  final TextEditingController controller;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 0),
        child: SizedBox(
          height: 40,
          child: TextField(
            focusNode: focusNode,
            controller: controller,
            obscureText: obsecure,
            decoration: InputDecoration(
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
              hintText: hint,
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ));
  }
}
