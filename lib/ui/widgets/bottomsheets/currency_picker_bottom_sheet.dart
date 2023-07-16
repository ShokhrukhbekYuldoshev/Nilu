import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/profile_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../secret.dart';
import '../../../utils/constants.dart';
import '../../../utils/currencies.dart';
import '../../../utils/preferences.dart';

class CurrencyPickerBottomSheet extends StatefulWidget {
  final bool isMainCurrency;
  final bool isAuth;
  const CurrencyPickerBottomSheet({
    Key? key,
    this.isMainCurrency = true,
    this.isAuth = false,
  }) : super(key: key);

  @override
  State<CurrencyPickerBottomSheet> createState() =>
      _CurrencyPickerBottomSheetState();
}

class _CurrencyPickerBottomSheetState extends State<CurrencyPickerBottomSheet> {
  List<dynamic> searchCurrencies = [];

  @override
  void initState() {
    super.initState();
    searchCurrencies = currencies;
  }

  @override
  void dispose() {
    super.dispose();
  }

  final TextEditingController _searchController = TextEditingController();
  final AuthController _authController = Get.find();
  final ProfileController _profileController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        searchCurrencies = currencies
                            .where((currency) => currency
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'search'.tr,
                      contentPadding: const EdgeInsets.all(0),
                      hintStyle: bodyText(iconGrayColor),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: iconGrayColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                widget.isMainCurrency
                    ? Container()
                    : IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          if (widget.isAuth) {
                            _authController.secondaryCurrency.value = '';
                          } else {
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                });
                            await firestore
                                .collection('users')
                                .doc(_profileController.user['id'])
                                .update(
                              {
                                'secondaryCurrency': '',
                              },
                            );
                            await _profileController.updateUserData();
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          }
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        },
                      ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: ShaderMask(
                shaderCallback: (Rect rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.purple,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.purple
                    ],
                    stops: [
                      0.0,
                      0.05,
                      0.9,
                      1
                    ], // 10% purple, 80% transparent, 10% purple
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstOut,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: searchCurrencies.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        searchCurrencies[index],
                        style: bodyText(
                            Theme.of(context).textTheme.bodyLarge!.color),
                      ),
                      onTap: () async {
                        if (widget.isMainCurrency) {
                          if (widget.isAuth) {
                            _authController.mainCurrency.value =
                                searchCurrencies[index];
                          } else {
                            final ProfileController profileController =
                                Get.find();
                            await firestore
                                .collection('users')
                                .doc(profileController.user['id'])
                                .update(
                              {
                                'mainCurrency': searchCurrencies[index],
                              },
                            );
                          }
                        } else {
                          if (widget.isAuth) {
                            _authController.secondaryCurrency.value =
                                searchCurrencies[index];
                          } else {
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                });

                            await firestore
                                .collection('users')
                                .doc(_profileController.user['id'])
                                .update(
                              {
                                'secondaryCurrency': searchCurrencies[index],
                              },
                            );
                            await _profileController.updateUserData();
                            var url = Uri.parse(
                              'https://v6.exchangerate-api.com/v6/$exchangeApiKey/pair/${_profileController.user['secondaryCurrency']}/${_profileController.user['mainCurrency']}',
                            );
                            var response = await http.get(url);
                            if (response.statusCode == 200) {
                              var jsonResponse = jsonDecode(response.body);
                              Preferences.setExchangeRate(
                                  jsonResponse['conversion_rate'] +
                                      Preferences.getExchangeRateAdjustment());
                              Preferences.setExchangeRateDate(
                                  DateTime.now().toString());
                            }
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          }
                        }
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
