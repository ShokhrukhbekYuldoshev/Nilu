import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:nilu/controllers/cart_controller.dart';
import 'package:nilu/utils/constants.dart';
import 'package:nilu/utils/preferences.dart';

import '../../../controllers/profile_controller.dart';
import '../buttons/delete_save_button.dart';

class DiscountBottomSheet extends StatefulWidget {
  final String chosenCurrency;
  const DiscountBottomSheet({Key? key, required this.chosenCurrency})
      : super(key: key);

  @override
  State<DiscountBottomSheet> createState() => _DiscountBottomSheetState();
}

class _DiscountBottomSheetState extends State<DiscountBottomSheet> {
  final ProfileController _profileController = Get.find();
  final CartController _cartController = Get.find();
  final TextEditingController _discountController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'discount'.tr,
                  style: h5(
                    Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  keyboardType: TextInputType.phone,
                  controller: _discountController,
                  textInputAction: TextInputAction.done,
                  autofocus: true,
                  decoration: InputDecoration(
                    contentPadding: inputPadding,
                    hintText: 'enter_discount'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  inputFormatters: [
                    ThousandsFormatter(
                      allowFraction: true,
                      formatter: NumberFormat(
                        '###,###.###',
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                DeleteSaveButton(
                  onDelete: () {
                    _cartController.clearDiscount();
                    Navigator.pop(context);
                  },
                  onSave: () {
                    if (_discountController.text.isNotEmpty) {
                      double discount = double.tryParse(
                              _discountController.text.replaceAll(',', '')) ??
                          0;
                      if (discount > 0 &&
                          widget.chosenCurrency ==
                              _profileController.user['secondaryCurrency']) {
                        discount =
                            discount * Preferences.getExchangeRateResult();
                      }
                      if (discount >= 0 &&
                          discount <= _cartController.productsPrice) {
                        _cartController.payments.clear();
                        _cartController.addPayment(
                          _cartController.productsPrice - discount,
                          _profileController.user['mainCurrency'],
                        );
                      } else if (widget.chosenCurrency ==
                              _profileController.user['mainCurrency'] &&
                          double.parse(_discountController.text
                                  .replaceAll(',', '')) >
                              _cartController.productsPrice) {
                        _cartController.clearPayments();
                        discount = _cartController.productsPrice;
                      } else if (widget.chosenCurrency ==
                              _profileController.user['secondaryCurrency'] &&
                          double.parse(_discountController.text
                                  .replaceAll(',', '')) >
                              _cartController.productsPrice /
                                  Preferences.getExchangeRateResult()) {
                        _cartController.payments.clear();
                        discount = _cartController.productsPrice;
                      }
                      if (discount > 0 &&
                          discount <= _cartController.productsPrice) {
                        _cartController.setDiscount(discount);
                      }
                    }
                    Navigator.pop(context);
                  },
                  text: 'save'.tr,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
