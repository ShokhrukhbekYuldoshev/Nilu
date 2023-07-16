import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/auth_controller.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/controllers/theme_controller.dart';
import 'package:nilu/models/themes_model.dart';
import 'package:nilu/utils/app_router.dart';
import 'package:nilu/utils/languages.dart';

import 'firebase_options.dart';
import 'utils/preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  await Preferences.init().then((value) => Get.put(ProfileController()));
  await Firebase.initializeApp(
    name: 'nilu',
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) => Get.put(AuthController()));
  getLocale();
  runApp(const MyApp());
}

Locale locale = const Locale('en', 'US');

void getLocale() {
  if (Preferences.getLanguage() == 'english') {
    locale = const Locale('en', 'US');
  } else if (Preferences.getLanguage() == 'russian') {
    locale = const Locale('ru', 'RU');
  } else if (Preferences.getLanguage() == 'uzbek') {
    locale = const Locale('uz', 'UZ');
  } else if (Preferences.getLanguage() == 'spanish') {
    locale = const Locale('es', 'ES');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());

    return GetMaterialApp(
      translations: Languages(),
      locale: locale,
      fallbackLocale: const Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
      title: 'Nilu',
      themeMode: themeController.theme,
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
