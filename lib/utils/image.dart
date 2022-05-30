import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

final _picker = ImagePicker();

Future<File?> pickImageFromGallery() async {
  File? imageFile;
  final pickedFile = await _picker.pickImage(
    source: ImageSource.gallery,
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
  );
  if (pickedFile != null) {
    imageFile = File(pickedFile.path);
  }
  return imageFile;
}

Future<File?> compressFile(File? file) async {
  if (file == null) {
    return null;
  }
  final newPath = p.join(
    (await getTemporaryDirectory()).path,
    '${DateTime.now()}.jpg',
  );
  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    newPath,
    quality: 20,
  );

  return result;
}
