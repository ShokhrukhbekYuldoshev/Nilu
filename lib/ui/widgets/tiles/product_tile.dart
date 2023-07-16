import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/utils/preferences.dart';
import '../../widgets/bottomsheets/product_info_bottom_sheet.dart';
import '../../../models/product_model.dart';
import '../../../utils/constants.dart';
import '../dialogs/product_quantity_dialog.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({Key? key, required this.product}) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find();
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          builder: (_) => ProductInfoBottomSheet(
            product: product,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Preferences.getTheme() ? mediumGrayColor : borderColor,
              width: 1,
            ),
          ),
        ),
        margin: const EdgeInsets.only(left: 16, right: 16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: product.image != ''
                    ? Container(
                        margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
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
                              decoration: const BoxDecoration(
                                color: Color(0xFF80B2FF),
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
                        margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF80B2FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Image.asset('assets/images/box.png'),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: bodyText(
                          Preferences.getTheme()
                              ? primaryLightColor
                              : primaryColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        formatCurrency(product.price,
                            profileController.user['mainCurrency']),
                        style: bodyText(
                          Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                      ),
                      hasSecondaryCurrency()
                          ? Text(
                              formatCurrency(
                                  product.price /
                                      Preferences.getExchangeRateResult(),
                                  profileController.user['secondaryCurrency']),
                              style: bodyText(
                                Theme.of(context).textTheme.bodyMedium!.color,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) =>
                              ProductQuantityDialog(product: product),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width * 0.25,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Preferences.getTheme()
                                  ? mediumGrayColor
                                  : borderColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.quantity.toString(),
                              style: h5(
                                warningColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.unfold_more,
                              color: iconGrayColor,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
