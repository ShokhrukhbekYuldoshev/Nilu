import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/cart_controller.dart';
import 'package:nilu/utils/constants.dart';

import '../buttons/delete_save_button.dart';

class CommentBottomSheet extends StatelessWidget {
  const CommentBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CartController _cartController = Get.find();
    final TextEditingController _commentController =
        TextEditingController(text: _cartController.comment);
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Comment',
                    style: h5(
                      Theme.of(context).textTheme.bodyText1!.color,
                    )),
                const SizedBox(height: 20),
                TextField(
                  controller: _commentController,
                  autofocus: true,
                  decoration: InputDecoration(
                    contentPadding: inputPadding,
                    hintText: 'Enter your comment',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DeleteSaveButton(
                  onDelete: () {
                    _cartController.clearComment();
                    Navigator.pop(context);
                  },
                  onSave: () {
                    _cartController.setComment(_commentController.text.trim());
                    Navigator.pop(context);
                  },
                  text: 'Save',
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
