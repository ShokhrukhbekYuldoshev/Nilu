import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/profile_controller.dart';
import '../../../utils/constants.dart';
import '../../../utils/image.dart';
import '../../../utils/preferences.dart';
import '../../widgets/buttons/primary_button.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({Key? key}) : super(key: key);

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final ProfileController _profileController = Get.find();
  final TextEditingController _noteController = TextEditingController();

  File? imageFile;
  UploadTask? uploadTask;
  bool isUploading = false;

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
          backgroundColor:
              Preferences.getTheme() ? darkGrayColor : primaryUltraLightColor,
          elevation: 0,
          leading: isUploading
              ? Container()
              : IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
          title: Text(
            'new_client'.tr,
            style: TextStyle(
              color: Preferences.getTheme()
                  ? primaryUltraLightColor
                  : textDarkColor,
            ),
          ),
        ),
        body: isUploading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Center(
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
                                        leading: const Icon(Icons.collections),
                                        title: Text('gallery'.tr),
                                        onTap: () async {
                                          imageFile =
                                              await pickImageFromGallery()
                                                  .then((value) {
                                            setState(() {
                                              imageFile = value;
                                              Navigator.pop(context);
                                            });
                                            return null;
                                          });
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.camera),
                                        title: Text('camera'.tr),
                                        onTap: () async {
                                          imageFile =
                                              await pickImageFromCamera()
                                                  .then((value) {
                                            setState(() {
                                              imageFile = value;
                                              Navigator.pop(context);
                                            });
                                            return null;
                                          });
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.close),
                                        title: Text('delete'.tr),
                                        onTap: () {
                                          setState(() {
                                            imageFile = null;
                                            Navigator.pop(context);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          child: imageFile != null
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: gray200Color,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  width: 72,
                                  height: 72,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.file(
                                      imageFile!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : const CircleAvatar(
                                  radius: 36,
                                  backgroundColor: gray200Color,
                                  child: Icon(
                                    Icons.person,
                                    size: 44,
                                    color: primaryColor,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _nameController,
                        maxLength: 25,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          labelText: '${'name'.tr}*',
                          counterText: '',
                          labelStyle: bodyText(textPlaceholderColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 15,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          labelText: 'phone'.tr,
                          counterText: '',
                          labelStyle: bodyText(textPlaceholderColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _noteController,
                        maxLength: 50,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          labelText: 'note'.tr,
                          counterText: '',
                          labelStyle: bodyText(textPlaceholderColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 34),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              onPressed: () async {
                                try {
                                  if (_nameController.text.isEmpty) {
                                    errorSnackbar('fill_required_fields'.tr);
                                  } else {
                                    setState(() {
                                      isUploading = true;
                                    });

                                    String? url = '';
                                    if (imageFile != null) {
                                      url = await uploadFile(
                                          'clients', imageFile!);
                                    }

                                    firestore.collection('clients').add({
                                      'name': _nameController.text.trim(),
                                      'owner': _profileController.user['id'],
                                      'debt': 0.0,
                                      'phone': _phoneController.text.trim(),
                                      "image": url,
                                      "note": _noteController.text.trim(),
                                      'date': DateTime.now(),
                                    });

                                    setState(() {
                                      isUploading = false;
                                    });

                                    if (mounted) {
                                      Navigator.pop(context);
                                    }
                                    successSnackbar(
                                      'client_added'.tr,
                                    );
                                  }
                                } catch (e) {
                                  errorSnackbar('something_went_wrong'.tr);
                                  Navigator.pop(context);
                                }
                              },
                              text: 'save'.tr,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
