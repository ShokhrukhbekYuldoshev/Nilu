import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/client_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/sale_controller.dart';
import '../../secret.dart';
import '../../utils/constants.dart';
import '../../utils/preferences.dart';
import '../widgets/screens_card.dart';
import '../widgets/tiles/drawer_tile.dart';
import '../widgets/tiles/info_tile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProfileController _profileController = Get.put(ProfileController());
  @override
  void initState() {
    _profileController.updateUserPhone(Preferences.getPhone());
    setExchangeRate();
    startTimer();
    super.initState();
  }

  int time = 0;
  void startTimer() {
    Timer.periodic(const Duration(seconds: 25), (timer) {
      if (mounted) {
        setState(() {
          time = time + 25;
        });
      }
    });
  }

  void setExchangeRate() async {
    await Future.delayed(
      const Duration(seconds: 1),
      () async {
        if (Preferences.getExchangeRateType() == 'auto' &&
                Preferences.getExchangeRateDate() == '' ||
            DateTime.parse(Preferences.getExchangeRateDate())
                .isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
          var url = Uri.parse(
            'https://v6.exchangerate-api.com/v6/$apiKey/pair/${_profileController.user['secondaryCurrency']}/${_profileController.user['mainCurrency']}',
          );
          var response = await http.get(url);
          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);
            Preferences.setExchangeRate(jsonResponse['conversion_rate'] +
                Preferences.getExchangeRateAdjustment());
            Preferences.setExchangeRateDate(DateTime.now().toString());
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      init: ProfileController(),
      builder: (controller) {
        if (controller.user.isEmpty) {
          return Scaffold(
            body: Center(
              child: time < 25
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Something went wrong'),
                        TextButton(
                          child: Text(
                            'Login',
                            style: h5(
                              Theme.of(context).textTheme.bodyText1!.color,
                            ),
                          ),
                          onPressed: () {
                            Get.toNamed('/login');
                          },
                        ),
                      ],
                    ),
            ),
          );
        }
        final SaleController _saleController = Get.put(SaleController());
        // ignore: unused_local_variable
        final ProductController _productController =
            Get.put(ProductController());
        // ignore: unused_local_variable
        final ClientController _clientController = Get.put(ClientController());
        // ignore: unused_local_variable
        final CartController _cartController = Get.put(CartController());
        _profileController.user['categories'].sort();
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
          ),
          drawer: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Drawer(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    UserAccountsDrawerHeader(
                      margin: EdgeInsets.zero,
                      accountName: Text(
                        controller.user['business'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      accountEmail: Text(
                        FlutterLibphonenumber()
                            .formatNumberSync(controller.user['phone']),
                        style: const TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                        ),
                      ),
                      currentAccountPicture: _profileController.user['image'] !=
                              ''
                          ? Container(
                              decoration: BoxDecoration(
                                color: gray200Color,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: CachedNetworkImage(
                                  imageUrl: _profileController.user['image'],
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : const CircleAvatar(
                              backgroundColor: gray100Color,
                              child: Icon(
                                Icons.person,
                                color: iconGrayColor,
                                size: 36,
                              ),
                            ),
                    ),
                    const DrawerTile(
                      title: 'New sale',
                      icon: Icons.shopping_basket,
                      route: 'sale/add',
                    ),
                    const DrawerTile(
                      title: 'Add product',
                      icon: Icons.add,
                      route: 'product/add',
                    ),
                    const DrawerTile(
                      title: 'All sales',
                      icon: Icons.receipt,
                      route: 'sales',
                    ),
                    const DrawerTile(
                      title: 'Statistics',
                      icon: Icons.bar_chart,
                      route: 'statistics',
                    ),
                    const DrawerTile(
                      title: 'Clients',
                      icon: Icons.people,
                      route: 'clients',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Divider(),
                    ),
                    const DrawerTile(
                      title: 'Exchange rate',
                      icon: Icons.currency_exchange,
                      route: 'exchange-rate',
                    ),
                    const DrawerTile(
                      title: 'Categories',
                      icon: Icons.category,
                      route: 'categories',
                    ),
                    const DrawerTile(
                      title: 'Settings',
                      icon: Icons.settings,
                      route: 'settings',
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Obx(
            () => SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: primaryColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nilu app',
                          style: TextStyle(
                            fontSize: 24,
                            color: whiteColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 25),
                        InfoTile(
                          route: '/exchange-rate',
                          title: 'Exchange rate',
                          trailing:
                              '1 ${_profileController.user['secondaryCurrency']} = ${formatCurrency(Preferences.getExchangeRateResult(), _profileController.user['mainCurrency'])}',
                        ),
                        const SizedBox(height: 16),
                        InfoTile(
                          route: '/sales',
                          title: "Today's sales",
                          trailing: formatCurrency(
                              _saleController.getTodaySales(),
                              _profileController.user['mainCurrency']),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const ScreensCard(
                              title: 'All sales',
                              child: Icon(
                                Icons.receipt,
                                color: Color(0xFFE49639),
                              ),
                              backgroundColor: Color(0xFFFDF0D6),
                              route: '/sales',
                            ),
                            const SizedBox(width: 16),
                            ScreensCard(
                              title: 'Products',
                              child: Image.asset(
                                'assets/images/products.png',
                                width: 24,
                                height: 24,
                              ),
                              backgroundColor: const Color(0xFFFCE2E6),
                              route: '/products',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: const [
                            ScreensCard(
                              title: 'Clients',
                              child: Icon(
                                Icons.people,
                                color: Color(0xFF00C2FF),
                              ),
                              backgroundColor: Color(0xFFDFF7FF),
                              route: '/clients',
                            ),
                            SizedBox(width: 16),
                            ScreensCard(
                              title: 'New Sale',
                              child: Icon(
                                Icons.shopping_basket,
                                color: Color(0xFF64BE62),
                              ),
                              backgroundColor: Color(0xFFDAF9DA),
                              route: '/sale/add',
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
