import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/client_controller.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/controllers/sale_controller.dart';
import 'package:nilu/models/client_model.dart';
import 'package:nilu/ui/widgets/dialogs/double_action_dialog.dart';

import '../../../utils/constants.dart';
import '../../screens/client/edit_client_screen.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

class ClientInfoBottomSheet extends StatelessWidget {
  final Client client;
  const ClientInfoBottomSheet({Key? key, required this.client})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ClientController clientController = Get.find();
    final ProfileController profileController = Get.find();
    final SaleController saleController = Get.find();
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 25.0,
            horizontal: 20,
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: client.image != null && client.image != ''
                    ? Container(
                        decoration: const BoxDecoration(
                          color: gray200Color,
                        ),
                        width: 72,
                        height: 72,
                        child: CachedNetworkImage(
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          imageUrl: client.image!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                            radius: 31,
                            backgroundColor: gray200Color,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      )
                    : const CircleAvatar(
                        radius: 31,
                        backgroundColor: gray200Color,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: primaryColor,
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              Text(
                client.name,
                style: h5(Theme.of(context).textTheme.bodyLarge!.color),
              ),
              const SizedBox(height: 12),
              Text(
                client.phone != "" ? client.phone : "no_phone".tr,
                style: bodyText(
                  Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                  client.note != null && client.note != ''
                      ? client.note!
                      : 'no_note'.tr,
                  style: bodyText(
                    Theme.of(context).textTheme.bodyMedium!.color,
                  )),
              const SizedBox(height: 12),
              Text(
                client.debt > 0
                    ? "${'debt'.tr}: ${formatCurrency(client.debt, profileController.user['mainCurrency'])}"
                    : 'no_debt'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: client.debt > 0
                      ? redColor
                      : Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
              const SizedBox(height: 44),
              SizedBox(
                height: 44,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: borderColor,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) {
                              return DoubleActionDialog(
                                title: 'delete_client'.tr,
                                content: 'delete_client_confirmation'.tr,
                                confirm: 'delete'.tr,
                                cancel: 'cancel'.tr,
                                onConfirm: () {
                                  clientController.deleteClient(client.id);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                onCancel: () {
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: redColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SecondaryButton(
                      text: 'edit'.tr,
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => EditClientScreen(
                              client: client,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PrimaryButton(
                        text: 'view_orders'.tr,
                        onPressed: () {
                          saleController.filterClients([client.id]);
                          saleController.filterSales();
                          Navigator.pushNamed(context, '/sales');
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
