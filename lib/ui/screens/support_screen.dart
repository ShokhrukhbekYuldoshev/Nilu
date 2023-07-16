import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nilu/utils/constants.dart';
import 'package:url_launcher/link.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('support'.tr),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 18.0),
          child: Column(
            children: [
              Center(
                child: SizedBox(
                  height: 124,
                  width: 124,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      color: primaryUltraLightColor,
                      child: Image.asset(
                        'assets/images/splash.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 200,
                child: Text(
                  'support_description'.tr,
                  textAlign: TextAlign.center,
                  style: bodyText(
                    Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: primaryUltraLightColor,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: SizedBox(
                        width: 38,
                        height: 38,
                        child: Image.asset(
                          'assets/images/telegram.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Telegram',
                          style: bodyText(textDarkColor),
                        ),
                        Link(
                          uri: Uri.parse('https://t.me/fighttothedeath'),
                          builder: (context, followLink) => GestureDetector(
                            onTap: followLink,
                            child: Text(
                              '@fighttothedeath',
                              style: bodyText(primaryColor),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: primaryUltraLightColor,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        color: primaryColor,
                        width: 38,
                        height: 38,
                        child: const Icon(Icons.email, color: whiteColor),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: bodyText(textDarkColor),
                        ),
                        Link(
                          uri: Uri.parse('mailto:shokhrukhbekdev@gmail.com'),
                          builder: (context, followLink) => GestureDetector(
                            onTap: followLink,
                            child: Text(
                              'shokhrukhbekdev@gmail.com',
                              style: bodyText(primaryColor),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
