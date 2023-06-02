import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/profile_controller.dart';
import '../../../utils/preferences.dart';
import '../dialogs/add_to_cart_dialog.dart';
import '../bottomsheets/actions_bottom_sheet.dart';
import '../../../controllers/cart_controller.dart';
import '../../../models/product_model.dart';
import '../../../utils/constants.dart';

class SaleTile extends StatelessWidget {
  SaleTile({Key? key, required this.product}) : super(key: key);

  final CartController _cartController = Get.find();
  final ProfileController _profileController = Get.find();

  final Product product;
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            product.image != ''
                ? Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: product.image!,
                        placeholder: (context, url) => Container(
                          padding: const EdgeInsets.all(10),
                          child: const CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF80B2FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Image.asset('assets/images/box.png'),
                        ),
                        height: 48,
                        width: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF80B2FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Image.asset('assets/images/box.png'),
                  ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: h6(
                      Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    formatCurrency(
                        product.price, _profileController.user['mainCurrency']),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF999999),
                    ),
                  ),
                  hasSecondaryCurrency()
                      ? Text(
                          formatCurrency(
                              product.price /
                                  Preferences.getExchangeRateResult(),
                              _profileController.user['secondaryCurrency']),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF999999),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        product.quantity.toString(),
                        style: bodyText(
                          warningColor,
                        ),
                      ),
                      Text(
                        'in_stock'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          color: warningColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  const VerticalDivider(
                    color: borderColor,
                    width: 1,
                  ),
                  _cartController.singleProductQuantity(product.id) > 0
                      ? TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            minimumSize: const Size(0, 0),
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.8,
                              ),
                              context: context,
                              builder: (context) {
                                return ActionsBottomSheet(
                                  product: product,
                                );
                              },
                            );
                          },
                          child: Text(
                            _cartController
                                .singleProductQuantity(product.id)
                                .toString(),
                            style: TextStyle(
                              fontSize: 24,
                              color: Preferences.getTheme()
                                  ? primaryLightColor
                                  : primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: () {
                            if (product.quantity! > 0) {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) => AddToCartDialog(
                                  product: product,
                                  itemCounter:
                                      _cartController.singleProductQuantity(
                                    product.id,
                                  ),
                                ),
                              );
                            } else {
                              return;
                            }
                          },
                          icon: Icon(
                            Icons.add_circle,
                            color: product.quantity! > 0
                                ? Preferences.getTheme()
                                    ? primaryLightColor
                                    : primaryColor
                                : iconGrayColor,
                            size: 28,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
