import 'package:flutter/material.dart';
import 'package:nilu/ui/widgets/buttons/primary_button.dart';
import 'package:nilu/ui/widgets/buttons/secondary_button.dart';

import '../../../utils/constants.dart';

class TripleActionDialog extends StatelessWidget {
  final String title;
  final String content;
  final String middle;
  final String end;
  final String begin;
  final VoidCallback onMiddle;
  final VoidCallback onEnd;
  final VoidCallback onBegin;
  const TripleActionDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.middle,
    required this.begin,
    required this.onMiddle,
    required this.onBegin,
    required this.end,
    required this.onEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(20),
      title: Text(title),
      content: Text(content),
      actions: [
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                color: gray200Color,
                textColor: textDarkColor,
                onPressed: onBegin,
                text: begin,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: PrimaryButton(
                color: greenColor,
                onPressed: onMiddle,
                text: middle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: PrimaryButton(
                color: warningColor,
                onPressed: onEnd,
                text: end,
              ),
            ),
          ],
        )
      ],
    );
  }
}
