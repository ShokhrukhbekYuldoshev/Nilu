import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/cart_controller.dart';
import 'package:nilu/models/product_model.dart';
import '../../../utils/constants.dart';
import '../dialogs/add_to_cart_dialog.dart';

class ActionsBottomSheet extends StatelessWidget {
  ActionsBottomSheet({Key? key, required this.product}) : super(key: key);

  final CartController _cartController = Get.find();

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 60,
                width: double.maxFinite,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (context) => AddToCartDialog(
                            product: product,
                            itemCounter: _cartController
                                .singleProductQuantity(product.id)));
                  },
                  child: Text(
                    'change'.tr,
                    style: const TextStyle(
                        color: primaryColor, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const Divider(
                height: 0,
              ),
              SizedBox(
                width: double.maxFinite,
                height: 60,
                child: TextButton(
                  onPressed: () async {
                    _cartController.clearSingleProduct(product);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'delete'.tr,
                    style: const TextStyle(
                        color: Color(0xFFEB5757), fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(
          height: 0,
        ),
        Container(
          color: Colors.transparent,
          height: 8,
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          child: SizedBox(
            width: double.maxFinite,
            height: 60,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'cancel'.tr,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 25,
        )
      ],
    );
  }
}
