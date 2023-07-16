import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    startTimer();
    super.initState();
  }

  int time = 0;

  void startTimer() {
    Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        setState(() {
          time = time + 15;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: time < 15
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('something_went_wrong'.tr),
                  TextButton(
                    child: Text(
                      'login'.tr,
                      style: h5(
                        Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    onPressed: () {
                      Get.toNamed('/login');
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
