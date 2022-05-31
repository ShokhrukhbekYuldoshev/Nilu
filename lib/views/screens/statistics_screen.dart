import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('statistics'.tr),
        elevation: 0,
      ),
      body: const Center(
        child: Text('Coming soon'),
      ),
    );
  }
}
