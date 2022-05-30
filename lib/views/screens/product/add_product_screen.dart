import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../utils/constants.dart';
import '../../../utils/preferences.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../../utils/image.dart';
import '../../widgets/bottomsheets/product_category_bottom_sheet.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ProductController _productController = Get.find();
  static final ProfileController _profileController = Get.find();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  File? imageFile;
  UploadTask? uploadTask;
  bool isUploading = false;

  @override
  void dispose() {
    _productController.setCategory('No category');
    super.dispose();
  }

  // * SCAN
  Future<void> scanner() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      _codeController.text = barcodeScanRes;
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
  }

  Future<String> uploadFile(String folder, File file) async {
    final path = '$folder/${DateTime.now().millisecondsSinceEpoch}.png';
    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);
    final snapshot = await uploadTask!.whenComplete(() => {});
    final url = await snapshot.ref.getDownloadURL();
    return url;
  }

  String _payment = _profileController.user['mainCurrency'];
  @override
  Widget build(BuildContext context) {
    _categoryController.text = _productController.selectedCategory.value;
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
                  icon: Icon(Icons.close,
                      color: Theme.of(context).textTheme.bodyText1!.color),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
          title: Text(
            'New Product',
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
                                            imageFile =
                                                await pickImageFromGallery();

                                            await compressFile(imageFile)
                                                .then((value) {
                                              setState(() {
                                                imageFile = value;
                                                Navigator.pop(context);
                                              });
                                            });
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.camera),
                                          title: const Text('Camera'),
                                          onTap: () async {
                                            imageFile =
                                                await pickImageFromCamera();

                                            await compressFile(imageFile)
                                                .then((value) {
                                              setState(() {
                                                imageFile = value;
                                                Navigator.pop(context);
                                              });
                                            });
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.close),
                                          title: const Text('Delete'),
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: imageFile != null
                                  ? Image.file(
                                      imageFile!,
                                      width: 86,
                                      height: 86,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 86,
                                      height: 86,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF80B2FF),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                            )),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 44,
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            labelText: 'Name*',
                            labelStyle: bodyText(textPlaceholderColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: Preferences.getTheme()
                                    ? mediumGrayColor
                                    : borderColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 44,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _codeController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  labelText: 'Code',
                                  labelStyle: bodyText(textPlaceholderColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide(
                                      color: Preferences.getTheme()
                                          ? mediumGrayColor
                                          : borderColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                scanner();
                              },
                              icon: const Icon(
                                Icons.camera_alt,
                                size: 24,
                                color: iconGrayColor,
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 44,
                        child: TextField(
                          onTap: () {
                            showModalBottomSheet(
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              context: context,
                              builder: (context) => ProductCategoryBottomSheet(
                                refresh: () {
                                  _categoryController.text =
                                      _productController.selectedCategory.value;
                                },
                              ),
                            );
                          },
                          controller: _categoryController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            labelText: 'Category',
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                            labelStyle: bodyText(textPlaceholderColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: Preferences.getTheme()
                                    ? mediumGrayColor
                                    : borderColor,
                              ),
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Text(
                            'Price:',
                            style: bodyText(
                              Theme.of(context).textTheme.bodyText1!.color,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            constraints: const BoxConstraints(
                              maxWidth: 200,
                            ),
                            height: 44,
                            width: 140,
                            child: TextField(
                              inputFormatters: [
                                ThousandsFormatter(allowFraction: true)
                              ],
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                hintText: '0.00',
                                hintStyle: bodyText(textPlaceholderColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(
                                    color: Preferences.getTheme()
                                        ? mediumGrayColor
                                        : borderColor,
                                  ),
                                ),
                                suffix: GestureDetector(
                                  child: Text(_payment),
                                  onTap: () {
                                    showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          SimpleDialog(
                                        title: const Text('Currency'),
                                        children: [
                                          Column(
                                            children: [
                                              RadioListTile(
                                                  activeColor:
                                                      Preferences.getTheme()
                                                          ? primaryLightColor
                                                          : primaryColor,
                                                  value: _profileController
                                                      .user['mainCurrency']
                                                      .toString(),
                                                  groupValue: _payment,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _payment =
                                                          value.toString();
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                  title: Text(_profileController
                                                      .user['mainCurrency'])),
                                              RadioListTile(
                                                activeColor:
                                                    Preferences.getTheme()
                                                        ? primaryLightColor
                                                        : primaryColor,
                                                value: _profileController
                                                    .user['secondaryCurrency']
                                                    .toString(),
                                                groupValue: _payment,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _payment = value.toString();
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                title: Text(_profileController
                                                    .user['secondaryCurrency']),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                suffixStyle: h6(
                                  Preferences.getTheme()
                                      ? primaryLightColor
                                      : primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Text(
                            'Total stock:',
                            style: bodyText(warningColor),
                          ),
                          const Spacer(),
                          Container(
                            width: 140,
                            constraints: const BoxConstraints(
                              maxWidth: 200,
                            ),
                            height: 44,
                            child: TextField(
                              controller: _quantityController,
                              inputFormatters: [ThousandsFormatter()],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                hintText: '0',
                                hintStyle: bodyText(textPlaceholderColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(
                                    color: Preferences.getTheme()
                                        ? mediumGrayColor
                                        : borderColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 34),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: PrimaryButton(
                                text: 'Save product',
                                onPressed: () async {
                                  try {
                                    if (_nameController.text.isEmpty) {
                                      errorSnackbar('Product name is required');
                                    } else if (_priceController.text.isEmpty) {
                                      errorSnackbar(
                                          'Product price is required');
                                    } else if (_quantityController
                                        .text.isEmpty) {
                                      errorSnackbar(
                                          'Product quantity is required');
                                    } else if (double.parse(_priceController
                                            .text
                                            .replaceAll(',', '')) <
                                        0) {
                                      errorSnackbar(
                                          'Product price cannot be negative');
                                    } else if (int.parse(_quantityController
                                            .text
                                            .replaceAll(',', '')) <
                                        0) {
                                      errorSnackbar(
                                          'Product quantity cannot be negative');
                                    } else {
                                      setState(() {
                                        isUploading = true;
                                      });

                                      _productController.onInit();

                                      String? url = '';
                                      if (imageFile != null) {
                                        url = await uploadFile(
                                            'products', imageFile!);
                                      }

                                      double _priceMain = double.parse(
                                          _priceController.text
                                              .replaceAll(',', ''));
                                      double _priceSecondary;
                                      if (_payment ==
                                          _profileController
                                              .user['secondaryCurrency']) {
                                        _priceSecondary = double.parse(
                                            _priceController.text
                                                .replaceAll(',', ''));
                                        _priceMain = double.parse(
                                            (_priceSecondary *
                                                    Preferences
                                                        .getExchangeRate())
                                                .toStringAsFixed(0));
                                      }

                                      firestore.collection('products').add({
                                        'owner': _profileController.user['id'],
                                        'name': _nameController.text.trim(),
                                        'code': _codeController.text.trim(),
                                        'price': _priceMain,
                                        'quantity': int.parse(
                                          _quantityController.text
                                              .trim()
                                              .replaceAll(',', ''),
                                        ),
                                        'category':
                                            _categoryController.text.trim(),
                                        "image": url,
                                      });

                                      setState(() {
                                        isUploading = false;
                                      });
                                      Navigator.pop(context);

                                      successSnackbar(
                                          'Product added successfully');
                                    }
                                  } catch (e) {
                                    errorSnackbar(e.toString());
                                  }
                                },
                              ),
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
