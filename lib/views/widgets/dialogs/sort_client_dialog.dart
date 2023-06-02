import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/client_controller.dart';

import '../../../utils/constants.dart';
import '../../../utils/preferences.dart';

class SortClientDialog extends StatefulWidget {
  const SortClientDialog({Key? key}) : super(key: key);

  @override
  State<SortClientDialog> createState() => _SortClientDialogState();
}

class _SortClientDialogState extends State<SortClientDialog> {
  final ClientController _clientController = Get.find();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'sort'.tr,
        style: h5(
          Theme.of(context).textTheme.bodyLarge!.color,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile(
            activeColor:
                Preferences.getTheme() ? primaryLightColor : primaryColor,
            contentPadding: const EdgeInsets.all(0),
            title: Text('name'.tr),
            value: 'name',
            groupValue: _clientController.sortCategory.value,
            onChanged: (value) {
              setState(() {
                _clientController.sort(value.toString());
                Navigator.pop(context);
              });
            },
          ),
          RadioListTile(
            activeColor:
                Preferences.getTheme() ? primaryLightColor : primaryColor,
            contentPadding: const EdgeInsets.all(0),
            title: Text('debt'.tr),
            value: 'debt',
            groupValue: _clientController.sortCategory.value,
            onChanged: (value) {
              setState(() {
                _clientController.sort(value.toString());
                Navigator.pop(context);
              });
            },
          ),
          RadioListTile(
            activeColor:
                Preferences.getTheme() ? primaryLightColor : primaryColor,
            contentPadding: const EdgeInsets.all(0),
            title: Text('date'.tr),
            value: 'date',
            groupValue: _clientController.sortCategory.value,
            onChanged: (value) {
              setState(() {
                _clientController.sort(value.toString());
                Navigator.pop(context);
              });
            },
          ),
        ],
      ),
    );
  }
}
