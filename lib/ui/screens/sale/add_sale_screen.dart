import 'dart:async';
import 'package:badges/badges.dart' as badge;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/cart_controller.dart';
import 'package:nilu/controllers/product_controller.dart';
import '../../../models/product_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/preferences.dart';
import '../../widgets/bottomsheets/sort_products_bottom_sheet.dart';
import '../../widgets/search_filter_icon.dart';
import '../../widgets/tiles/sale_tile.dart';

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({Key? key}) : super(key: key);

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen>
    with TickerProviderStateMixin {
  // * Animation
  late final AnimationController _animationController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void dispose() {
    Timer.run(() {
      _productController.filterCategories.value = [];
      _productController.searchProducts.value = _productController.products;
      _productController.searchText.value = '';
      _productController.filteredProducts.value = _productController.products;
      _cartController.clearCart();
      _cartController.productsPriceMap.value = [];
      _animationController.dispose();
      _cartController.clearPayments();
    });

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController.forward();
  }

  final ProductController _productController = Get.find();
  final CartController _cartController = Get.find();
  final ScrollController _scrollController = ScrollController();
  bool showSearchBar = true;

  // * SCAN
  Future<void> scanner() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'cancel'.tr, true, ScanMode.BARCODE);

      if (barcodeScanRes != "-1") {
        Product product = _productController.getProductByCode(barcodeScanRes);
        if (product.id != "") {
          if (product.quantity! >
              _cartController.singleProductQuantity(product.id)) {
            _cartController.updateCart(
              product,
              _cartController.singleProductQuantity(product.id) + 1,
              _cartController.getPrice(product.id) == 0
                  ? product.price
                  : _cartController.getPrice(product.id),
            );
          } else {
            errorSnackbar('not_enough'.tr);
          }
        } else {
          errorSnackbar(
            "${'not_found'.tr}. ${'code'.tr}: $barcodeScanRes",
          );
        }
      }
    } on PlatformException {
      barcodeScanRes = 'something_went_wrong'.tr;
    }
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController(
      text: '',
    );
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          backgroundColor:
              Preferences.getTheme() ? darkGrayColor : primaryUltraLightColor,
          foregroundColor:
              Preferences.getTheme() ? primaryUltraLightColor : textDarkColor,
          elevation: 0,
          title: Text(
            'select_items'.tr,
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 62,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                    Text(
                      _cartController.products.length.toString(),
                      style: TextStyle(
                        fontSize: 28,
                        color: Preferences.getTheme()
                            ? primaryLightColor
                            : primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      ' ${'selected'.tr}',
                      style: bodyText(const Color(0xFFA9A9A9)),
                    ),
                  ],
                ),
                SizedBox(
                  height: 44,
                  width: 124,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    onPressed: _cartController.products.length <= 0
                        ? null
                        : () {
                            Navigator.pushNamed(context, '/cart');
                          },
                    child: Text(
                      'done'.tr,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            showSearchBar
                ? SizeTransition(
                    sizeFactor: _animation,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 44,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Preferences.getTheme()
                                        ? mediumGrayColor
                                        : const Color(0xFFE0E0E0),
                                  ),
                                ),
                                child: TextField(
                                  controller: searchController,
                                  onChanged: (value) {
                                    _productController.search(value);
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(0),
                                    hintText: 'search'.tr,
                                    hintStyle: bodyText(iconGrayColor),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: iconGrayColor,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SearchFilterIcon(
                              icon: Icons.qr_code_scanner,
                              onPressed: () {
                                scanner();
                              },
                            ),
                            const SizedBox(width: 8),
                            badge.Badge(
                              showBadge: _productController
                                  .filterCategories.isNotEmpty,
                              badgeStyle: const badge.BadgeStyle(
                                badgeColor: Color(0xFFFBBC05),
                              ),
                              badgeContent: Text(
                                _productController.filterCategories.length
                                    .toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              child: SearchFilterIcon(
                                icon: Icons.sort,
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        topRight: Radius.circular(4),
                                      ),
                                    ),
                                    builder: (_) {
                                      return const SortProductsBottomSheet();
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            Expanded(
              child: _productController.filteredProducts.isEmpty
                  ? Center(
                      child: Text(
                        'not_found'.tr,
                        style: bodyText(
                            Theme.of(context).textTheme.bodyMedium!.color),
                      ),
                    )
                  : NotificationListener(
                      onNotification: (scrollNotification) {
                        if (_scrollController.position.userScrollDirection ==
                            ScrollDirection.reverse) {
                          if (showSearchBar) {
                            _animationController.reverse();
                            showSearchBar = false;
                          }
                        } else if (_scrollController
                                .position.userScrollDirection ==
                            ScrollDirection.forward) {
                          if (!showSearchBar) {
                            _animationController.forward();
                            setState(() {
                              showSearchBar = true;
                            });
                          }
                        }
                        return true;
                      },
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            ListView.builder(
                              padding: const EdgeInsets.only(top: 8),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount:
                                  _productController.filteredProducts.length,
                              itemBuilder: (context, index) {
                                return SaleTile(
                                  product: _productController
                                      .filteredProducts[index],
                                );
                              },
                            ),
                            _productController.filterCategories.isNotEmpty
                                ? Column(
                                    children: [
                                      const Divider(
                                        height: 0,
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        'you_applied_filter'.tr,
                                        style: bodyText(textMutedColor),
                                      ),
                                      const SizedBox(height: 6),
                                      TextButton(
                                        child: Text(
                                          'show_all'.tr,
                                          style: bodyText(
                                            Preferences.getTheme()
                                                ? primaryLightColor
                                                : primaryColor,
                                          ),
                                        ),
                                        onPressed: () {
                                          _productController
                                              .filterCategories.value = [];
                                          _productController.filterProducts();
                                        },
                                      ),
                                      const SizedBox(height: 40),
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
