// import 'dart:io';

// import 'package:flutter/services.dart';
// import 'package:flutter/material.dart';
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:photo_to_pdf/commons/constants.dart';
// import 'package:photo_to_pdf/helpers/compress_file.dart';
// import 'package:photo_to_pdf/helpers/convert.dart';
// import 'package:photo_to_pdf/helpers/resize_image.dart';
// import 'package:photo_to_pdf/models/project.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';

// Future<void> previewPdf1(
//     Project project, BuildContext context, List<double> ratioTarget,
//     {double? compressValue, List<double>? ratioWHImages}) async {
//   final bytes = await createPdfFile1(project, context, ratioTarget,
//       compressValue: compressValue, ratioWHImages: ratioWHImages);
//   final directory = await getApplicationSupportDirectory();
//   final path = directory.path;
//   File file = File('$path/Output.pdf');
//   await file.writeAsBytes(bytes, flush: true);
//   OpenFile.open('$path/Output.pdf');
// }

// Future<Uint8List> createPdfFile1(
//     Project project, BuildContext context, List<double> ratioTarget,
//     {double? compressValue, List<double>? ratioWHImages}) async {
//   //Create a new PDF document
//   PdfDocument document = PdfDocument();
//   Project _project = project;
//   PdfPageOrientation pdfPageOrientation;

//   Unit? unit = _project.paper?.unit;
//   double? valueUnit;

//   if (unit?.title == POINT.title) {
//     valueUnit = point;
//   } else if (unit?.title == INCH.title) {
//     valueUnit = inch;
//   } else if (unit?.title == CENTIMET.title) {
//     valueUnit = cm;
//   }
//   // add front image
//   if (_project.coverPhoto?.frontPhoto != null) {
//     File compressFrontPhoto;
//     PdfSection frontSection = document.sections!.add();
//     frontSection.pageSettings.setMargins(0);
//     if (compressValue != null) {
//       compressFrontPhoto = (await compressImageFile(
//           [_project.coverPhoto?.frontPhoto], compressValue))[0];
//     } else {
//       compressFrontPhoto = _project.coverPhoto?.frontPhoto;
//     }
//     var imageBitmap = PdfBitmap(compressFrontPhoto.readAsBytesSync());
//     if (_project.paper?.title == "None") {
//       double ratio = imageBitmap.width / imageBitmap.height;
//       double widthPdf = _getPdfPageSize(project).width;
//       double heightPdf = widthPdf / ratio;
//       frontSection.pageSettings.size = Size(widthPdf, heightPdf);
//       frontSection.pages
//           .add()
//           .graphics
//           .drawImage(imageBitmap, Rect.fromLTWH(0, 0, widthPdf, heightPdf));
//     } else {
//       final pdfSize = _getPdfPageSize(project);
//       imageBitmap = PdfBitmap((await ResizeImagePdf.resizeCover(
//               compressFrontPhoto,
//               pdfSize.width.floor(),
//               pdfSize.height.floor()))
//           .readAsBytesSync());
//       frontSection.pageSettings.size = Size(pdfSize.width, pdfSize.height);
//       frontSection.pages.add().graphics.drawImage(
//           imageBitmap, Rect.fromLTWH(0, 0, pdfSize.width, pdfSize.height));
//     }
//   }

//   final pdfSize = _getPdfPageSize(project);
//   //  document.pageSettings.size = PdfPageSize.a0;
//   PdfPage page = document.pages.add();
//   Uint8List imageData = Uint8List.sublistView(
//       await rootBundle.load("${PATH_PREFIX_IMAGE}abc.jpg"));
//   page.graphics.drawImage(PdfBitmap(imageData),   Rect.fromLTWH(0, 0, pdfSize.width, pdfSize.height));

//   // add body images
//   if (_project.coverPhoto?.backPhoto != null) {
//     File compressBackPhoto;
//     PdfSection backSection = document.sections!.add();
//     backSection.pageSettings.setMargins(0);
//     if (compressValue != null) {
//       compressBackPhoto = (await compressImageFile(
//           [_project.coverPhoto?.backPhoto], compressValue))[0];
//     } else {
//       compressBackPhoto = _project.coverPhoto?.backPhoto;
//     }
//     var imageBitmap = PdfBitmap(compressBackPhoto.readAsBytesSync());
//     if (_project.paper?.title == "None") {
//       double ratio = imageBitmap.width / imageBitmap.height;
//       double widthPdf = _getPdfPageSize(project).width;
//       double heightPdf = widthPdf / ratio;
//       backSection.pageSettings.size = Size(widthPdf, heightPdf);
//       backSection.pages
//           .add()
//           .graphics
//           .drawImage(imageBitmap, Rect.fromLTWH(0, 0, widthPdf, heightPdf));
//     } else {
//       final pdfSize = _getPdfPageSize(project);
//       imageBitmap = PdfBitmap(compressBackPhoto.readAsBytesSync());
//       backSection.pageSettings.size = Size(pdfSize.width, pdfSize.height);
//       backSection.pages.add().graphics.drawImage(
//           imageBitmap, Rect.fromLTWH(0, 0, pdfSize.width, pdfSize.height));
//     }
//   }

//   List<int> bytes = await document.save();
//   return Uint8List.fromList(bytes);
// }

// // orientation
// // page format
// // add page
// Size _getPdfPageSize(Project project) {
//   final paperHeight =
//       convertUnit(project.paper?.unit, POINT, project.paper!.height);
//   final paperWidth =
//       convertUnit(project.paper?.unit, POINT, project.paper!.width);

//   return Size(paperWidth, paperHeight);
// }
