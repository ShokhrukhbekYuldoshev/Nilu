import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:get/get.dart';
import 'package:nilu/controllers/auth_controller.dart';
import 'package:nilu/controllers/theme_controller.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/utils/preferences.dart';
import 'package:nilu/ui/widgets/bottomsheets/currency_picker_bottom_sheet.dart';
import 'package:nilu/ui/widgets/dialogs/double_action_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../models/themes_model.dart';
import '../../utils/constants.dart';
import '../../utils/image.dart';
import '../widgets/bottomsheets/edit_user_bottom_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? imageFile;
  UploadTask? uploadTask;
  bool isUploading = false;

  final ThemeController _themeController = Get.find();
  final ProfileController _profileController = Get.find();
  final AuthController _authController = Get.put(AuthController());

  Future<String> uploadFile(String folder, File file) async {
    final path = '$folder/${DateTime.now().millisecondsSinceEpoch}.png';
    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);
    final snapshot = await uploadTask!.whenComplete(() => {});
    final url = await snapshot.ref.getDownloadURL();
    return url;
  }

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => isUploading ? false : true,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('settings'.tr),
          leading: isUploading
              ? Container()
              : IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
          actions: [
            isUploading
                ? Container()
                : IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => DoubleActionDialog(
                          title: 'logout'.tr,
                          content: 'logout_confirmation'.tr,
                          confirm: 'logout'.tr,
                          cancel: 'cancel'.tr,
                          onConfirm: () {
                            setState(() {
                              Preferences.setTheme(false);
                              Preferences.setLoggedIn(false);
                              ThemeController().changeTheme(
                                  ThemeMode.light, Themes.lightTheme);
                              _authController.logout(context);
                            });
                          },
                          onCancel: () {
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
          ],
        ),
        body: isUploading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Obx(
                () => SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 62,
                            width: double.maxFinite,
                            color: primaryColor,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0, top: 20),
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text('select_image_source'.tr),
                                    content: SizedBox(
                                      height: 180,
                                      child: Column(
                                        children: [
                                          ListTile(
                                            leading:
                                                const Icon(Icons.collections),
                                            title: Text('gallery'.tr),
                                            onTap: () async {
                                              setState(() {
                                                isUploading = true;
                                              });
                                              imageFile =
                                                  await pickImageFromGallery()
                                                      .then((value) {
                                                setState(() {
                                                  imageFile = value;
                                                  Navigator.pop(context);
                                                });
                                                return null;
                                              });
                                              String? url = '';
                                              if (imageFile != null) {
                                                url = await uploadFile(
                                                  'users',
                                                  imageFile!,
                                                );
                                              }
                                              firestore
                                                  .collection('users')
                                                  .doc(_profileController
                                                      .user['id'])
                                                  .update({
                                                'image': url,
                                              });
                                              _profileController
                                                  .updateUserData();
                                              setState(() {
                                                isUploading = false;
                                              });
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.camera),
                                            title: Text('camera'.tr),
                                            onTap: () async {
                                              setState(() {
                                                isUploading = true;
                                              });
                                              imageFile =
                                                  await pickImageFromCamera()
                                                      .then((value) {
                                                setState(() {
                                                  imageFile = value;
                                                  Navigator.pop(context);
                                                });
                                                return null;
                                              });
                                              String? url = '';
                                              if (imageFile != null) {
                                                url = await uploadFile(
                                                  'users',
                                                  imageFile!,
                                                );
                                              }
                                              firestore
                                                  .collection('users')
                                                  .doc(_profileController
                                                      .user['id'])
                                                  .update({
                                                'image': url,
                                              });
                                              _profileController
                                                  .updateUserData();
                                              setState(() {
                                                isUploading = false;
                                              });
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.close),
                                            title: Text('delete'.tr),
                                            onTap: () {
                                              setState(() {
                                                isUploading = true;
                                                imageFile = null;
                                                firestore
                                                    .collection('users')
                                                    .doc(_profileController
                                                        .user['id'])
                                                    .update({
                                                  'image': '',
                                                });
                                                _profileController
                                                    .updateUserData();
                                                Navigator.pop(context);
                                                isUploading = false;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border:
                                      Border.all(color: whiteColor, width: 1),
                                ),
                                child: imageFile != null
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: gray200Color,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        width: 80,
                                        height: 80,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: Image.file(
                                            imageFile!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : _profileController.user['image'] != ''
                                        ? Container(
                                            decoration: BoxDecoration(
                                              color: gray200Color,
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                            width: 80,
                                            height: 80,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: CachedNetworkImage(
                                                imageUrl: _profileController
                                                    .user['image'],
                                                placeholder: (context, url) =>
                                                    const CircularProgressIndicator(),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : const CircleAvatar(
                                            radius: 40,
                                            backgroundColor: gray100Color,
                                            child: Icon(
                                              Icons.person,
                                              color: iconGrayColor,
                                              size: 40,
                                            ),
                                          ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => EditUserBottomSheet(
                                info: 'name'.tr,
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'name'.tr,
                                style: bodyText(
                                  Theme.of(context).textTheme.bodyMedium!.color,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _profileController.user['name'],
                                    style: bodyText(
                                      Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color,
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: gray400Color,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(
                        height: 0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => EditUserBottomSheet(
                                info: 'business_name'.tr,
                              ),
                            );
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'business_name'.tr,
                                style: bodyText(Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _profileController.user['business'],
                                    style: bodyText(
                                      Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color,
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: gray400Color,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(
                        height: 0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'phone'.tr,
                              style: bodyText(Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color),
                            ),
                            Text(
                              formatNumberSync(
                                _profileController.user['phone'],
                              ),
                              style: bodyText(
                                Theme.of(context).textTheme.bodyLarge!.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 12,
                        child: Container(
                          color: Preferences.getTheme() == false
                              ? const Color(0xFFF2F2F2)
                              : darkGrayColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'main_currency'.tr,
                              style: bodyText(Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color),
                            ),
                            Row(
                              children: [
                                Text(
                                  _profileController.user['mainCurrency'],
                                  style: bodyText(
                                    Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                const Icon(
                                  Icons.unfold_more,
                                  size: 20,
                                  color: gray400Color,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                              builder: (_) => const CurrencyPickerBottomSheet(
                                isMainCurrency: false,
                              ),
                            ).then(
                                (value) => _profileController.updateUserData());
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'secondary_currency'.tr,
                                style: bodyText(Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _profileController
                                        .user['secondaryCurrency'],
                                    style: bodyText(Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color),
                                  ),
                                  const SizedBox(width: 18),
                                  const Icon(
                                    Icons.unfold_more,
                                    size: 20,
                                    color: gray400Color,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                        child: Container(
                          color: Preferences.getTheme() == false
                              ? const Color(0xFFF2F2F2)
                              : darkGrayColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'notifications'.tr,
                              style: bodyText(Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color),
                            ),
                            Switch(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                activeColor: primaryLightColor,
                                value: Preferences.getNotification(),
                                onChanged: (value) {
                                  setState(() {
                                    Preferences.setNotification(value);
                                  });
                                }),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'dark_mode'.tr,
                              style: bodyText(
                                Theme.of(context).textTheme.bodyMedium!.color,
                              ),
                            ),
                            Switch(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              activeColor: primaryLightColor,
                              value: Preferences.getTheme(),
                              onChanged: (value) {
                                setState(
                                  () {
                                    if (value == true) {
                                      _themeController.changeTheme(
                                          ThemeMode.dark, Themes.darkTheme);
                                    } else {
                                      _themeController.changeTheme(
                                          ThemeMode.light, Themes.lightTheme);
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => SimpleDialog(
                                title: Text(
                                  'select_language'.tr,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                children: [
                                  SimpleDialogOption(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    onPressed: () {
                                      Preferences.setLanguage('english');
                                      Get.updateLocale(
                                        const Locale('en', 'US'),
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'English',
                                      style: bodyText(
                                        Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color,
                                      ),
                                    ),
                                  ),
                                  SimpleDialogOption(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    onPressed: () {
                                      Preferences.setLanguage('spanish');
                                      Get.updateLocale(
                                        const Locale('es', 'ES'),
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Español',
                                      style: bodyText(
                                        Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color,
                                      ),
                                    ),
                                  ),
                                  SimpleDialogOption(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    onPressed: () {
                                      Preferences.setLanguage('russian');
                                      Get.updateLocale(
                                        const Locale('ru', 'RU'),
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Русский',
                                      style: bodyText(
                                        Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color,
                                      ),
                                    ),
                                  ),
                                  SimpleDialogOption(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    onPressed: () {
                                      Preferences.setLanguage('uzbek');
                                      Get.updateLocale(
                                        const Locale('uz', 'UZ'),
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "O'zbek",
                                      style: bodyText(
                                        Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'language'.tr,
                                style: bodyText(Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${Preferences.getLanguage()}'.tr,
                                    style: bodyText(
                                      Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color,
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  const Icon(
                                    Icons.unfold_more,
                                    size: 20,
                                    color: gray400Color,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${_packageInfo.appName} for ${Platform.operatingSystem} v${_packageInfo.version}',
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
