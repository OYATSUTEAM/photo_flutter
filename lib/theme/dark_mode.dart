import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
    scaffoldBackgroundColor: const Color.fromARGB(255, 51, 50, 50),
    colorScheme: ColorScheme.dark(
      surface: const Color.fromARGB(255, 51, 50, 50),
      primary: const Color.fromARGB(255, 197, 192, 192),
      secondary: Colors.grey.shade700,
      tertiary: Colors.grey.shade800,
      inversePrimary: Colors.grey.shade300,
    ),
    fontFamily: 'NotoSansJP',
    drawerTheme: DrawerThemeData(
        backgroundColor: Colors.grey.shade800,
        surfaceTintColor: Colors.white,
        scrimColor: const Color.fromARGB(255, 51, 50, 50)),
    appBarTheme:
        AppBarTheme(backgroundColor: const Color.fromARGB(255, 51, 50, 50)));
