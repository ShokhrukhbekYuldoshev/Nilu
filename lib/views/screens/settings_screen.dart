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
import 'package:nilu/views/widgets/bottomsheets/currency_picker_bottom_sheet.dart';
import 'package:nilu/views/widgets/dialogs/double_action_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => isUploading ? false : true,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text('Settings'),
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
                          title: 'Logout',
                          content: 'Are you sure you want to logout?',
                          confirm: 'Logout',
                          cancel: 'Cancel',
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
                            padding: const EdgeInsets.only(left: 15.0, top: 15),
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Select Image Source'),
                                    content: SizedBox(
                                      height: 180,
                                      child: Column(
                                        children: [
                                          ListTile(
                                            leading:
                                                const Icon(Icons.collections),
                                            title: const Text('Gallery'),
                                            onTap: () async {
                                              setState(() {
                                                isUploading = true;
                                              });
                                              imageFile =
                                                  await pickImageFromGallery();
                                              await compressFile(imageFile)
                                                  .then((value) {
                                                setState(() {
                                                  imageFile = value;
                                                  Navigator.pop(context);
                                                });
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
                                            title: const Text('Camera'),
                                            onTap: () async {
                                              setState(() {
                                                isUploading = true;
                                              });
                                              imageFile =
                                                  await pickImageFromCamera();
                                              await compressFile(imageFile)
                                                  .then((value) {
                                                setState(() {
                                                  imageFile = value;
                                                  Navigator.pop(context);
                                                });
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
                                            title: const Text('Delete'),
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
                                        width: 92,
                                        height: 92,
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
                                            width: 92,
                                            height: 92,
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
                                            radius: 46,
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
                              builder: (_) => const EditUserBottomSheet(
                                info: 'name',
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Name',
                                style: bodyText(
                                  Theme.of(context).textTheme.bodyText2!.color,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _profileController.user['name'],
                                    style: bodyText(
                                      Theme.of(context)
                                          .textTheme
                                          .bodyText1!
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
                              builder: (_) => const EditUserBottomSheet(
                                info: 'business',
                              ),
                            );
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Business',
                                style: bodyText(Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .color),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _profileController.user['business'],
                                    style: bodyText(
                                      Theme.of(context)
                                          .textTheme
                                          .bodyText1!
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
                              'Phone',
                              style: bodyText(
                                  Theme.of(context).textTheme.bodyText2!.color),
                            ),
                            Text(
                              FlutterLibphonenumber().formatNumberSync(
                                _profileController.user['phone'],
                              ),
                              style: bodyText(
                                Theme.of(context).textTheme.bodyText1!.color,
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
                              'Main currency',
                              style: bodyText(
                                  Theme.of(context).textTheme.bodyText2!.color),
                            ),
                            Row(
                              children: [
                                Text(
                                  _profileController.user['mainCurrency'],
                                  style: bodyText(
                                    Theme.of(context)
                                        .textTheme
                                        .bodyText1!
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
                                'Secondary currency',
                                style: bodyText(Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .color),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _profileController
                                        .user['secondaryCurrency'],
                                    style: bodyText(Theme.of(context)
                                        .textTheme
                                        .bodyText1!
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
                              'Notifications',
                              style: bodyText(
                                  Theme.of(context).textTheme.bodyText2!.color),
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
                              'Dark mode',
                              style: bodyText(
                                Theme.of(context).textTheme.bodyText2!.color,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Language',
                              style: bodyText(
                                  Theme.of(context).textTheme.bodyText2!.color),
                            ),
                            Row(
                              children: [
                                Text(
                                  'English',
                                  style: bodyText(
                                    Theme.of(context)
                                        .textTheme
                                        .bodyText1!
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
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
