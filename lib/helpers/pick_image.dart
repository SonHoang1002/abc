import 'dart:io';

import 'package:image_picker/image_picker.dart';

Future<File?> pickImage(ImageSource src) async {
  XFile? result = await ImagePicker().pickImage(source: src);
  if (result != null) {
    return File(result.path);
  }
}
