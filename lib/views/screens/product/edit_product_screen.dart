import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:nilu/controllers/product_controller.dart';
import 'package:nilu/controllers/profile_controller.dart';
import 'package:nilu/utils/constants.dart';
import 'package:nilu/utils/preferences.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../../models/product_model.dart';
import '../../../utils/image.dart';
import '../../widgets/bottomsheets/product_category_bottom_sheet.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({Key? key, required this.product})
      : super(
          key: key,
        );

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  @override
  void dispose() {
    _productController.setCategory('No category');
    super.dispose();
  }

  //* TextControllers
  late final TextEditingController _nameController =
      TextEditingController(text: widget.product.name);
  late final TextEditingController _codeController =
      TextEditingController(text: widget.product.code);
  late final TextEditingController _categoryController =
      TextEditingController(text: widget.product.category);
  late final TextEditingController _priceController = TextEditingController();

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

  final ProductController _productController = Get.find();

  File? imageFile;
  UploadTask? uploadTask;
  bool isUploading = false;

  Future<String> uploadFile(String folder, File file) async {
    final path = '$folder/${widget.product.id}.png';
    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);
    final snapshot = await uploadTask!.whenComplete(() => {});
    final url = await snapshot.ref.getDownloadURL();
    return url;
  }

  static final ProfileController _profileController = Get.find();
  String _payment = _profileController.user['mainCurrency'];
  @override
  Widget build(BuildContext context) {
    if (_payment == 'UZS') {
      _priceController.text = widget.product.price.toString();
    } else {
      _priceController.text = widget.product.price.toString();
    }
    final TextEditingController _quantityController = TextEditingController(
      text: widget.product.quantity.toString(),
    );
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
            'Edit Product',
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
                                        leading: const Icon(Icons.collections),
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
                                            widget.product.image = '';
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
                            borderRadius: BorderRadius.circular(
                              4,
                            ),
                            child: imageFile != null
                                ? Image.file(
                                    imageFile!,
                                    width: 86,
                                    height: 86,
                                    fit: BoxFit.cover,
                                  )
                                : widget.product.image != ''
                                    ? CachedNetworkImage(
                                        imageUrl: widget.product.image!,
                                        placeholder: (context, url) =>
                                            Container(
                                          padding: const EdgeInsets.all(10),
                                          child:
                                              const CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
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
                                        width: 86,
                                        height: 86,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 86,
                                        height: 86,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF80B2FF),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 36,
                                        ),
                                      ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
                            labelText: 'Category (optional)',
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
                          Text('Price:',
                              style: bodyText(Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .color)),
                          const Spacer(),
                          Container(
                            constraints: const BoxConstraints(
                              maxWidth: 200,
                            ),
                            width: 140,
                            height: 44,
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
                            constraints: const BoxConstraints(
                              maxWidth: 200,
                            ),
                            width: 140,
                            height: 44,
                            child: TextField(
                              inputFormatters: [ThousandsFormatter()],
                              controller: _quantityController,
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

                                      String url = widget.product.image!;
                                      if (imageFile != null) {
                                        url = await uploadFile(
                                          'products',
                                          imageFile!,
                                        );
                                      }
                                      updateProduct(
                                        _profileController,
                                        _nameController,
                                        _codeController,
                                        _priceMain,
                                        _quantityController,
                                        _categoryController,
                                        url,
                                      );
                                      setState(() {
                                        isUploading = false;
                                      });

                                      Navigator.pop(context);
                                      successSnackbar(
                                          'Product updated successfully');
                                    }
                                  } catch (e) {
                                    errorSnackbar('Something went wrong');
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

  void updateProduct(
      ProfileController _profileController,
      TextEditingController _nameController,
      TextEditingController _codeController,
      double _price,
      TextEditingController _quantityController,
      TextEditingController _categoryController,
      String url) {
    firestore.collection('products').doc(widget.product.id).update({
      'owner': _profileController.user['id'],
      'name': _nameController.text.trim(),
      'code': _codeController.text.trim(),
      'price': _price,
      'quantity':
          int.parse(_quantityController.text.trim().replaceAll(',', '')),
      'category': _categoryController.text.trim(),
      "image": url,
    });
  }
}
