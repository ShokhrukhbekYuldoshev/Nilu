import 'package:flutter/material.dart';
import 'package:nilu/utils/preferences.dart';

import '../../utils/constants.dart';

class ScreensCard extends StatelessWidget {
  const ScreensCard({
    Key? key,
    required this.child,
    required this.backgroundColor,
    required this.title,
    required this.route,
  }) : super(key: key);

  final Widget child;
  final Color backgroundColor;
  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Preferences.getTheme() == false
                ? whiteColor
                : const Color.fromARGB(77, 81, 81, 81),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.only(top: 26, bottom: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: child,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: h6(
                  Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
