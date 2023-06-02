import 'package:flutter/material.dart';
import 'package:nilu/utils/preferences.dart';
import '../../../utils/constants.dart';

class SecondaryButton extends StatelessWidget {
  final Color color;
  final Color textColor;
  final String text;
  final VoidCallback onPressed;
  const SecondaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = primaryUltraLightColor,
    this.textColor = primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Preferences.getTheme() ? lightGrayColor : color,
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Preferences.getTheme() ? whiteColor : textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
