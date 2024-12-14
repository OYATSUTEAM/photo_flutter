import 'package:flutter/material.dart';

class ThemeState {}

class ThemeInitState extends ThemeState {
  ThemeData initTheme;

  ThemeInitState(this.initTheme);
}

class ThemeResponseState extends ThemeState {
  ThemeData secondaryTheme;

  ThemeResponseState(this.secondaryTheme);
}
