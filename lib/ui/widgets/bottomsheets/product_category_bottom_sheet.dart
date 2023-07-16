import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/product_controller.dart';
import 'package:nilu/controllers/profile_controller.dart';
import '../../../utils/constants.dart';
import '../../../utils/preferences.dart';
import '../buttons/primary_button.dart';

class ProductCategoryBottomSheet extends StatefulWidget {
  const ProductCategoryBottomSheet({
    Key? key,
    required this.refresh,
  }) : super(key: key);
  final VoidCallback refresh;
  @override
  State<ProductCategoryBottomSheet> createState() =>
      _ProductCategoryBottomSheetState();
}

class _ProductCategoryBottomSheetState
    extends State<ProductCategoryBottomSheet> {
  final ProductController _productController = Get.find();
  final ProfileController _profileController = Get.find();

  @override
  Widget build(BuildContext context) {
    int radioValue = _profileController.user['categories']
        .indexOf(_productController.selectedCategory.value);
    final TextEditingController newCategoryController = TextEditingController();
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Wrap(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "categories".tr,
                      style: h5(
                        Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        ..._profileController.user['categories']
                            .map((category) {
                          return Container(
                            padding: const EdgeInsets.all(0),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Preferences.getTheme()
                                    ? mediumGrayColor
                                    : borderColor,
                              ),
                            ),
                            child: SizedBox(
                              height: 44,
                              child: RadioListTile(
                                visualDensity: VisualDensity.compact,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 0,
                                ),
                                activeColor: Preferences.getTheme()
                                    ? primaryLightColor
                                    : primaryColor,
                                title: Text(
                                  category,
                                  style: bodyText(
                                    Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                  ),
                                ),
                                value: _profileController.user['categories']
                                    .indexOf(category),
                                groupValue: radioValue,
                                onChanged: (dynamic value) {
                                  setState(() {
                                    radioValue = value;
                                    _productController.setCategory(category);
                                    widget.refresh();
                                    Navigator.pop(context);
                                  });
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 44,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(0),
                                elevation: 0,
                                backgroundColor: primaryUltraLightColor,
                              ),
                              onPressed: () {
                                addCategory(context, newCategoryController);
                              },
                              child: const Icon(
                                Icons.settings,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.add,
                                color: primaryColor,
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(0),
                                elevation: 0,
                                backgroundColor: primaryUltraLightColor,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                addCategory(context, newCategoryController);
                              },
                              label: Text('add_new_category'.tr,
                                  style: h6(primaryColor)),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> addCategory(
      BuildContext context, TextEditingController newCategoryController) {
    return showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) {
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
                      "new_category".tr,
                      style: h5(
                        Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 44,
                      child: TextField(
                        controller: newCategoryController,
                        autofocus: true,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          labelText: 'category_name'.tr,
                          labelStyle: bodyText(textPlaceholderColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: PrimaryButton(
                              text: 'save'.tr,
                              onPressed: () async {
                                await firestore
                                    .collection('users')
                                    .doc(_profileController.user['id'])
                                    .update({
                                  'categories': FieldValue.arrayUnion(
                                    [newCategoryController.text.trim()],
                                  ),
                                });
                                _productController
                                    .setCategory(newCategoryController.text);
                                _profileController.updateUserData();
                                widget.refresh();
                                if (mounted) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
