import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/profile_controller.dart';
import '../../../utils/constants.dart';
import '../buttons/delete_save_button.dart';

class EditUserBottomSheet extends StatelessWidget {
  const EditUserBottomSheet({Key? key, required this.info}) : super(key: key);
  final String info;

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find();
    final TextEditingController infoController = TextEditingController();
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info[0].toUpperCase() + info.substring(1),
                    style: h5(
                      Theme.of(context).textTheme.bodyLarge!.color,
                    )),
                const SizedBox(height: 20),
                TextField(
                  controller: infoController,
                  maxLength: 25,
                  autofocus: true,
                  decoration: InputDecoration(
                    contentPadding: inputPadding,
                    hintText: info,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 20),
                DeleteSaveButton(
                  onDelete: () {
                    Navigator.pop(context);
                  },
                  onSave: () {
                    if (infoController.text.isNotEmpty) {
                      firestore
                          .collection('users')
                          .doc(profileController.user['id'])
                          .update({
                        info: infoController.text.trim(),
                      });
                      profileController.updateUserData();
                      Navigator.pop(context);
                    } else {
                      errorSnackbar('fill_required_fields'.tr);
                    }
                  },
                  text: 'save'.tr,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
