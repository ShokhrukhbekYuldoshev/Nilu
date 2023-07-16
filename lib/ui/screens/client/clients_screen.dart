import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/utils/preferences.dart';
import 'package:nilu/ui/widgets/dialogs/sort_client_dialog.dart';
import 'package:nilu/ui/widgets/search_filter_icon.dart';
import '../../widgets/bottomsheets/client_info_bottom_sheet.dart';
import '../../../controllers/client_controller.dart';
import '../../../utils/constants.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({Key? key}) : super(key: key);

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final ClientController _clientController = Get.find();
  final ProfileController _profileController = Get.find();

  @override
  void dispose() {
    Timer.run(() {
      _clientController.searchClients.value = _clientController.clients;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('clients'.tr),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/client/add',
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _clientController.search(value);
                          });
                        },
                        decoration: InputDecoration(
                          contentPadding: inputPadding,
                          prefixIcon: const Icon(Icons.search),
                          prefixIconColor: iconGrayColor,
                          filled: true,
                          fillColor: Preferences.getTheme()
                              ? darkGrayColor
                              : gray100Color,
                          hintText: 'search'.tr,
                          hintStyle: bodyText(textPlaceholderColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(
                              color: Preferences.getTheme()
                                  ? mediumGrayColor
                                  : const Color(0xFFE0E0E0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(
                              color: Preferences.getTheme()
                                  ? mediumGrayColor
                                  : const Color(0xFFE0E0E0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SearchFilterIcon(
                      icon: Icons.sort,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) {
                            return const SortClientDialog();
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _clientController.clients.isEmpty
                    ? Center(
                        child: Text(
                          'not_found'.tr,
                          style: bodyText(
                            Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _clientController.searchClients.length,
                        itemBuilder: (context, index) {
                          final client = _clientController.searchClients[index];
                          return ListTile(
                            onTap: () {
                              showModalBottomSheet(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4),
                                  ),
                                ),
                                isScrollControlled: true,
                                context: context,
                                builder: (_) {
                                  return ClientInfoBottomSheet(
                                    client: client,
                                  );
                                },
                              );
                            },
                            contentPadding: const EdgeInsets.all(0),
                            leading: SizedBox(
                              height: 36,
                              width: 36,
                              child: client.image != ''
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: CachedNetworkImage(
                                        imageUrl: client.image!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: gray200Color,
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                              ),
                                            ),
                                            const Icon(
                                              Icons.person,
                                              color: iconGrayColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: gray200Color,
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.person,
                                          color: iconGrayColor,
                                        ),
                                      ],
                                    ),
                            ),
                            title: Text(
                              client.name,
                              style: bodyText(
                                  Theme.of(context).textTheme.bodyLarge!.color),
                            ),
                            subtitle: client.debt > 0
                                ? Text(
                                    '${'debt'.tr}: ${formatCurrency(client.debt, _profileController.user['mainCurrency'])}',
                                    style: const TextStyle(
                                        fontSize: 14, color: redColor),
                                  )
                                : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
