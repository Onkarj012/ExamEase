import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

Future<Uint8List?> pickImage([dynamic _]) async { // Accepts an unused parameter
  if (!kIsWeb) return null;

  final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  uploadInput.accept = 'image/*';
  uploadInput.click();

  await uploadInput.onChange.first;
  final file = uploadInput.files?.first;
  if (file == null) return null;

  final reader = html.FileReader();
  reader.readAsArrayBuffer(file);
  await reader.onLoad.first;

  return reader.result as Uint8List?;
}
