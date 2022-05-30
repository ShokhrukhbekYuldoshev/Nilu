import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/views/widgets/buttons/delete_save_button.dart';

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
    final TextEditingController _exchangeRateController = TextEditingController(
      text: formatCurrencyWithoutSymbol(Preferences.getExchangeRate()),
    );
    final ProfileController _profileController = Get.find();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.maxFinite,
              color: primaryColor,
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 32,
                ),
                child: Text(
                  'Exchange Rate',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: whiteColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Preferences.getTheme() ? darkGrayColor : whiteColor,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      title: Text('Auto-update from central bank',
                          style: bodyText(
                              Theme.of(context).textTheme.bodyText1!.color)),
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
                          children: Preferences.getExchangeRateDate() != ""
                              ? [
                                  const Divider(),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Bank rate: 1 ${_profileController.user['secondaryCurrency']} = ${formatCurrency(Preferences.getExchangeRate(), _profileController.user['mainCurrency'])}',
                                    style: h5(
                                      Preferences.getExchangeRateAdjustment() !=
                                              0
                                          ? Theme.of(context)
                                              .textTheme
                                              .bodyText2!
                                              .color
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .color,
                                    ),
                                  ),
                                  Preferences.getExchangeRateAdjustment() != 0
                                      ? Text(
                                          'New rate: 1 ${_profileController.user['secondaryCurrency']} = ${formatCurrency(Preferences.getExchangeRateResult(), _profileController.user['mainCurrency'])}',
                                          style: h5(
                                            Theme.of(context)
                                                .textTheme
                                                .bodyText1!
                                                .color,
                                          ),
                                        )
                                      : Container(),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        primary: Preferences.getTheme()
                                            ? lightGrayColor
                                            : primaryUltraLightColor,
                                        textStyle: bodyText(whiteColor)),
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
                                        builder: (_) => AutoAdjustBottomSheet(
                                          profileController: _profileController,
                                          exchangeRateController:
                                              _exchangeRateController,
                                        ),
                                      ).then((_) {
                                        setState(() => {});
                                      });
                                    },
                                    child: Text(
                                      '+/- Auto adjust',
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
                color: Preferences.getTheme() ? darkGrayColor : whiteColor,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      'Manual input',
                      style: bodyText(
                        Theme.of(context).textTheme.bodyText1!.color,
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
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Preferences.getTheme()
                                          ? mediumGrayColor
                                          : const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                        '1 ${_profileController.user['secondaryCurrency']} = ',
                                        style: bodyText(Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .color)),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: TextField(
                                      controller: _exchangeRateController,
                                      autofocus: true,
                                      keyboardType: TextInputType.number,
                                      style: bodyText(Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .color),
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        border: const OutlineInputBorder(),
                                        hintText: 'Enter amount',
                                        hintStyle: bodyText(Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .color),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  PrimaryButton(
                                    text: "Save",
                                    onPressed: () {
                                      try {
                                        Preferences.setExchangeRate(
                                          double.parse(
                                            _exchangeRateController.text
                                                .replaceAll(',', ''),
                                          ),
                                        );
                                        Preferences.setExchangeRateAdjustment(
                                            0);
                                        FocusScope.of(context).unfocus();
                                        successSnackbar('Exchange rate saved');
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
                  'Auto adjustment',
                  style: h5(
                    Theme.of(context).textTheme.bodyText1!.color,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Bank rate: 1 ${widget._profileController.user['secondaryCurrency']} = ${formatCurrency(Preferences.getExchangeRate(), widget._profileController.user['mainCurrency'])}',
                  style: bodyText(
                    Theme.of(context).textTheme.bodyText2!.color,
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
                          '+/- adjust by',
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
                            Theme.of(context).textTheme.bodyText1!.color,
                          ),
                          decoration: InputDecoration(
                            contentPadding: inputPadding,
                            hintText: 'Enter rate',
                            hintStyle: bodyText(
                              Theme.of(context).textTheme.bodyText1!.color,
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
                  'New rate: 1 ${widget._profileController.user['secondaryCurrency']} = ${formatCurrency(Preferences.getExchangeRate() + (isDouble(_adjustmentController.text) ? double.parse(_adjustmentController.text) : 0), widget._profileController.user['mainCurrency'])}',
                  style: bodyText(
                    Theme.of(context).textTheme.bodyText2!.color,
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
                        successSnackbar('Exchange rate saved');
                      } catch (_) {}
                    },
                    text: 'Save'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
