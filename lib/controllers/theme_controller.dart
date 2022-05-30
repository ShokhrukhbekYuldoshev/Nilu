import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nilu/utils/preferences.dart';

class ThemeController extends GetxController {
  ThemeMode get theme =>
      Preferences.getTheme() ? ThemeMode.dark : ThemeMode.light;

  void changeTheme(ThemeMode themeMode, ThemeData theme) async {
    Preferences.setTheme(theme.brightness == Brightness.dark);
    Get.changeThemeMode(themeMode);
    Get.changeTheme(theme);
  }
}
