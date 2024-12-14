import 'package:flutter/material.dart';

class MyTrancyTextField extends StatelessWidget {
  const MyTrancyTextField(
      {super.key,
      required this.hint,
      required this.obsecure,
      required this.controller,
      required this.labelText,
      this.focusNode});
  final String hint;
  final String labelText;
  final bool obsecure;
  final TextEditingController controller;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        focusNode: focusNode,
        controller: controller,
        obscureText: obsecure,
        decoration: InputDecoration(
          labelText: labelText,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color.fromARGB(0, 131, 115, 57),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color.fromARGB(0, 131, 115, 57),
            ),
          ),
          filled: true,
          fillColor: const Color.fromARGB(0, 131, 115, 57),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
