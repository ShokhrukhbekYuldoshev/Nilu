import 'package:flutter/material.dart';
import 'package:nilu/utils/preferences.dart';

import '../../utils/constants.dart';

class SearchFilterIcon extends StatelessWidget {
  const SearchFilterIcon({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Preferences.getTheme() ? lightGrayColor : primaryUltraLightColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Preferences.getTheme() ? whiteColor : primaryColor,
        ),
      ),
    );
  }
}
