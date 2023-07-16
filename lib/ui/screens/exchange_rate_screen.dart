import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/ui/widgets/buttons/delete_save_button.dart';

import '../../utils/constants.dart';
import '../../utils/preferences.dart';
import '../widgets/buttons/primary_button.dart';

class ExchangeRateScreen extends StatefulWidget {
  const ExchangeRateScreen({Key? key}) : super(key: key);

  @override
  State<ExchangeRateScreen> createState() => _ExchangeRateScreenState();
}

class _ExchangeRateScreenState extends State<ExchangeRateScreen> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController exchangeRateController = TextEditingController(
      text: formatCurrencyWithoutSymbol(Preferences.getExchangeRate()),
    );
    final ProfileController profileController = Get.find();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'exchange_rate'.tr,
        ),
      ),
      body: hasSecondaryCurrency()
          ? SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color:
                          Preferences.getTheme() ? darkGrayColor : whiteColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Preferences.getExchangeRateType() == 'auto'
                            ? primaryColor
                            : Colors.transparent,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioListTile(
                            enableFeedback: mounted,
                            activeColor: Preferences.getTheme()
                                ? primaryLightColor
                                : primaryColor,
                            contentPadding: const EdgeInsets.all(0),
                            title: Text('auto_update'.tr,
                                style: bodyText(Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color)),
                            value: 'auto',
                            groupValue: Preferences.getExchangeRateType(),
                            onChanged: (value) {
                              setState(() {
                                Preferences.setExchangeRateType('auto');
                              });
                            }),
                        Preferences.getExchangeRateType() == 'auto'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: Preferences.getExchangeRateDate() !=
                                        ""
                                    ? [
                                        const Divider(),
                                        const SizedBox(height: 20),
                                        Text(
                                          '${'bank_rate'.tr}: 1 ${profileController.user['secondaryCurrency']} = ${formatCurrency(Preferences.getExchangeRate(), profileController.user['mainCurrency'])}',
                                          style: h5(
                                            Preferences.getExchangeRateAdjustment() !=
                                                    0
                                                ? Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color
                                                : Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color,
                                          ),
                                        ),
                                        Preferences.getExchangeRateAdjustment() !=
                                                0
                                            ? Text(
                                                '${'new_rate'.tr}: 1 ${profileController.user['secondaryCurrency']} = ${formatCurrency(Preferences.getExchangeRateResult(), profileController.user['mainCurrency'])}',
                                                style: h5(
                                                  Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .color,
                                                ),
                                              )
                                            : Container(),
                                        const SizedBox(height: 24),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              backgroundColor:
                                                  Preferences.getTheme()
                                                      ? lightGrayColor
                                                      : primaryUltraLightColor,
                                              textStyle: bodyText(whiteColor)),
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(4),
                                                  topRight: Radius.circular(4),
                                                ),
                                              ),
                                              builder: (_) =>
                                                  AutoAdjustBottomSheet(
                                                profileController:
                                                    profileController,
                                                exchangeRateController:
                                                    exchangeRateController,
                                              ),
                                            ).then((_) {
                                              setState(() => {});
                                            });
                                          },
                                          child: Text(
                                            '+/- ${'auto_adjust'.tr}',
                                            style: bodyText(
                                              Preferences.getTheme()
                                                  ? whiteColor
                                                  : primaryColor,
                                            ),
                                          ),
                                        ),
                                      ]
                                    : [],
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color:
                          Preferences.getTheme() ? darkGrayColor : whiteColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Preferences.getExchangeRateType() == 'manual'
                            ? primaryColor
                            : Colors.transparent,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.all(0),
                          activeColor: Preferences.getTheme()
                              ? primaryLightColor
                              : primaryColor,
                          title: Text(
                            'manual_input'.tr,
                            style: bodyText(
                              Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                          ),
                          value: 'manual',
                          groupValue: Preferences.getExchangeRateType(),
                          onChanged: (value) {
                            setState(() {
                              Preferences.setExchangeRateType('manual');
                            });
                          },
                        ),
                        Preferences.getExchangeRateType() == 'manual'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    height: 44,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Preferences.getTheme()
                                                ? mediumGrayColor
                                                : const Color(0xFFF5F5F5),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                              '1 ${profileController.user['secondaryCurrency']} = ',
                                              style: bodyText(Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .color)),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: TextField(
                                            controller: exchangeRateController,
                                            autofocus: true,
                                            keyboardType: TextInputType.number,
                                            style: bodyText(Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color),
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                              ),
                                              border:
                                                  const OutlineInputBorder(),
                                              hintText: 'enter_amount'.tr,
                                              hintStyle: bodyText(
                                                  Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .color),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        PrimaryButton(
                                          text: "save".tr,
                                          onPressed: () {
                                            try {
                                              Preferences.setExchangeRate(
                                                double.parse(
                                                  exchangeRateController.text
                                                      .replaceAll(',', ''),
                                                ),
                                              );
                                              Preferences
                                                  .setExchangeRateAdjustment(0);
                                              FocusScope.of(context).unfocus();
                                              successSnackbar(
                                                  'exchange_rate_saved'.tr);
                                            } catch (_) {}
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: Text('no_secondary_currency'.tr),
            ),
    );
  }
}

class AutoAdjustBottomSheet extends StatefulWidget {
  const AutoAdjustBottomSheet({
    Key? key,
    required ProfileController profileController,
    required TextEditingController exchangeRateController,
  })  : _profileController = profileController,
        super(key: key);

  final ProfileController _profileController;

  @override
  State<AutoAdjustBottomSheet> createState() => _AutoAdjustBottomSheetState();
}

bool isDouble(String? text) {
  try {
    double.parse(text!);
    return true;
  } catch (_) {
    return false;
  }
}

class _AutoAdjustBottomSheetState extends State<AutoAdjustBottomSheet> {
  final TextEditingController _adjustmentController = TextEditingController(
    text: Preferences.getExchangeRateAdjustment().toString(),
  );

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
                  'auto_adjust'.tr,
                  style: h5(
                    Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  '${'bank_rate'.tr}: 1 ${widget._profileController.user['secondaryCurrency']} = ${formatCurrency(Preferences.getExchangeRate(), widget._profileController.user['mainCurrency'])}',
                  style: bodyText(
                    Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Preferences.getTheme()
                              ? mediumGrayColor
                              : const Color(0xFFF5F5F5),
                          border: Border.all(
                            color: Preferences.getTheme()
                                ? primaryLightColor
                                : primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '+/- ${'adjust_by'.tr}',
                          style: bodyText(
                            Preferences.getTheme()
                                ? primaryLightColor
                                : primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          onChanged: (value) => setState(() {}),
                          autofocus: true,
                          controller: _adjustmentController,
                          keyboardType: TextInputType.number,
                          style: bodyText(
                            Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                          decoration: InputDecoration(
                            contentPadding: inputPadding,
                            hintText: 'enter_amount'.tr,
                            hintStyle: bodyText(
                              Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: Preferences.getTheme()
                                    ? primaryLightColor
                                    : primaryColor,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: Preferences.getTheme()
                                    ? primaryLightColor
                                    : primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${'new_rate'.tr}: 1 ${widget._profileController.user['secondaryCurrency']} = ${formatCurrency(Preferences.getExchangeRate() + (isDouble(_adjustmentController.text) ? double.parse(_adjustmentController.text) : 0), widget._profileController.user['mainCurrency'])}',
                  style: bodyText(
                    Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                ),
                const SizedBox(height: 50),
                DeleteSaveButton(
                    onDelete: () {
                      try {
                        Preferences.setExchangeRateAdjustment(0);
                        Navigator.pop(context);
                      } catch (_) {}
                    },
                    onSave: () {
                      try {
                        Preferences.setExchangeRateAdjustment(
                          isDouble(_adjustmentController.text)
                              ? double.parse(_adjustmentController.text)
                              : 0,
                        );
                        Navigator.pop(context);
                        successSnackbar('exchange_rate_saved'.tr);
                      } catch (_) {}
                    },
                    text: 'save'.tr),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
