import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/auth_controller.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/controllers/theme_controller.dart';
import 'package:nilu/models/themes_model.dart';
import 'package:nilu/utils/languages.dart';
import 'utils/preferences.dart';
import 'views/screens/auth/login_screen.dart';
import 'views/screens/categories_screen.dart';
import 'views/screens/auth/register_screen.dart';
import 'views/screens/client/add_client_screen.dart';
import 'views/screens/product/add_product_screen.dart';
import 'views/screens/sale/sales_screen.dart';
import 'views/screens/cart_screen.dart';
import 'views/screens/client/clients_screen.dart';
import 'views/screens/exchange_rate_screen.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/client/select_client_screen.dart';
import 'views/screens/statistics_screen.dart';
import 'views/screens/sale/add_sale_screen.dart';
import 'views/screens/product/products_screen.dart';
import 'views/screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLibphonenumber().init();
  await Preferences.init().then((value) => Get.put(ProfileController()));
  await Firebase.initializeApp().then((value) => Get.put(AuthController()));
  getLocale();
  runApp(const MyApp());
}

Locale locale = const Locale('en', 'US');

getLocale() {
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
    final ThemeController _themeController = Get.put(ThemeController());

    return GetMaterialApp(
      translations: Languages(),
      locale: locale,
      fallbackLocale: const Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
      title: 'Nilu',
      themeMode: _themeController.theme,
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/register':
            return CupertinoPageRoute(builder: (_) => const RegisterScreen());
          case '/home':
            return MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            );
          case '/sale/add':
            return CupertinoPageRoute(builder: (_) => const AddSaleScreen());
          case '/sales':
            return CupertinoPageRoute(builder: (_) => const SalesScreen());
          case '/cart':
            return CupertinoPageRoute(builder: (_) => const CartScreen());
          case '/products':
            return CupertinoPageRoute(builder: (_) => const ProductsScreen());
          case '/product/add':
            return CupertinoPageRoute(builder: (_) => const AddProductScreen());
          case '/statistics':
            return CupertinoPageRoute(builder: (_) => const StatisticsScreen());
          case '/clients':
            return CupertinoPageRoute(builder: (_) => const ClientsScreen());
          case '/client/select':
            return CupertinoPageRoute(
                builder: (_) => const SelectClientScreen());
          case '/client/add':
            return CupertinoPageRoute(
              builder: (_) => const AddClientScreen(),
            );
          case '/exchange-rate':
            return CupertinoPageRoute(
                builder: (_) => const ExchangeRateScreen());
          case '/categories':
            return CupertinoPageRoute(builder: (_) => const CategoriesScreen());
          case '/settings':
            return CupertinoPageRoute(builder: (_) => const SettingsScreen());

          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
        }
      },
    );
  }
}
