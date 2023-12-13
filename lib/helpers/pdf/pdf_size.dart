import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_to_pdf/helpers/pdf/create_pdf.dart';
import 'package:photo_to_pdf/models/project.dart';

Future<double> getPdfFileSize(
    Project project, BuildContext context, List<double> ratioTarget,
    {double? compressValue, List<double>? ratioWHImages}) async {
  Uint8List result = await createPdfFile(project, context, ratioTarget,
      ratioWHImages: ratioWHImages, compressValue: compressValue);
  File file = await createPdfFromUint8List(result);
  int fileSizeInBytes = await file.length();
  double fileSizeInKB = (fileSizeInBytes / 1024);
  return fileSizeInKB;
}

Future<File> createPdfFromUint8List(Uint8List data) async {
  final directory = await getTemporaryDirectory();
  final filePath = '${directory.path}/temp.pdf';
  final file = File(filePath);
  await file.writeAsBytes(data);
  return file;
}
