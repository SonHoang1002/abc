import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class ResizeImagePdf {
  static Future<File> resizeCover(File inputFile, int width, int height) async {
    Uint8List bytes = await inputFile.readAsBytes();
    img.Image image = img.decodeImage(Uint8List.fromList(bytes))!;
    img.Image resizedImage = img.copyResize(
      image,
      width: image.width,
      height: image.height,
      maintainAspect: true,
    ); 
    int offsetX = (resizedImage.width - width) ~/ 2;
    int offsetY = (resizedImage.height - height) ~/ 2;
    resizedImage = img.copyCrop(resizedImage,
        x: offsetX, y: offsetY, width: width, height: height);
    await inputFile
        .writeAsBytes(Uint8List.fromList(img.encodePng(resizedImage)));
    return inputFile;
  }
}
