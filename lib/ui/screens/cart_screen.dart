import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/client_controller.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/ui/widgets/dashed_seperator.dart';
import 'package:nilu/ui/widgets/dialogs/triple_action_button.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_controller.dart';
import '../../utils/constants.dart';
import '../../utils/preferences.dart';
import '../widgets/bottomsheets/comment_bottom_sheet.dart';
import '../widgets/bottomsheets/discount_bottom_sheet.dart';
import '../widgets/bottomsheets/payment_bottom_sheet.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/dialogs/add_to_cart_dialog.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController _cartController = Get.find();
  final ProductController _productController = Get.find();
  final ClientController _clientController = Get.put(ClientController());
  static final ProfileController _profileController = Get.find();

  bool _isLoading = false;
  @override
  void dispose() {
    Timer.run(() {
      _cartController.clearClient();
      _cartController.clearComment();
      _cartController.clearDiscount();
    });

    super.dispose();
  }

  String chosenCurrency = _profileController.user['mainCurrency'];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _isLoading ? false : true,
      child: Scaffold(
        appBar: AppBar(
          title: Text('new_sale'.tr),
          elevation: 0,
          actions: [
            hasSecondaryCurrency()
                ? PopupMenuButton(
                    child: Row(
                      children: [
                        Text(
                          chosenCurrency,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    onSelected: (String value) {
                      setState(() {
                        chosenCurrency = value;
                      });
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: _profileController.user['mainCurrency'],
                        child: Text(
                          _profileController.user['mainCurrency'],
                          style: bodyText(
                              Theme.of(context).textTheme.bodyLarge!.color),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: _profileController.user['secondaryCurrency'],
                        child: Text(
                          _profileController.user['secondaryCurrency'],
                          style: bodyText(
                              Theme.of(context).textTheme.bodyLarge!.color),
                        ),
                      ),
                    ],
                  )
                : Container(),
          ],
          leading: _isLoading
              ? Container()
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Obx(
                () => SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      hasSecondaryCurrency()
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 7),
                              alignment: Alignment.centerLeft,
                              color: const Color(0xFFFFF2CC),
                              child: Text(
                                "1 ${_profileController.user['secondaryCurrency']}  = ${formatCurrency(Preferences.getExchangeRateResult(), _profileController.user['mainCurrency'])}",
                                style: bodyText(warningColor),
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: SizedBox(
                          height: 44,
                          child: TextField(
                            onTap: () {
                              Navigator.pushNamed(context, '/client/select')
                                  .then(
                                (value) => setState(() {}),
                              );
                            },
                            readOnly: true,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              hintText: _cartController.client?.name ??
                                  'unnamed_client'.tr,
                              hintStyle: bodyText(
                                  Theme.of(context).textTheme.bodyLarge!.color),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(
                                  color: Preferences.getTheme()
                                      ? mediumGrayColor
                                      : borderColor,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              suffixIcon:
                                  const Icon(Icons.keyboard_arrow_right),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Preferences.getTheme()
                              ? mediumGrayColor
                              : gray100Color,
                          border: Border.all(
                            color: Preferences.getTheme()
                                ? mediumGrayColor
                                : const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  _cartController.getUniqueProducts().length,
                              itemBuilder: (context, index) {
                                final product =
                                    _cartController.getUniqueProducts()[index];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: bodyText(
                                                Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              formatCurrency(
                                                  _cartController
                                                      .getPrice(product.id),
                                                  _profileController
                                                      .user['mainCurrency']),
                                              style: const TextStyle(
                                                color: Color(0xFF999999),
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            hasSecondaryCurrency()
                                                ? Text(
                                                    formatCurrency(
                                                        _cartController
                                                                .getPrice(
                                                                    product
                                                                        .id) /
                                                            Preferences
                                                                .getExchangeRateResult(),
                                                        _profileController.user[
                                                            'secondaryCurrency']),
                                                    style: const TextStyle(
                                                      color: Color(0xFF999999),
                                                      fontSize: 14,
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (context) =>
                                                AddToCartDialog(
                                              product: product,
                                              itemCounter: _cartController
                                                  .singleProductQuantity(
                                                product.id,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                            horizontal: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Preferences.getTheme()
                                                  ? mediumGrayColor
                                                  : const Color(0xFFE0E0E0),
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '${_cartController.singleProductQuantity(product.id)}x',
                                            style: h6(
                                              Preferences.getTheme()
                                                  ? primaryLightColor
                                                  : primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Preferences.getTheme()
                                      ? mediumGrayColor
                                      : const Color(0xFFE0E0E0),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              height: 36,
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "add_product".tr,
                                  style: bodyText(textMutedColor),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const DashedSeperator(width: 2),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${'total'.tr}:',
                                  style: bodyText(
                                    Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                  ),
                                ),
                                Text(
                                  chosenCurrency ==
                                          _profileController
                                              .user['mainCurrency']
                                      ? formatCurrency(
                                          _cartController.productsPrice,
                                          chosenCurrency)
                                      : formatCurrency(
                                          _cartController.productsPrice /
                                              Preferences
                                                  .getExchangeRateResult(),
                                          chosenCurrency),
                                  style: h6(
                                    Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const DashedSeperator(width: 2),
                            _cartController.discount > 0
                                ? Column(
                                    children: [
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${'discounted_price'.tr}:',
                                            style: bodyText(
                                              Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .color,
                                            ),
                                          ),
                                          Text(
                                            chosenCurrency ==
                                                    _profileController
                                                        .user['mainCurrency']
                                                ? formatCurrency(
                                                    _cartController
                                                            .productsPrice -
                                                        _cartController
                                                            .discount.value,
                                                    chosenCurrency)
                                                : formatCurrency(
                                                    (_cartController
                                                                .productsPrice -
                                                            _cartController
                                                                .discount
                                                                .value) /
                                                        Preferences
                                                            .getExchangeRateResult(),
                                                    chosenCurrency),
                                            style: h6(
                                              Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : Container(),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 36,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Preferences.getTheme()
                                        ? mediumGrayColor
                                        : const Color(0xFFE0E0E0),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                height: 36,
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(4),
                                        ),
                                      ),
                                      context: context,
                                      builder: (BuildContext context) {
                                        return DiscountBottomSheet(
                                          chosenCurrency: chosenCurrency,
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    _cartController.discount > 0
                                        ? '${'discount'.tr}: ${chosenCurrency == _profileController.user['mainCurrency'] ? formatCurrency(_cartController.discount.value, chosenCurrency) : formatCurrency(_cartController.discount.value / Preferences.getExchangeRateResult(), chosenCurrency)}'
                                        : "add_discount".tr,
                                    style: bodyText(textMutedColor),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _cartController.payment > 0
                          ? GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                  builder: (BuildContext context) {
                                    return PaymentBottomSheet(
                                      chosenCurrency: chosenCurrency,
                                    );
                                  },
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Preferences.getTheme()
                                      ? mediumGrayColor
                                      : primaryUltraLightColor,
                                  border: Border.all(
                                    color: Preferences.getTheme()
                                        ? mediumGrayColor
                                        : primaryColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${'paid'.tr}: ${chosenCurrency == _profileController.user['mainCurrency'] ? formatCurrency(_cartController.payment, chosenCurrency) : formatCurrency(_cartController.payment / Preferences.getExchangeRateResult(), chosenCurrency)}',
                                      style: bodyText(
                                        Preferences.getTheme()
                                            ? primaryLightColor
                                            : primaryColor,
                                      ),
                                    ),
                                    Text(
                                      '${'remaining'.tr}: ${chosenCurrency == _profileController.user['mainCurrency'] ? formatCurrency(_cartController.remaining, chosenCurrency) : formatCurrency(_cartController.remaining / Preferences.getExchangeRateResult(), chosenCurrency)}',
                                      style: bodyText(
                                        _cartController.remaining > 0
                                            ? warningColor
                                            : textPlaceholderColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: SizedBox(
                                height: 44,
                                child: TextField(
                                  onTap: () {
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(4),
                                        ),
                                      ),
                                      builder: (BuildContext context) {
                                        return PaymentBottomSheet(
                                          chosenCurrency: chosenCurrency,
                                        );
                                      },
                                    );
                                  },
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    contentPadding: inputPadding,
                                    hintText: _cartController.payment > 0
                                        ? "${formatCurrency(_cartController.payment, chosenCurrency)} ${'paid'.tr}"
                                        : 'add_payment'.tr,
                                    hintStyle: TextStyle(
                                      color: Preferences.getTheme()
                                          ? primaryLightColor
                                          : primaryColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: BorderSide(
                                        color: Preferences.getTheme()
                                            ? mediumGrayColor
                                            : primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          height: 44,
                          child: TextField(
                            onTap: () {
                              showModalBottomSheet(
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                                context: context,
                                builder: (BuildContext context) {
                                  return const CommentBottomSheet();
                                },
                              );
                            },
                            readOnly: true,
                            decoration: InputDecoration(
                              contentPadding: inputPadding,
                              hintText: _cartController.comment != ''
                                  ? _cartController.comment
                                  : 'add_comment'.tr,
                              hintStyle: bodyText(
                                _cartController.comment != ''
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color
                                    : textPlaceholderColor,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(
                                  color: Preferences.getTheme()
                                      ? mediumGrayColor
                                      : borderColor,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: PrimaryButton(
                                  color: greenColor,
                                  onPressed: () async {
                                    if (_cartController.products.length == 0) {
                                      errorSnackbar('no_products_in_cart'.tr);
                                      return;
                                    }
                                    List products = [];
                                    for (var item in _cartController
                                        .getUniqueProducts()) {
                                      products.add({
                                        'id': item.id,
                                        'quantity': _cartController
                                            .singleProductQuantity(item.id),
                                        'price':
                                            _cartController.getPrice(item.id),
                                        'name': item.name,
                                      });
                                    }
                                    if (_cartController.remaining > 0) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return TripleActionDialog(
                                            title: 'unpaid_amount'.tr,
                                            content:
                                                'unpaid_amount_description'.tr,
                                            middle: 'discount'.tr,
                                            begin: 'cancel'.tr,
                                            onMiddle: () {
                                              setState(() {
                                                _isLoading = true;
                                              });
                                              try {
                                                // add remaining to discount
                                                _cartController
                                                        .discount.value +=
                                                    _cartController.remaining;
                                                _cartController
                                                        .discount.value +=
                                                    _cartController.remaining;
                                                // create order
                                                addSale(products);
                                                // Decrease sold quantity
                                                decreaseSoldQuantity();
                                                // clear cart
                                                _cartController.clearCart();
                                                // navigate to home
                                                Navigator
                                                    .pushNamedAndRemoveUntil(
                                                        context,
                                                        '/home',
                                                        (route) => false);
                                                // show success snackbar
                                                successSnackbar(
                                                  'order_created'.tr,
                                                );
                                              } catch (e) {
                                                errorSnackbar(e.toString());
                                              }
                                              setState(() {
                                                _isLoading = false;
                                              });
                                            },
                                            onBegin: () {
                                              Navigator.pop(context);
                                            },
                                            end: 'debt'.tr,
                                            onEnd: () {
                                              setState(() {
                                                _isLoading = true;
                                              });
                                              try {
                                                // create order
                                                addSale(products);
                                                // Decrease sold quantity
                                                decreaseSoldQuantity();
                                                // add debt to client

                                                if (_cartController.client !=
                                                    null) {
                                                  _clientController.updateDebt(
                                                      _cartController.client!,
                                                      _cartController
                                                              .remaining +
                                                          _cartController
                                                              .client!.debt);
                                                }
                                                // clear cart
                                                _cartController.clearCart();
                                                // navigate to home
                                                Navigator
                                                    .pushNamedAndRemoveUntil(
                                                        context,
                                                        '/home',
                                                        (route) => false);
                                                // show success snackbar
                                                successSnackbar(
                                                  'order_created'.tr,
                                                );
                                              } catch (e) {
                                                errorSnackbar(e.toString());
                                              }
                                              setState(() {
                                                _isLoading = false;
                                              });
                                            },
                                          );
                                        },
                                      );
                                    } else if (_cartController.remaining < 0) {
                                      if (chosenCurrency ==
                                          _profileController
                                              .user['mainCurrency']) {
                                        errorSnackbar(
                                          "${'overpaid'.tr}: ${formatCurrency(
                                            -_cartController.remaining,
                                            chosenCurrency,
                                          )}",
                                        );
                                      } else {
                                        errorSnackbar(
                                          "${'overpaid'.tr}: ${formatCurrency(
                                            -_cartController.remaining /
                                                Preferences
                                                    .getExchangeRateResult(),
                                            chosenCurrency,
                                          )}",
                                        );
                                      }
                                    } else {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      try {
                                        // create order
                                        addSale(products);
                                        // Decrease sold quantity
                                        decreaseSoldQuantity();
                                        // clear cart
                                        _cartController.clearCart();
                                        // navigate to home
                                        Navigator.pushNamedAndRemoveUntil(
                                            context, '/home', (route) => false);
                                        // show success snackbar
                                        successSnackbar(
                                          'order_created'.tr,
                                        );
                                      } catch (e) {
                                        errorSnackbar(e.toString());
                                      }
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  },
                                  text: 'confirm'.tr,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void addSale(List<dynamic> products) {
    firestore.collection('sales').add({
      'client':
          _cartController.client == null ? "" : _cartController.client!.id,
      'products': products,
      'owner': _profileController.user['id'],
      'price': _cartController.productsPrice,
      'payment': _cartController.payment,
      'debt': _cartController.remaining,
      'discount': _cartController.discount.value,
      'comment': _cartController.comment,
      'date': DateTime.now(),
    });
  }

  void decreaseSoldQuantity() {
    for (var product in _cartController.products) {
      _productController.updateProductCount(
        product,
        product.quantity - _cartController.singleProductQuantity(product.id),
      );
    }
  }
}
