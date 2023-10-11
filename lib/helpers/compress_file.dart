// 1. compress file and get Uint8List
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<List<File>> compressImageFile(
  List imageFiles,
  double compressValue,
) async {
  List<File> results = [];
  for (var element in imageFiles) {
    final filePath = element.absolute.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
    var result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: int.parse((compressValue * 100).toStringAsFixed(0)),
    );
    if (result != null) {
      results.add(File(result.path));
    }
  }
  return results;
}
// Future<List<File>> compressImageFile(
//   List<dynamic> imageFiles, double compressValue,
// ) async {
//   List<File> results = [];
//   for (var element in imageFiles) {
//     final result = await FlutterImageCompress.compressWithFile(
//       element.absolute.path,
//       quality: int.parse((compressValue * 100).toStringAsFixed(0)),
//     );
//     if (result != null) {
//       final file = await convertUint8ListToFile(result);
//       results.add(file);
//     }
//   }
//   return results;
// }
