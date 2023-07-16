import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = Get.put(AuthController());
  static String countryCode = '1';

  String verificationID = "";
  @override
  void initState() {
    super.initState();
    updatePlaceholderHint();
    getCountryCode();
    _authController.isLoading.value = false;
  }

  void getCountryCode() async {
    countryController.text = countryCode;
    final sortedCountries = CountryManager().countries
      ..sort((a, b) => (a.countryName ?? '').compareTo(b.countryName ?? ''));

    currentSelectedCountry = sortedCountries
        .firstWhere((country) => country.phoneCode == countryCode);

    updatePlaceholderHint();
  }

  final phoneController = TextEditingController();
  final countryController = TextEditingController(text: countryCode);

  /// Used to format numbers as mobile or land line
  var globalPhoneType = PhoneNumberType.mobile;

  /// Use international or national phone format
  var globalPhoneFormat = PhoneNumberFormat.international;

  /// Current selected country
  var currentSelectedCountry = const CountryWithPhoneCode.us();

  var placeholderHint = '';

  var inputContainsCountryCode = false;

  void updatePlaceholderHint() {
    late String newPlaceholder;

    if (globalPhoneType == PhoneNumberType.mobile) {
      if (globalPhoneFormat == PhoneNumberFormat.international) {
        newPlaceholder = currentSelectedCountry.phoneMaskMobileInternational;
      } else {
        newPlaceholder = currentSelectedCountry.phoneMaskMobileNational;
      }
    } else {
      if (globalPhoneFormat == PhoneNumberFormat.international) {
        newPlaceholder = currentSelectedCountry.phoneMaskFixedLineInternational;
      } else {
        newPlaceholder = currentSelectedCountry.phoneMaskFixedLineNational;
      }
    }

    if (!inputContainsCountryCode) {
      newPlaceholder =
          newPlaceholder.substring(currentSelectedCountry.phoneCode.length + 2);
    }

    if (!mounted) {
      return;
    }

    setState(() => placeholderHint = newPlaceholder);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Obx(
        () => _authController.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     Text(
                    //       'restore_account'.tr,
                    //       style: bodyText(primaryColor),
                    //     ),
                    //   ],
                    // ),
                    Image.asset(
                      "assets/images/cash_register.png",
                      height: 90,
                      width: 90,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nilu Mobile POS',
                      style: TextStyle(
                        fontSize: 32,
                        color: textDarkColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: Text(
                        'app_description'.tr,
                        style: bodyText(textMutedColor),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 44,
                      width: double.infinity,
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.1,
                            constraints: const BoxConstraints(minWidth: 80),
                            child: TextField(
                              onChanged: (v) {
                                final sortedCountries = CountryManager()
                                    .countries
                                  ..sort((a, b) => (a.countryName ?? '')
                                      .compareTo(b.countryName ?? ''));

                                try {
                                  currentSelectedCountry =
                                      sortedCountries.firstWhere(
                                          (country) => country.phoneCode == v);
                                } catch (_) {}
                                updatePlaceholderHint();
                              },
                              controller: countryController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                                counterText: '',
                                prefix: Text(
                                  '+',
                                  style: bodyText(
                                    Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              maxLength: 3,
                              keyboardType: TextInputType.phone,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              inputFormatters: [
                                LibPhonenumberTextFormatter(
                                  country: currentSelectedCountry,
                                ),
                              ],
                              textAlign: TextAlign.center,
                              controller: phoneController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                                hintText: placeholderHint,
                                hintStyle: bodyText(gray400Color),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _authController.isLoading.value = true;
                          });
                          String phoneNumber =
                              '+${countryController.text.replaceAll(RegExp(r'[^0-9]'), '')}${phoneController.text.replaceAll(RegExp(r'[^0-9]'), '')}';

                          if (phoneNumber.isPhoneNumber) {
                            _authController.loginWithPhone(
                              phoneNumber,
                              verificationID,
                              context,
                            );
                          } else {
                            errorSnackbar('not_phone_number'.tr);
                            _authController.isLoading.value = false;
                          }
                        },
                        text: 'continue'.tr,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
