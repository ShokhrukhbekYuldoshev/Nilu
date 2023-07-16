import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/auth_controller.dart';
import 'package:nilu/utils/constants.dart';

import '../../widgets/bottomsheets/currency_picker_bottom_sheet.dart';
import '../../widgets/buttons/primary_button.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({Key? key}) : super(key: key);

  final TextEditingController _nameController = TextEditingController(
    text: '',
  );
  final TextEditingController _businessController = TextEditingController(
    text: '',
  );
  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            _authController.mainCurrency.value = '';
            _authController.secondaryCurrency.value = '';
            _authController.isLoading.value = false;
            Navigator.pop(context);
          },
        ),
      ),
      body: Obx(
        () => SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  runAlignment: WrapAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'account_info'.tr,
                            style: const TextStyle(
                              color: textDarkColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            formatNumberSync(
                              _authController.phoneNumber.toString(),
                            ),
                            style: bodyText(textMutedColor),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: gray200Color,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: iconGrayColor,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _nameController,
                    maxLength: 25,
                    autofocus: true,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      labelText: '${'name'.tr}*',
                      counterText: '',
                      hintStyle: bodyText(
                        textPlaceholderColor,
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: borderColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  height: 44,
                  child: TextField(
                    maxLength: 25,
                    controller: _businessController,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      labelText: '${'business_name'.tr}*',
                      counterText: '',
                      hintStyle: bodyText(
                        textPlaceholderColor,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: borderColor,
                        ),
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: borderColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  height: 44,
                  child: TextField(
                    onTap: () {
                      showModalBottomSheet(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return const CurrencyPickerBottomSheet(
                            isAuth: true,
                          );
                        },
                      );
                    },
                    readOnly: true,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      hintText: _authController.mainCurrency.value == ""
                          ? '${'main_currency'.tr}*'
                          : _authController.mainCurrency.value,
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: borderColor,
                        ),
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: borderColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  height: 44,
                  child: TextField(
                    onTap: () {
                      showModalBottomSheet(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return const CurrencyPickerBottomSheet(
                            isAuth: true,
                            isMainCurrency: false,
                          );
                        },
                      );
                    },
                    readOnly: true,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      hintText: _authController.secondaryCurrency.value == ""
                          ? 'secondary_currency'.tr
                          : _authController.secondaryCurrency.value,
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: borderColor,
                        ),
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: borderColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'save_and_continue'.tr,
                    onPressed: () {
                      if (_nameController.text != '' &&
                          _businessController.text != '' &&
                          _authController.mainCurrency.value != '') {
                        _authController.register(
                          _nameController.text.trim(),
                          _authController.phoneNumber.toString().trim(),
                          _businessController.text.trim(),
                          _authController.mainCurrency.value.trim(),
                          _authController.secondaryCurrency.value.trim(),
                          context,
                        );
                        _authController.mainCurrency.value = '';
                      } else {
                        errorSnackbar('fill_required_fields'.tr);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
