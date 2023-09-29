import 'dart:io';

import 'package:image_picker/image_picker.dart';

Future<List<File>> pickImage(ImageSource src, bool isMultiMedia) async {
  List<XFile?> listXFile = [];
  if (isMultiMedia) {
    listXFile = await ImagePicker().pickMultiImage(imageQuality: 99);
  } else {
    XFile? result = await ImagePicker().pickImage(source: src);
    if (result != null) {
      listXFile.add(result);
    }
  }
  if (listXFile.isEmpty) {
    return [];
  } else {
    return listXFile.map((e) => File(e!.path)).toList();
  }
}
