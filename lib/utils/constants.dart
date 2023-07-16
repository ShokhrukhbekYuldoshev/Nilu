import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nilu/controllers/profile_controller.dart';

//* Colors
const Color primaryColor = Color(0xFF0057DA);
const Color primaryLightColor = Color.fromARGB(255, 104, 164, 255);
const Color primaryUltraLightColor = Color(0xFFF0F5FF);
const Color gray100Color = Color(0xFFF5F5F5);
const Color gray200Color = Color(0xFFEEEEEE);
const Color gray300Color = Color(0xFFE0E0E0);
const Color gray400Color = Color(0xFFBDBDBD);
const Color gray500Color = Color(0xFFE0E0E0);
const Color whiteColor = Color(0xFFFFFFFF);
const Color textDarkColor = Color(0xFF2B2B2B);
const Color textPlaceholderColor = Color(0xFFAAAAAA);
const Color textMutedColor = Color(0xFF828282);
const Color borderColor = Color(0xFFE0E0E0);
const Color iconGrayColor = Color(0xFFAAAAAA);
const Color warningColor = Color(0xFFFF7A00);
const Color redColor = Color(0xFFEB5757);
const Color greenColor = Color(0xFF219653);

const Color darkGrayColor = Color(0xFF333333);
const Color mediumGrayColor = Color(0xFF444444);
const Color lightGrayColor = Color(0xFF666666);

final firestore = FirebaseFirestore.instance;

TextStyle bodyText(Color? color) {
  return TextStyle(
    fontFamily: 'Roboto',
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: color,
  );
}

TextStyle h5(Color? color) {
  return TextStyle(
    fontFamily: 'Roboto',
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: color,
  );
}

TextStyle h6(Color? color) {
  return TextStyle(
    fontFamily: 'Roboto',
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: color,
  );
}

//* Format currency
String formatCurrency(double amount, String value) {
  return '${NumberFormat.currency(
    symbol: '',
    decimalDigits: 2,
    name: value,
  ).format(amount)} $value';
}

String formatCurrencyWithoutSymbol(double amount) {
  return NumberFormat.currency(
    symbol: '',
    decimalDigits: 2,
  ).format(amount);
}

//* Input Padding
const inputPadding = EdgeInsets.symmetric(vertical: 8, horizontal: 10);

//* Snackbar
SnackbarController errorSnackbar(String message) {
  return Get.snackbar(
    'error'.tr,
    message,
    icon: const Icon(
      Icons.error,
      color: whiteColor,
    ),
    colorText: whiteColor,
    backgroundColor: const Color.fromRGBO(255, 0, 0, 0.5),
    duration: const Duration(seconds: 2),
    isDismissible: false,
  );
}

ProfileController _profileController = Get.find();
bool hasSecondaryCurrency() {
  return _profileController.user['secondaryCurrency'] != '';
}

SnackbarController successSnackbar(String message) {
  return Get.snackbar(
    'success'.tr,
    message,
    icon: const Icon(
      Icons.check,
      color: whiteColor,
    ),
    colorText: whiteColor,
    backgroundColor: const Color.fromRGBO(0, 255, 0, 0.5),
    duration: const Duration(seconds: 2),
    isDismissible: false,
  );
}
