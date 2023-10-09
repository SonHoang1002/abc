// 1. compress file and get Uint8List
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';


Future<List<File>> testCompressFile(
  List<File> files, double compressValue) async {
  List<File> results = [];
  for (var element in files) {
    final result = await FlutterImageCompress.compressWithFile(
      element.absolute.path,
      quality: int.parse(compressValue.toStringAsFixed(0)),
    );
    final compressedFile = await convertUint8ListToFile(result, element);
    results.add(compressedFile);
  }
  print("results: $results");
  return results;
}


Future<File> convertUint8ListToFile(Uint8List? data, File file) async {
  if (data != null) {
    final newFile = File(file.path);
    await newFile.writeAsBytes(data);
    return newFile;
  } else {
    return file;
  }
}
