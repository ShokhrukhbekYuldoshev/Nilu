import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:nilu/utils/constants.dart';
import '../../../controllers/auth_controller.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key, required this.phone}) : super(key: key);
  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  int time = 60;
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    Timer.run(() {
      _authController.isLoading.value = false;
    });
    super.dispose();
  }

  void startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (time <= 0) {
        timer.cancel();
        return;
      }
      if (mounted) {
        setState(() {
          time--;
        });
      }
    });
  }

  final AuthController _authController = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textDarkColor,
      ),
      body: _authController.isLoading.value
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'verification'.tr,
                      style: const TextStyle(
                        fontSize: 24,
                        color: textDarkColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Image.asset(
                      "assets/images/otp.png",
                      height: 64,
                      width: 64,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'otp_description'.tr,
                      style: bodyText(
                          Theme.of(context).textTheme.bodyLarge!.color),
                    ),
                    Text(
                      formatNumberSync(widget.phone),
                      style: bodyText(
                          Theme.of(context).textTheme.bodyMedium!.color),
                    ),
                    const SizedBox(height: 48),
                    // Implement 4 input fields
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Pinput(
                        autofocus: true,
                        defaultPinTheme: PinTheme(
                          textStyle: const TextStyle(
                            fontSize: 24,
                            color: textDarkColor,
                            fontWeight: FontWeight.w600,
                          ),
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: primaryUltraLightColor,
                          ),
                        ),
                        length: 6,
                        onCompleted: (pin) {
                          _authController.verifyOTP(
                            pin,
                            _authController.verificationID,
                            context,
                          );
                        },
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (time <= 0) {
                          _authController.resendOTP(
                            context,
                          );
                          time = 60;
                        }
                      },
                      child: Text(
                        'resend_code'.tr + (time > 0 ? ' $time' : ''),
                        style: bodyText(primaryColor),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
