import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

Future<List<File>> pickImage(ImageSource src, bool isMultiMedia) async {
  List<XFile?> listXFile = [];
  if (isMultiMedia) {
    listXFile = await ImagePicker().pickMultiImage(imageQuality: 99);
  } else {
    XFile? result =
        await ImagePicker().pickImage(source: src, imageQuality: 99);
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

Future<List<File>> pickFiles() async {
  List<File> listFiles = [];
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowMultiple: true,
    allowedExtensions: ['jpg', "png", "jpeg"],
  );
  if (result?.paths != null) {
    result?.paths.forEach((element) {
      listFiles.add(File(element!));
    });
  }

  return listFiles;
}
