import 'package:get/get.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static SharedPreferences? _prefs;
  static final ProfileController _profileController = Get.find();

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // * Profile data
  static bool isLoggedIn() {
    return _prefs?.getBool('isLoggedIn') ?? false;
  }

  static setLoggedIn(bool value) async {
    await _prefs?.setBool('isLoggedIn', value);
  }

  static String getPhone() {
    return _prefs?.getString('phone') ?? '';
  }

  static setPhone(String value) async {
    await _prefs?.setString('phone', value);
  }

  static getCurrencies() {
    final List<String> currencies = [
      _profileController.user['mainCurrency'],
      _profileController.user['secondaryCurrency'],
    ];
    return currencies;
  }

  // * Exchange rates
  static Future setExchangeRate(double value) async {
    await _prefs?.setDouble('rate', value);
  }

  static getExchangeRate() => _prefs?.getDouble('rate') ?? 0;

  static Future setExchangeRateDate(String value) async {
    await _prefs?.setString('rateDate', value);
  }

  static getExchangeRateDate() => _prefs?.getString('rateDate') ?? '';

  static Future setExchangeRateAdjustment(double value) async {
    await _prefs?.setDouble('rateAdjustment', value);
  }

  static getExchangeRateAdjustment() =>
      _prefs?.getDouble('rateAdjustment') ?? 0;

  static Future setExchangeRateType(String value) async {
    await _prefs?.setString('rateType', value);
  }

  static getExchangeRateType() => _prefs?.getString('rateType') ?? 'auto';

  static getExchangeRateResult() {
    return getExchangeRate() + getExchangeRateAdjustment();
  }

  // * Themes
  static Future setTheme(value) async {
    await _prefs?.setBool('isDarkMode', value);
  }

  static getTheme() => _prefs?.getBool('isDarkMode') ?? false;
  // * Notification

  static Future setNotification(value) async {
    await _prefs?.setBool('isNotificationEnabled', value);
  }

  static getNotification() => _prefs?.getBool('isNotificationEnabled') ?? false;
  // * Language
  static Future setLanguage(value) async {
    await _prefs?.setString('language', value);
  }

  static getLanguage() => _prefs?.getString('language') ?? 'english';
}
