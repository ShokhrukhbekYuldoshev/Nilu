import 'package:flutter/material.dart';

import '../../../utils/constants.dart';

class DrawerTile extends StatelessWidget {
  const DrawerTile({
    Key? key,
    required this.route,
    required this.title,
    required this.icon,
  }) : super(key: key);

  final String route;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/$route');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconGrayColor,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
