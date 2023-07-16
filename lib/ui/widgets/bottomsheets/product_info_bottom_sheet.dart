import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/product_controller.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/ui/screens/product/edit_product_screen.dart';
import 'package:nilu/ui/widgets/buttons/secondary_button.dart';
import 'package:nilu/ui/widgets/dialogs/double_action_dialog.dart';

import '../../../utils/constants.dart';
import '../../../controllers/cart_controller.dart';
import '../../../models/product_model.dart';
import '../dialogs/product_quantity_dialog.dart';
import '../buttons/delete_save_button.dart';

class ProductInfoBottomSheet extends StatelessWidget {
  ProductInfoBottomSheet({Key? key, required this.product}) : super(key: key);

  final Product product;
  final ProductController _productController = Get.find();
  final ProfileController _profileController = Get.find();
  final CartController _cartController = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: product.image != null && product.image != ''
                        ? CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              padding: const EdgeInsets.all(10),
                              child: const CircularProgressIndicator(),
                            ),
                            imageUrl: product.image!,
                            errorWidget: (context, url, error) => Container(
                              width: 100,
                              height: 100,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF80B2FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Image.asset(
                                'assets/images/box.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 100,
                            height: 100,
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(
                              color: Color(0xFF80B2FF),
                            ),
                            child: Image.asset(
                              'assets/images/box.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: h5(
                            Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${'category'.tr}: ${product.category!}',
                          style: bodyText(
                              Theme.of(context).textTheme.bodyMedium!.color),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${'code'.tr}:',
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  product.code != '' ? product.code : 'N/A',
                                  style: h6(
                                    Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${'in_stock'.tr}:',
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  product.quantity.toString(),
                                  style: h6(
                                    warningColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${'price'.tr}:',
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  formatCurrency(product.price,
                                      _profileController.user['mainCurrency']),
                                  style: h6(
                                    Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'stock_in_out'.tr,
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) =>
                              ProductQuantityDialog(product: product),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'edit_product'.tr,
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (context) =>
                                EditProductScreen(product: product),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: DeleteSaveButton(
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (context) => DoubleActionDialog(
                        title: 'delete_product'.tr,
                        content: 'delete_product_confirmation'.tr,
                        confirm: 'delete'.tr,
                        cancel: 'cancel'.tr,
                        onConfirm: () {
                          _productController.deleteProduct(product);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        onCancel: () {
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                  onSave: () {
                    if (product.quantity! > 0) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (route) => false);

                      Navigator.pushNamed(context, '/sale/add');
                      _cartController.updateCart(product, 1, product.price);
                      Navigator.pushNamed(context, '/cart');
                    } else {
                      errorSnackbar('not_enough'.tr);
                    }
                  },
                  text: 'make_sale'.tr,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
