// 1. compress file and get Uint8List
import 'dart:io';
import 'package:photo_to_pdf/helpers/create_pdf.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';



Future<List<File>> compressImageFile(
  List<dynamic> imageFiles, double compressValue,
) async {
  List<File> results = [];
  for (var element in imageFiles) {
    final result = await FlutterImageCompress.compressWithFile(
      element.absolute.path,
      quality: int.parse((compressValue * 100).toStringAsFixed(0)),
    );
    if (result != null) {
      final file = await convertUint8ListToFile(result);
      results.add(file);
    }
  }
  return results;
}
