// import 'dart:io';
// import 'dart:typed_data';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:photo_to_pdf/commons/colors.dart';
// import 'package:photo_to_pdf/commons/constants.dart';
// import 'package:photo_to_pdf/helpers/compress_file.dart';
// import 'package:photo_to_pdf/helpers/extract_list.dart';
// import 'package:photo_to_pdf/helpers/navigator_route.dart';
// import 'package:photo_to_pdf/helpers/random_number.dart';
// import 'package:photo_to_pdf/widgets/w_text_content.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:photo_to_pdf/models/project.dart';
// import 'package:photo_to_pdf/helpers/render_boxfit.dart';
// import 'package:printing/printing.dart';

// Future<String> savePdf(Uint8List uint8list, Project project) async {
//   final outputDirectory = await getExternalStorageDirectory();
//   final pdfFile = File(
//       '${outputDirectory?.path}/${project.title != "" ? project.title : "Untitled"}.pdf');
//   await pdfFile.writeAsBytes(uint8list);
//   String message = ('Tệp PDF đã được lưu tại: ${pdfFile.path}');
//   return message;
// }

// Future<File> convertUint8ListToFile(Uint8List uint8list) async {
//   final directory = await getTemporaryDirectory();
//   final filePath = '${directory.path}/${getRandomNumber()}.pdf';
//   final file = File(filePath);
//   await file.writeAsBytes(uint8list);
//   return file;
// }

// Future<double> getPdfFileSize(Project project, BuildContext context,
//     {double? compressValue}) async {
//   Uint8List result =
//       await createPdfFile(project, context, compressValue: compressValue);
//   final directory = await getTemporaryDirectory();
//   final filePath = '${directory.path}/temp.pdf';
//   final file = File(filePath);
//   await file.writeAsBytes(result);
//   int fileSizeInBytes = await file.length();
//   double fileSizeInMB = (fileSizeInBytes / 1024) / 1024;
//   return fileSizeInMB;
// }

// Future<void> createAndPreviewPdf(Project project, BuildContext context,
//     {double? compressValue}) async {
//   final result =
//       await createPdfFile(project, context, compressValue: compressValue);
//   // ignore: use_build_context_synchronously
//   await Navigator.of(context).push(
//     MaterialPageRoute(
//       builder: (context) => Scaffold(
//         appBar: AppBar(
//             centerTitle: true,
//             title: WTextContent(value: 'Preview PDF'),
//             actions: [
//               IconButton(
//                 icon: const Icon(FontAwesomeIcons.save),
//                 color: colorBlue,
//                 onPressed: () async {
//                   final message = await savePdf(result, project);
//                   // ignore: use_build_context_synchronously
//                   ScaffoldMessenger.of(context)
//                       .showSnackBar(SnackBar(content: Text(message)));
//                 },
//               ),
//             ],
//             leading: GestureDetector(
//               onTap: () {
//                 popNavigator(context);
//               },
//               child: const Icon(
//                 FontAwesomeIcons.chevronLeft,
//                 color: colorBlack,
//                 size: 23,
//               ),
//             )),
//         body: PdfPreview(
//           maxPageWidth: 700,
//           allowSharing: true,
//           allowPrinting: false,
//           padding: EdgeInsets.zero,
//           shouldRepaint: true,
//           pdfFileName: project.title,
//           pageFormats: const <String, PdfPageFormat>{
//             "A3": PdfPageFormat.a3,
//             'A4': PdfPageFormat.a4,
//             "B5": PdfPageFormat.a5,
//             "JIS B5": PdfPageFormat.roll57,
//             "Legal": PdfPageFormat.legal,
//             'Letter': PdfPageFormat.letter,
//             "Tabloid": PdfPageFormat.roll80,
//             "Custom": PdfPageFormat.undefined
//           },
//           onPageFormatChanged: (value) {},
//           build: (fomat) {
//             return result;
//           },
//           dpi: 1.0,
//         ),
//       ),
//     ),
//   );
// }

// Future<Uint8List> createPdfFile(Project project, BuildContext context,
//     {double? compressValue}) async {
//   final pdf = pw.Document();
//   Project _project = project;
//   if (compressValue != null) {
//     final compressImages =
//         await compressImageFile(project.listMedia, compressValue);
//     _project = project.copyWith(listMedia: compressImages);
//   }
//   print("createPdfFile ${_project.listMedia}");
//   List listExtract =
//       extractList(_checkNumberExtractList(_project), _project.listMedia);

//   if (_project.coverPhoto?.frontPhoto != null) {
//     pdf.addPage(pw.Page(build: (ctx) {
//       return pw.Container(
//           color: _convertColorToPdfColor(_project.backgroundColor),
//           child: pw.Image(
//               pw.MemoryImage(
//                   File(_project.coverPhoto?.frontPhoto.path).readAsBytesSync()),
//               fit: pw.BoxFit.cover));
//     }));
//   }
//   for (var element in listExtract) {
//     int index = listExtract.indexOf(element);
//     pdf.addPage(pw.Page(build: (ctx) {
//       return _buildPdfPreview(_project, listExtract, index, [3, 4]);
//     }));
//   }
//   if (_project.coverPhoto?.backPhoto != null) {
//     pdf.addPage(pw.Page(build: (ctx) {
//       return pw.Container(
//           child: pw.Center(
//               child: pw.Image(
//                   pw.MemoryImage(File(_project.coverPhoto?.backPhoto.path)
//                       .readAsBytesSync()),
//                   fit: pw.BoxFit.cover)));
//     }));
//   }
//   final result = await pdf.save();
//   return result;
// }

// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// pw.Widget _buildPdfPreview(Project project, List layoutExtractList,
//     int indexPage, List<double> ratioTarget) {
//   return pw.Container(
//     color: _convertColorToPdfColor(project.backgroundColor),
//     padding: pw.EdgeInsets.only(
//         top: (2 + (project.paddingAttribute?.verticalPadding ?? 0.0)) *
//             _getDrawBoardWithPreviewBoardHeight(ratioTarget),
//         left: (2 + (project.paddingAttribute?.horizontalPadding ?? 0.0)) *
//             _getDrawBoardWithPreviewBoardWidth(ratioTarget),
//         right: (2 + (project.paddingAttribute?.horizontalPadding ?? 0.0)) *
//             _getDrawBoardWithPreviewBoardWidth(ratioTarget),
//         bottom: (2 + (project.paddingAttribute?.verticalPadding ?? 0.0)) *
//             _getDrawBoardWithPreviewBoardHeight(ratioTarget)),
//     // alignment: project.alignmentAttribute?.alignmentMode,
//     child: _buildCorePDFLayoutMedia(
//         indexPage, project, layoutExtractList[indexPage], ratioTarget),
//   );
// }

// pw.Widget _buildCorePDFLayoutMedia(
//   int indexPage,
//   Project project,
//   List<dynamic>? layoutExtractList,
//   List<double> ratioTarget,
// ) {
//   final double spacingHorizontalValue =
//       ((project.spacingAttribute?.horizontalSpacing ?? 0.0)) * 3;
//   final double spacingVerticalValue =
//       ((project.spacingAttribute?.verticalSpacing ?? 0.0)) * 3;
//   if (project.useAvailableLayout != true &&
//       project.placements != null &&
//       project.placements!.isNotEmpty) {
//     return pw.Stack(
//       children: layoutExtractList!.map((e) {
//         final index = layoutExtractList.indexOf(e);
//         return pw.Positioned(
//           top: _getPositionWithTop(index, project, ratioTarget),
//           left: _getPositionWithLeft(index, project, ratioTarget),
//           child: _buildImageWidget(
//             project,
//             layoutExtractList[index],
//             height: _getRealHeight(index, project, ratioTarget),
//             width: _getRealWidth(index, project, ratioTarget),
//           ),
//         );
//       }).toList(),
//     );
//   } else {
//     if (project.layoutIndex == 0 && layoutExtractList != null) {
//       return _buildImageWidget(project, project.listMedia[indexPage]);
//     } else if (layoutExtractList != null && layoutExtractList.isNotEmpty) {
//       if (project.layoutIndex == 1) {
//         return pw.Column(
//           children: [
//             pw.Flexible(
//                 child: _buildImageWidget(
//               project,
//               layoutExtractList[0],
//               height: 150,
//               width: 150,
//             )),
//             _buildSpacer(
//               height: spacingVerticalValue,
//             ),
//             pw.Flexible(
//                 child: _buildImageWidget(
//               project,
//               layoutExtractList[1],
//               height: 150,
//               width: 150,
//             )),
//           ],
//         );
//       } else if (project.layoutIndex == 2) {
//         return pw.Flex(
//           direction: pw.Axis.vertical,
//           children: [
//             pw.Flexible(
//                 child: _buildImageWidget(
//               project,
//               layoutExtractList[0],
//               width: 150,
//             )),
//             _buildSpacer(height: spacingVerticalValue),
//             pw.Flexible(
//               child: pw.Flex(
//                 direction: pw.Axis.horizontal,
//                 mainAxisAlignment: pw.MainAxisAlignment.center,
//                 children: [
//                   pw.Flexible(
//                       child: _buildImageWidget(
//                     project,
//                     layoutExtractList[1],
//                   )),
//                   _buildSpacer(
//                     width: spacingHorizontalValue,
//                   ),
//                   pw.Flexible(
//                     child: _buildImageWidget(project, layoutExtractList[2]),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         );
//       } else {
//         return pw.Flex(
//           direction: pw.Axis.vertical,
//           children: [
//             pw.Flexible(
//               child: pw.Flex(
//                 direction: pw.Axis.horizontal,
//                 mainAxisAlignment: pw.MainAxisAlignment.center,
//                 children: [
//                   pw.Flexible(
//                       child: _buildImageWidget(project, layoutExtractList[0])),
//                   _buildSpacer(width: spacingHorizontalValue),
//                   pw.Flexible(
//                     child: _buildImageWidget(project, layoutExtractList[1]),
//                   ),
//                 ],
//               ),
//             ),
//             _buildSpacer(height: spacingVerticalValue),
//             pw.Flexible(
//                 child: _buildImageWidget(
//               project,
//               layoutExtractList[2],
//               width: 150,
//             )),
//           ],
//         );
//       }
//     } else {
//       return pw.SizedBox();
//     }
//   }
// }

// pw.Widget _buildImageWidget(Project project, dynamic imageData,
//     {double? width, double? height}) {
//   final fit = renderPdfWidgetImageBoxfit(project.resizeAttribute);
//   if (imageData == null) {
//     return pw.Container();
//   } else {
//     return pw.Image(pw.MemoryImage(File(imageData.path).readAsBytesSync()),
//         width: width, height: height, fit: fit);
//   }
// }

// int _checkNumberExtractList(Project project) {
//   if (project.useAvailableLayout) {
//     if (project.layoutIndex == 0) {
//       return 1;
//     } else if (project.layoutIndex == 1) {
//       return 2;
//     } else if ([2, 3].contains(project.layoutIndex)) {
//       return 3;
//     } else {
//       return 1;
//     }
//   } else {
//     return (project.placements?.length) ?? 0;
//   }
// }

// PdfColor _convertColorToPdfColor(Color color) {
//   final r = color.red / 255.0;
//   final g = color.green / 255.0;
//   final b = color.blue / 255.0;
//   return PdfColor(r, g, b);
// }

// double _getDrawBoardWithPreviewBoardHeight(List<dynamic> ratioTarget) {
//   return (ratioTarget[0] / LIST_RATIO_PLACEMENT_BOARD[0]) / 2;
// }

// double _getDrawBoardWithPreviewBoardWidth(List<dynamic> ratioTarget) {
//   return (ratioTarget[1] / LIST_RATIO_PLACEMENT_BOARD[1]) / 2;
// }

// double _getRealHeight(
//     int extractIndex, Project project, List<dynamic> ratioTarget) {
//   final realHeight = _getDrawBoardWithPreviewBoardHeight(ratioTarget) *
//       (project.placements![extractIndex].height);
//   return realHeight;
// }

// double _getRealWidth(
//     int extractIndex, Project project, List<dynamic> ratioTarget) {
//   final realWidth = _getDrawBoardWithPreviewBoardWidth(ratioTarget) *
//       (project.placements![extractIndex].width);
//   return realWidth;
// }

// double _getPositionWithTop(
//     int extractIndex, Project project, List<dynamic> ratioTarget) {
//   return (project.placements![extractIndex].offset.dy) *
//       _getDrawBoardWithPreviewBoardHeight(ratioTarget);
// }

// double _getPositionWithLeft(
//     int extractIndex, Project project, List<dynamic> ratioTarget) {
//   return (project.placements![extractIndex].offset.dx) *
//       _getDrawBoardWithPreviewBoardWidth(ratioTarget);
// }

// pw.Widget _buildSpacer({double? height, double? width}) {
//   return pw.Container(height: height, width: width);
// }