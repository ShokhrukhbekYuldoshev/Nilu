import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:nilu/controllers/cart_controller.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/utils/preferences.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/secondary_button.dart';
import '../../../models/product_model.dart';
import '../../../utils/constants.dart';

// ignore: must_be_immutable
class AddToCartDialog extends StatefulWidget {
  AddToCartDialog({
    Key? key,
    required this.product,
    required this.itemCounter,
    this.addition = 0,
    this.soldQuantity = 0,
  }) : super(key: key);
  final Product product;
  final int addition;
  final int soldQuantity;

  int itemCounter;

  @override
  State<AddToCartDialog> createState() => _AddToCartDialogState();
}

class _AddToCartDialogState extends State<AddToCartDialog> {
  final CartController _cartController = Get.find();
  final ProfileController _profileController = Get.find();

  late final TextEditingController _priceController = TextEditingController(
    text: formatCurrencyWithoutSymbol(widget.product.price),
  );

  late double secondaryCurrencyValue =
      widget.product.price / Preferences.getExchangeRateResult();

  @override
  Widget build(BuildContext context) {
    final TextEditingController quantityController = TextEditingController(
      text: widget.itemCounter.toString(),
    );
    quantityController.selection = TextSelection.fromPosition(
        TextPosition(offset: quantityController.text.length));

    return AlertDialog(
      title: Column(
        children: [
          Text('select_quantity'.tr,
              style: h6(
                Theme.of(context).textTheme.bodyLarge!.color,
              )),
          Text(widget.product.name,
              style: bodyText(Theme.of(context).textTheme.bodyMedium!.color))
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Preferences.getTheme()
                      ? lightGrayColor
                      : primaryUltraLightColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      if (widget.itemCounter > 0) {
                        widget.itemCounter--;
                        quantityController.text = widget.itemCounter.toString();
                        quantityController.selection =
                            TextSelection.fromPosition(TextPosition(
                                offset: quantityController.text.length));
                      }
                    });
                  },
                  icon: Icon(
                    Icons.remove,
                    color: Preferences.getTheme() ? whiteColor : primaryColor,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    if (int.tryParse(value) != null) {
                      setState(() {
                        widget.itemCounter = int.parse(value);
                        quantityController.selection =
                            TextSelection.fromPosition(TextPosition(
                                offset: quantityController.text.length));
                      });
                    }
                  },
                  style: TextStyle(
                    fontSize: 36,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                  textAlign: TextAlign.center,
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Preferences.getTheme()
                      ? lightGrayColor
                      : primaryUltraLightColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      widget.itemCounter++;
                      quantityController.text = widget.itemCounter.toString();
                      quantityController.selection = TextSelection.fromPosition(
                          TextPosition(offset: quantityController.text.length));
                    });
                  },
                  icon: Icon(
                    Icons.add,
                    color: Preferences.getTheme() ? whiteColor : primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),
          SizedBox(
            height: 44,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  height: 44,
                  decoration: BoxDecoration(
                    color:
                        Preferences.getTheme() ? lightGrayColor : gray200Color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '1x = ',
                      style: bodyText(
                          Theme.of(context).textTheme.bodyMedium!.color),
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    inputFormatters: [ThousandsFormatter(allowFraction: true)],
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        try {
                          secondaryCurrencyValue =
                              double.parse(value.replaceAll(',', '')) /
                                  Preferences.getExchangeRateResult();
                        } catch (e) {
                          secondaryCurrencyValue = 0;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 0),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      )),
                      suffixText: _profileController.user['mainCurrency'],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          hasSecondaryCurrency()
              ? Text(
                  '= ${formatCurrency(secondaryCurrencyValue, _profileController.user['secondaryCurrency'])}',
                  style:
                      bodyText(Theme.of(context).textTheme.bodyMedium!.color),
                )
              : Container(),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'cancel'.tr,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PrimaryButton(
                onPressed: () {
                  if (widget.itemCounter <=
                      (widget.product.quantity as int) + widget.addition) {
                    _cartController.updateCart(
                      widget.product,
                      widget.itemCounter,
                      double.parse(
                        _priceController.text.replaceAll(',', ''),
                      ),
                    );

                    Navigator.of(context).pop();
                  } else {
                    errorSnackbar('not_enough'.tr);
                  }
                },
                text: 'confirm'.tr,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
