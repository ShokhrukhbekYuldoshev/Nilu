import 'dart:io';
import 'package:image_picker/image_picker.dart';

final _picker = ImagePicker();

Future<File?> pickImageFromGallery() async {
  File? imageFile;
  final pickedFile = await _picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 30,
  );
  if (pickedFile != null) {
    imageFile = File(pickedFile.path);
  }
  return imageFile;
}

Future<File?> pickImageFromCamera() async {
  File? imageFile;
  final pickedFile = await _picker.pickImage(
    source: ImageSource.camera,
    imageQuality: 30,
  );
  if (pickedFile != null) {
    imageFile = File(pickedFile.path);
  }
  return imageFile;
}
