import 'package:flutter/material.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../../utils/constants.dart';
import '../../../utils/preferences.dart';

class DeleteSaveButton extends StatelessWidget {
  const DeleteSaveButton({
    Key? key,
    required this.onDelete,
    required this.onSave,
    required this.text,
  }) : super(key: key);

  final VoidCallback onDelete;
  final VoidCallback onSave;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Preferences.getTheme() ? mediumGrayColor : borderColor,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete,
                color: Color(
                  0xFFFF0000,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: PrimaryButton(
              text: text,
              onPressed: onSave,
            ),
          ),
        ],
      ),
    );
  }
}
