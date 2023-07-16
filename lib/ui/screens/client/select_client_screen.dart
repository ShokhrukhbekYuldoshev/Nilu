import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/client_controller.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/utils/constants.dart';
import '../../../controllers/cart_controller.dart';
import '../../../utils/preferences.dart';
import '../../widgets/dialogs/sort_client_dialog.dart';
import '../../widgets/search_filter_icon.dart';

class SelectClientScreen extends StatefulWidget {
  const SelectClientScreen({Key? key}) : super(key: key);

  @override
  State<SelectClientScreen> createState() => _SelectClientScreenState();
}

class _SelectClientScreenState extends State<SelectClientScreen> {
  final CartController _cartController = Get.find();
  final ClientController _clientController = Get.find();
  final ProfileController _profileController = Get.find();

  @override
  void dispose() {
    _clientController.searchClients.value = _clientController.clients;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Preferences.getTheme() ? darkGrayColor : gray100Color,
        elevation: 0,
        title: Text(
          'select_client'.tr,
          style: TextStyle(
            color:
                Preferences.getTheme() ? primaryUltraLightColor : textDarkColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).textTheme.bodyLarge!.color),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/client/add');
        },
        child: const Icon(Icons.add),
      ),
      body: Obx(
        () => SingleChildScrollView(
          child: Padding(
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
                ListTile(
                  onTap: () {
                    _cartController.clearClient();
                    Navigator.pop(context);
                  },
                  contentPadding: const EdgeInsets.all(0),
                  leading: SizedBox(
                    height: 36,
                    width: 36,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: gray200Color,
                            borderRadius: BorderRadius.circular(100),
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
                    'unnamed_client'.tr,
                    style:
                        bodyText(Theme.of(context).textTheme.bodyLarge!.color),
                  ),
                  trailing: _cartController.client == null
                      ? const Icon(Icons.check)
                      : null,
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _clientController.searchClients.length,
                  itemBuilder: (context, index) {
                    final client = _clientController.searchClients[index];
                    return ListTile(
                      onTap: () {
                        _cartController.setClient(client);
                        Navigator.pop(context);
                      },
                      contentPadding: const EdgeInsets.all(0),
                      leading: SizedBox(
                        height: 36,
                        width: 36,
                        child: client.image != ''
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.network(
                                  client.image!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: gray200Color,
                                      borderRadius: BorderRadius.circular(100),
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
                      trailing: _cartController.client == client
                          ? const Icon(Icons.check)
                          : null,
                      subtitle: client.debt > 0
                          ? Text(
                              '${'debt'.tr}: ${formatCurrency(client.debt, _profileController.user['mainCurrency'])}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: redColor,
                              ),
                            )
                          : null,
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
