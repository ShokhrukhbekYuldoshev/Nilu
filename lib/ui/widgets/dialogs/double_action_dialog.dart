import 'package:flutter/material.dart';
import 'package:nilu/ui/widgets/buttons/primary_button.dart';
import 'package:nilu/ui/widgets/buttons/secondary_button.dart';

import '../../../utils/constants.dart';

class DoubleActionDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirm;
  final String cancel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  const DoubleActionDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.confirm,
    required this.cancel,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                color: gray200Color,
                textColor: textDarkColor,
                onPressed: onCancel,
                text: cancel,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: PrimaryButton(
                color: redColor,
                onPressed: onConfirm,
                text: confirm,
              ),
            ),
          ],
        )
      ],
    );
  }
}
