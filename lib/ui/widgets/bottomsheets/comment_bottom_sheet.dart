import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/cart_controller.dart';
import 'package:nilu/utils/constants.dart';

import '../buttons/delete_save_button.dart';

class CommentBottomSheet extends StatelessWidget {
  const CommentBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find();
    final TextEditingController commentController =
        TextEditingController(text: cartController.comment);
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('comment'.tr,
                    style: h5(
                      Theme.of(context).textTheme.bodyLarge!.color,
                    )),
                const SizedBox(height: 20),
                TextField(
                  controller: commentController,
                  autofocus: true,
                  decoration: InputDecoration(
                    contentPadding: inputPadding,
                    hintText: 'enter_comment'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DeleteSaveButton(
                  onDelete: () {
                    cartController.clearComment();
                    Navigator.pop(context);
                  },
                  onSave: () {
                    cartController.setComment(commentController.text.trim());
                    Navigator.pop(context);
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
