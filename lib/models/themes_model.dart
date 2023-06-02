import 'package:flutter/material.dart';

import '../utils/constants.dart';

class Themes {
  static final lightTheme = ThemeData(
    primaryColor: primaryColor,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      color: primaryColor,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: textDarkColor,
      ),
      bodyMedium: TextStyle(
        color: textMutedColor,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
    ),
  );

  static final darkTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: primaryLightColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.white,
      color: primaryColor,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryLightColor,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: whiteColor,
      ),
      bodyMedium: TextStyle(
        color: gray400Color,
      ),
    ),
  );
}
