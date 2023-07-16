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
          '#ff6666', 'cancel'.tr, true, ScanMode.BARCODE);
      _codeController.text = barcodeScanRes;
    } on PlatformException {
      barcodeScanRes = 'something_went_wrong'.tr;
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
    final TextEditingController quantityController = TextEditingController(
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
                      color: Theme.of(context).textTheme.bodyLarge!.color),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
          title: Text(
            'edit_product'.tr,
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
                            labelText: '${'name'.tr}*',
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
                                  labelText: 'code'.tr,
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
                            labelText: 'category'.tr,
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
                            '${'price'.tr}:',
                            style: bodyText(
                              Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                          ),
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
                                        title: Text('currency'.tr),
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
                                              hasSecondaryCurrency()
                                                  ? RadioListTile(
                                                      activeColor: Preferences
                                                              .getTheme()
                                                          ? primaryLightColor
                                                          : primaryColor,
                                                      value: _profileController
                                                          .user[
                                                              'secondaryCurrency']
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
                                                              .user[
                                                          'secondaryCurrency']),
                                                    )
                                                  : Container(),
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
                            '${'total_stock'.tr}:',
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
                              controller: quantityController,
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
                                text: 'save'.tr,
                                onPressed: () async {
                                  try {
                                    if (_nameController.text.isEmpty) {
                                      errorSnackbar('product_name_required'.tr);
                                    } else if (_priceController.text.isEmpty) {
                                      errorSnackbar(
                                          'product_price_required'.tr);
                                    } else if (quantityController
                                        .text.isEmpty) {
                                      errorSnackbar(
                                          'product_quantity_required'.tr);
                                    } else if (double.parse(_priceController
                                            .text
                                            .replaceAll(',', '')) <
                                        0) {
                                      errorSnackbar('price_negative'.tr);
                                    } else if (int.parse(quantityController.text
                                            .replaceAll(',', '')) <
                                        0) {
                                      errorSnackbar('quantity_negative'.tr);
                                    } else {
                                      setState(() {
                                        isUploading = true;
                                      });

                                      double priceMain = double.parse(
                                          _priceController.text
                                              .replaceAll(',', ''));
                                      double priceSecondary;
                                      if (_payment ==
                                          _profileController
                                              .user['secondaryCurrency']) {
                                        priceSecondary = double.parse(
                                            _priceController.text
                                                .replaceAll(',', ''));
                                        priceMain = double.parse(
                                            (priceSecondary *
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
                                        priceMain,
                                        quantityController,
                                        _categoryController,
                                        url,
                                      );
                                      setState(() {
                                        isUploading = false;
                                      });
                                      if (mounted) {
                                        Navigator.pop(context);
                                      }
                                      successSnackbar('product_updated'.tr);
                                    }
                                  } catch (e) {
                                    errorSnackbar('something_went_wrong'.tr);
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
      ProfileController profileController,
      TextEditingController nameController,
      TextEditingController codeController,
      double price,
      TextEditingController quantityController,
      TextEditingController categoryController,
      String url) {
    firestore.collection('products').doc(widget.product.id).update({
      'owner': profileController.user['id'],
      'name': nameController.text.trim(),
      'code': codeController.text.trim(),
      'price': price,
      'quantity': int.parse(quantityController.text.trim().replaceAll(',', '')),
      'category': categoryController.text.trim(),
      "image": url,
    });
  }
}
