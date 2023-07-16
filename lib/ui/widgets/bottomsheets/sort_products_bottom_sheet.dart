import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../utils/constants.dart';
import '../../../utils/preferences.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

class SortProductsBottomSheet extends StatefulWidget {
  const SortProductsBottomSheet({Key? key}) : super(key: key);

  @override
  State<SortProductsBottomSheet> createState() =>
      _SortProductsBottomSheetState();
}

class _SortProductsBottomSheetState extends State<SortProductsBottomSheet> {
  List<String> localFilterCategories = [];
  final ProductController _productController = Get.find();
  @override
  void initState() {
    localFilterCategories = [..._productController.filterCategories];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find();
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'categories'.tr,
                  style: h5(Theme.of(context).textTheme.bodyLarge!.color),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.close,
                    color: iconGrayColor,
                  ),
                ),
              ],
            ),
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
                    1.0
                  ], // 10% purple, 80% transparent, 10% purple
                ).createShader(rect);
              },
              blendMode: BlendMode.dstOut,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: profileController.user['categories'].length,
                itemBuilder: (_, index) {
                  return CheckboxListTile(
                    visualDensity: VisualDensity.compact,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Preferences.getTheme()
                        ? primaryLightColor
                        : primaryColor,
                    title: Text(
                      profileController.user['categories'][index],
                    ),
                    value: localFilterCategories.contains(
                      profileController.user['categories'][index],
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (localFilterCategories.contains(
                            profileController.user['categories'][index])) {
                          localFilterCategories.remove(
                            profileController.user['categories'][index],
                          );
                        } else {
                          localFilterCategories.add(
                            profileController.user['categories'][index],
                          );
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Preferences.getTheme() ? lightGrayColor : borderColor,
                ),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: SecondaryButton(
                    onPressed: () {
                      _productController.filterCategories.clear();
                      _productController.filterProducts();
                      Navigator.pop(context);
                    },
                    text: 'reset'.tr,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PrimaryButton(
                    text: 'apply'.tr,
                    onPressed: () {
                      _productController
                          .setFilterCategories(localFilterCategories);
                      _productController.filterProducts();
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
