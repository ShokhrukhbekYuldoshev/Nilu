import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:badges/badges.dart' as badge;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/product_controller.dart';
import 'package:nilu/utils/preferences.dart';
import 'package:nilu/ui/widgets/bottomsheets/product_info_bottom_sheet.dart';
import '../../../utils/constants.dart';
import '../../widgets/bottomsheets/sort_products_bottom_sheet.dart';
import '../../widgets/search_filter_icon.dart';
import '../../widgets/tiles/product_tile.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
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

      _animationController.dispose();
    });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _animationController.forward();
  }

  final ProductController _productController = Get.put(ProductController());
  final ScrollController _scrollController = ScrollController();
  bool showSearchBar = true;

  // * SCAN
  Future<void> scanner(context) async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'cancel'.tr, true, ScanMode.BARCODE);
      if (barcodeScanRes != "-1") {
        var product = _productController.getProductByCode(barcodeScanRes);
        if (product.id != '') {
          showModalBottomSheet(
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            context: context,
            builder: (_) => ProductInfoBottomSheet(
              product: product,
            ),
          );
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('products'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/product/add');
            },
          ),
        ],
      ),
      body: Obx(
        (() => Column(
              children: [
                showSearchBar
                    ? SizeTransition(
                        sizeFactor: _animation,
                        child: SearchWidget(scanner: scanner),
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
                            if (_scrollController
                                    .position.userScrollDirection ==
                                ScrollDirection.reverse) {
                              if (showSearchBar) {
                                showSearchBar = false;
                                _animationController.reverse();
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
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.only(top: 20),
                                  itemCount: _productController
                                      .filteredProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = _productController
                                        .filteredProducts[index];
                                    return ProductTile(product: product);
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
                                              _productController
                                                  .filterProducts();
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
            )),
      ),
    );
  }
}

class SearchWidget extends StatefulWidget {
  final Function scanner;
  const SearchWidget({Key? key, required this.scanner}) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final ProductController _productController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
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
                      controller: _searchController,
                      onChanged: (value) {
                        _productController.search(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'search'.tr,
                        contentPadding: const EdgeInsets.all(0),
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
                    widget.scanner(context);
                  },
                ),
                const SizedBox(width: 8),
                badge.Badge(
                  showBadge: _productController.filterCategories.isNotEmpty,
                  badgeStyle: const badge.BadgeStyle(
                    badgeColor: Color(0xFFFBBC05),
                  ),
                  badgeContent: Text(
                    _productController.filterCategories.length.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: SearchFilterIcon(
                    icon: Icons.sort,
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
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
        Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'product_name'.tr,
                style: bodyText(Theme.of(context).textTheme.bodyMedium!.color),
              ),
              Text(
                'in_stock'.tr,
                style: bodyText(warningColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
