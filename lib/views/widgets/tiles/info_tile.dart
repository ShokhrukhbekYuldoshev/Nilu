import 'package:flutter/material.dart';

import '../../../utils/constants.dart';

class InfoTile extends StatelessWidget {
  final String title, trailing, route;
  const InfoTile({
    Key? key,
    required this.title,
    required this.trailing,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: const Color(0xFF206DE1),
        ),
        child: ListTile(
          title: Text(
            title,
            style: bodyText(whiteColor),
          ),
          trailing: Opacity(
            opacity: 0.7,
            child: Text(
              trailing,
              style: bodyText(whiteColor),
            ),
          ),
        ),
      ),
    );
  }
}
