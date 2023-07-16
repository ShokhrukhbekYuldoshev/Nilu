import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:nilu/controllers/cart_controller.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/utils/preferences.dart';

import '../../../utils/constants.dart';
import '../buttons/delete_save_button.dart';

class PaymentBottomSheet extends StatefulWidget {
  final String chosenCurrency;
  const PaymentBottomSheet({Key? key, required this.chosenCurrency})
      : super(key: key);

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  int paymentsCounter = 0;
  final CartController _cartController = Get.find();
  final ProfileController _profileController = Get.find();
  final List<Map<String, dynamic>> _payments = [];

  @override
  void initState() {
    super.initState();
    if (_cartController.payments.length > 0) {
      paymentsCounter = _cartController.payments.length;
      for (final payment in _cartController.payments) {
        _payments.add(
          {
            'amount': payment.amount,
            'currency': payment.currency,
            'controller': TextEditingController(
                text: formatCurrencyWithoutSymbol(payment.amount)),
          },
        );
      }
    } else {
      paymentsCounter = 1;
      _payments.add({
        'amount': 0,
        'currency': widget.chosenCurrency,
        'controller': TextEditingController(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Wrap(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'payment'.tr,
                      style: h5(
                        Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      alignment: Alignment.centerRight,
                      icon: const Icon(
                        Icons.close,
                        color: iconGrayColor,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  color:
                      Preferences.getTheme() ? mediumGrayColor : gray100Color,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${'remaining'.tr}: ',
                        style: bodyText(
                          _cartController.remaining > 0
                              ? warningColor
                              : textPlaceholderColor,
                        ),
                      ),
                      Text(
                        widget.chosenCurrency ==
                                _profileController.user['mainCurrency']
                            ? formatCurrency(_cartController.remaining,
                                widget.chosenCurrency)
                            : formatCurrency(
                                _cartController.remaining /
                                    Preferences.getExchangeRateResult(),
                                widget.chosenCurrency),
                        style: bodyText(
                          _cartController.remaining > 0
                              ? warningColor
                              : textPlaceholderColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                for (int i = 0; i < paymentsCounter; i++)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.55,
                          child: TextField(
                            inputFormatters: [
                              ThousandsFormatter(
                                allowFraction: true,
                                formatter: NumberFormat(
                                  '###,###.###',
                                ),
                              )
                            ],
                            style: h5(
                                Theme.of(context).textTheme.bodyLarge!.color),
                            onChanged: (value) {
                              try {
                                setState(() {
                                  _payments[i]['amount'] =
                                      double.parse(value.replaceAll(',', ''));
                                });
                                // ignore: empty_catches
                              } catch (e) {}
                            },
                            controller: _payments[i]['controller'],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: inputPadding,
                              hintText: '0.00',
                              suffix: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _payments[i]['controller'] =
                                        TextEditingController();
                                    _payments[i]['amount'] = 0;
                                  });
                                },
                                child: const Icon(
                                  Icons.backspace,
                                  color: gray500Color,
                                  size: 20,
                                ),
                              ),
                              hintStyle: bodyText(textPlaceholderColor),
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
                        Expanded(child: Container()),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: TextField(
                            onTap: () {
                              showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => SimpleDialog(
                                  title: Text('currency'.tr),
                                  children: [
                                    Column(
                                      children: [
                                        RadioListTile(
                                            activeColor: Preferences.getTheme()
                                                ? primaryLightColor
                                                : primaryColor,
                                            value: _profileController
                                                .user['mainCurrency']
                                                .toString(),
                                            groupValue: _payments[i]
                                                ['currency'],
                                            onChanged: (value) {
                                              setState(() {
                                                _payments[i]['currency'] =
                                                    value;
                                              });
                                              Navigator.pop(context);
                                            },
                                            title: Text(_profileController
                                                .user['mainCurrency'])),
                                        hasSecondaryCurrency()
                                            ? RadioListTile(
                                                activeColor:
                                                    Preferences.getTheme()
                                                        ? primaryLightColor
                                                        : primaryColor,
                                                value: _profileController
                                                    .user['secondaryCurrency']
                                                    .toString(),
                                                groupValue: _payments[i]
                                                    ['currency'],
                                                onChanged: (value) {
                                                  setState(() {
                                                    _payments[i]['currency'] =
                                                        value;
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                title: Text(_profileController
                                                    .user['secondaryCurrency']),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                            readOnly: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 10),
                              hintText: _payments[i]['currency'],
                              hintStyle: bodyText(
                                Theme.of(context).textTheme.bodyLarge!.color,
                              ),
                              suffixIcon: const Icon(
                                Icons.arrow_drop_down,
                                color: iconGrayColor,
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
                        )
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (paymentsCounter < 4) {
                              _payments.add({
                                'controller': TextEditingController(),
                                'currency': _payments[paymentsCounter - 1]
                                    ['currency'],
                                'amount': 0,
                              });
                              paymentsCounter++;
                            } else {
                              return;
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Preferences.getTheme()
                              ? lightGrayColor
                              : paymentsCounter == 4
                                  ? gray200Color
                                  : gray100Color,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          'add_another'.tr,
                          style: h6(
                            Preferences.getTheme()
                                ? whiteColor
                                : paymentsCounter == 4
                                    ? whiteColor
                                    : primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DeleteSaveButton(
                  onDelete: () {
                    _cartController.clearPayments();
                    Navigator.pop(context);
                  },
                  onSave: () {
                    _cartController.clearPayments();
                    for (var payment in _payments) {
                      if (payment['amount'] <= 0 ||
                          payment['controller'].text.isEmpty) {
                        continue;
                      } else if (payment['currency'] ==
                              _profileController.user['mainCurrency'] &&
                          payment['amount'] > _cartController.remaining) {
                        payment['amount'] = _cartController.remaining;
                      } else if (payment['currency'] ==
                              _profileController.user['secondaryCurrency'] &&
                          payment['amount'] >
                              _cartController.remaining /
                                  Preferences.getExchangeRateResult()) {
                        payment['amount'] = _cartController.remaining /
                            Preferences.getExchangeRateResult();
                      }
                      _cartController.addPayment(
                        payment['amount'],
                        payment['currency'],
                      );
                    }

                    Navigator.pop(context);
                  },
                  text: "save".tr,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
