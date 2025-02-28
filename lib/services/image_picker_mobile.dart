// This file is ONLY for Mobile (Android & iOS)
import 'dart:typed_data';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickImage(ImageSource source) async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: source);
  if (pickedFile == null) return null;

  final File file = File(pickedFile.path);
  return await file.readAsBytes();
}
