import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

Future<void> previewPdf(
    Project project, BuildContext context, List<double> ratioTarget,
    {double? compressValue, List<double>? ratioWHImages}) async {
  final bytes = await createPdfFile(project, context, ratioTarget,
      compressValue: compressValue, ratioWHImages: ratioWHImages);
  final directory = await getApplicationSupportDirectory();
  final path = directory.path;
  File file = File('$path/Output.pdf');
  await file.writeAsBytes(bytes, flush: true);
  OpenFile.open('$path/Output.pdf');
}

Future<Uint8List> createPdfFile(
    Project project, BuildContext context, List<double> ratioTarget,
    {double? compressValue, List<double>? ratioWHImages}) async {
  //Create a new PDF document
  final PdfDocument document = PdfDocument();
  document.pageSettings.size = PdfPageSize.a0;

  document.pages.add().graphics.drawString(
      'Hello World!', PdfStandardFont(PdfFontFamily.helvetica, 20),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: const Rect.fromLTWH(0, 0, 500, 50));
  //Read the image data from the weblink.

  Uint8List imageData =
      Uint8List.sublistView(await rootBundle.load('assets/images/abc.jpg'));
  document.pages
      .add()
      .graphics
      .drawImage(PdfBitmap(imageData), const Rect.fromLTWH(0, 0, 500, 1000));

  // Project _project = project;
  // String pageOrientationValue;
  // if (_project.paper != null &&
  //     _project.paper!.height > _project.paper!.width) {
  //   pageOrientationValue = PORTRAIT;
  // } else if (_project.paper != null &&
  //     _project.paper!.height < _project.paper!.width) {
  //   pageOrientationValue = LANDSCAPE;
  // } else {
  //   pageOrientationValue = NATURAL;
  // }

  List<int> bytes = await document.save();
  document.dispose();
  return Uint8List.fromList(bytes);
}

// orientation
// page format
// add page 
