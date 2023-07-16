import 'package:flutter/cupertino.dart';

import 'package:nilu/ui/screens/auth/login_screen.dart';
import 'package:nilu/ui/screens/categories_screen.dart';
import 'package:nilu/ui/screens/auth/register_screen.dart';
import 'package:nilu/ui/screens/client/add_client_screen.dart';
import 'package:nilu/ui/screens/product/add_product_screen.dart';
import 'package:nilu/ui/screens/sale/sales_screen.dart';
import 'package:nilu/ui/screens/cart_screen.dart';
import 'package:nilu/ui/screens/client/clients_screen.dart';
import 'package:nilu/ui/screens/exchange_rate_screen.dart';
import 'package:nilu/ui/screens/home_screen.dart';
import 'package:nilu/ui/screens/client/select_client_screen.dart';
import 'package:nilu/ui/screens/statistics_screen.dart';
import 'package:nilu/ui/screens/sale/add_sale_screen.dart';
import 'package:nilu/ui/screens/product/products_screen.dart';
import 'package:nilu/ui/screens/settings_screen.dart';
import 'package:nilu/ui/screens/loading_screen.dart';
import 'package:nilu/ui/screens/support_screen.dart';

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return CupertinoPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return CupertinoPageRoute(builder: (_) => RegisterScreen());
      case '/home':
        return CupertinoPageRoute(
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
        return CupertinoPageRoute(builder: (_) => const SelectClientScreen());
      case '/client/add':
        return CupertinoPageRoute(
          builder: (_) => const AddClientScreen(),
        );
      case '/exchange-rate':
        return CupertinoPageRoute(builder: (_) => const ExchangeRateScreen());
      case '/categories':
        return CupertinoPageRoute(builder: (_) => const CategoriesScreen());
      case '/settings':
        return CupertinoPageRoute(builder: (_) => const SettingsScreen());
      case '/support':
        return CupertinoPageRoute(builder: (_) => const SupportScreen());
      default:
        return CupertinoPageRoute(
          builder: (_) => const LoadingScreen(),
        );
    }
  }
}
