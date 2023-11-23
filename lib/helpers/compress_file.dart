// 1. compress file and get Uint8List
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:photo_to_pdf/commons/constants.dart';

Future<List<File>> compressImageFile(
  List imageFiles,
  double compressValue,
) async {
  List<File> results = [];
  for (var element in imageFiles) {
    String filePath = element.absolute.path;
    final lastIndex = _getLastIndexOfFormat(filePath);
    if (lastIndex != -1) {
      final splitted = filePath.substring(0, lastIndex);
      final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
      var result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        format: _getCompressFormat(filePath, lastIndex),
        quality: int.parse((compressValue * 100).toStringAsFixed(0)),
      );
      if (result != null) {
        results.add(File(result.path));
      }
    } else {
      print('Không tìm thấy phần mở rộng trong đường dẫn: $filePath');
    }
  }
  print("results from compressImage ${results}");
  return results;
}

int _getLastIndexOfFormat(String filePath) {
  for (var format in IMAGE_FORMAT) {
    if (filePath.endsWith(format)) {
      return filePath.lastIndexOf(format);
    }
  }
  return -1;
}

CompressFormat _getCompressFormat(String filePath, int lastIndex) {
  CompressFormat format = CompressFormat.jpeg;
  switch (filePath.substring(lastIndex)) {
    case F_JPEG:
    case F_JPG:
      format = CompressFormat.jpeg;
    case F_PNG:
      format = CompressFormat.png;
    case F_HEIC:
      format = CompressFormat.heic;
    case F_WEBP:
      format = CompressFormat.webp;
    default:
      break;
  }
  return format;
}
