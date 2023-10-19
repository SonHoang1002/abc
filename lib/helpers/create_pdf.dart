import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/compress_file.dart';
import 'package:photo_to_pdf/helpers/extract_list.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/helpers/random_number.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/helpers/render_boxfit.dart';
import 'package:printing/printing.dart';

Future<String> savePdf(Uint8List uint8list, Project project) async {
  final outputDirectory = await getExternalStorageDirectory();
  final pdfFile = File(
      '${outputDirectory?.path}/${project.title != "" ? project.title : "Untitled"}.pdf');
  await pdfFile.writeAsBytes(uint8list);
  final message =('Tệp PDF đã được lưu tại: ${pdfFile.path}');
  return  message;
}

Future<File> convertUint8ListToFile(Uint8List uint8list) async {
  final directory = await getTemporaryDirectory();
  final filePath = '${directory.path}/${getRandomNumber()}.pdf';
  final file = File(filePath);
  await file.writeAsBytes(uint8list);
  return file;
}

Future<double> getPdfFileSize(
    Project project, BuildContext context, List<double> ratioTarget,
    {double? compressValue}) async {
  Uint8List result = await createPdfFile(project, context, ratioTarget,
      compressValue: compressValue);
  final directory = await getTemporaryDirectory();
  final filePath = '${directory.path}/temp.pdf';
  final file = File(filePath);
  await file.writeAsBytes(result);
  int fileSizeInBytes = await file.length();
  double fileSizeInKB = (fileSizeInBytes / 1024);
  return fileSizeInKB;
}

Future<void> createAndPreviewPdf(
    Project project, BuildContext context, List<double> ratioTarget,
    {double? compressValue}) async {
  final result = await createPdfFile(project, context, ratioTarget,
      compressValue: compressValue);
  // ignore: use_build_context_synchronously
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: WTextContent(value: 'Preview PDF'),
            actions: [
              IconButton(
                icon: const Icon(FontAwesomeIcons.save),
                color: colorBlue,
                onPressed: () async {
                  final message = await savePdf(result, project);
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(message)));
                },
              ),
            ],
            leading: GestureDetector(
              onTap: () {
                popNavigator(context);
              },
              child: Icon(
                FontAwesomeIcons.chevronLeft,
                size: 23,
                color: Theme.of(context).textTheme.displayLarge!.color,
              ),
            )),
        body: PdfPreview(
          allowSharing: true,
          allowPrinting: true,
          padding: EdgeInsets.zero,
          shouldRepaint: false,
          canChangeOrientation: false,
          pdfFileName: project.title,
          initialPageFormat: project.paper?.title != null
              ? (PDF_PAGE_FORMAT[project.paper?.title]?['natural'])
              : null,
          canChangePageFormat: false,
          canDebug: false,
          pageFormats: PDF_PAGE_FORMAT
              .map((key, value) => MapEntry(key, value['natural']!)),
          build: (fomat) {
            return result;
          },
        ),
      ),
    ),
  );
}

Future<Uint8List> createPdfFile(
    Project project, BuildContext context, List<double> ratioTarget,
    {double? compressValue}) async {
  final pdf = pw.Document();
  Project _project = project;
  String pageOrientationValue;
  if (_project.paper != null &&
      _project.paper!.height > _project.paper!.width) {
    pageOrientationValue = "portrait";
  } else if (_project.paper != null &&
      _project.paper!.height < _project.paper!.width) {
    pageOrientationValue = "landscape";
  } else {
    pageOrientationValue = "natural";
  }

  PdfPageFormat? pdfPageFormat;
  if (project.paper?.title != null) {
    pdfPageFormat =
        PDF_PAGE_FORMAT[project.paper?.title]?[pageOrientationValue];
  }
  // check height==width to render
  if (project.paper?.height != null && project.paper?.width != null) {
    // print(" project.paper? ${project.paper?.getInfor()}");
    
    // pdfPageFormat = PdfPageFormat(project.paper!.width, project.paper!.height);
  }
  if (compressValue != null) {
    final compressImages =
        await compressImageFile(project.listMedia, compressValue);
    _project = project.copyWith(listMedia: compressImages);
  }
  List listExtract = [];
  if (project.useAvailableLayout) {
    listExtract = extractList1(
        LIST_LAYOUT_SUGGESTION[_project.layoutIndex], _project.listMedia);
  } else {
    listExtract =
        extractList((_project.placements?.length) ?? 0, _project.listMedia);
  }

  // add front cover photo
  if (_project.coverPhoto?.frontPhoto != null) {
    File compressFrontPhoto;
    if (compressValue != null) {
      compressFrontPhoto = (await compressImageFile(
          [_project.coverPhoto?.frontPhoto], compressValue))[0];
    } else {
      compressFrontPhoto = _project.coverPhoto?.frontPhoto;
    }
    pdf.addPage(pw.Page(
      build: (ctx) {
        return pw.Container(
            color: convertColorToPdfColor(_project.backgroundColor),
            child: pw.Image(
                pw.MemoryImage(File(compressFrontPhoto.path).readAsBytesSync()),
                fit: pw.BoxFit.cover));
      },
      pageTheme: pw.PageTheme(
        pageFormat: pdfPageFormat,
        margin: pw.EdgeInsets.zero,
      ),
    ));
  }

  // add body page
  for (var element in listExtract) {
    int index = listExtract.indexOf(element);
    pdf.addPage(pw.Page(
      build: (ctx) {
        return pw.Center(
            child: _buildPdfPreview(
                context, _project, listExtract, index, ratioTarget));
      },
      pageTheme: pw.PageTheme(
        pageFormat: pdfPageFormat,
        margin: pw.EdgeInsets.zero,
      ),
    ));
  }
  // add back cover photo
  if (_project.coverPhoto?.backPhoto != null) {
    File compressBackPhoto;
    if (compressValue != null) {
      compressBackPhoto = (await compressImageFile(
          [_project.coverPhoto?.backPhoto], compressValue))[0];
    } else {
      compressBackPhoto = _project.coverPhoto?.backPhoto;
    }
    pdf.addPage(pw.Page(
      build: (ctx) {
        return pw.Container(
            child: pw.Center(
                child: pw.Image(
                    pw.MemoryImage(
                        File(compressBackPhoto.path).readAsBytesSync()),
                    fit: pw.BoxFit.cover)));
      },
      pageTheme: pw.PageTheme(
        pageFormat: pdfPageFormat,
        margin: pw.EdgeInsets.zero,
      ),
    ));
  }
  // return result
  final result = await pdf.save();
  return result;
}

pw.Widget _buildPdfPreview(BuildContext context, Project project,
    List layoutExtractList, int indexPage, List<double> ratioTarget) {
  return pw.Container(
    color: convertColorToPdfColor(project.backgroundColor),
    padding: pw.EdgeInsets.only(
      top: 2 * (5 + (project.paddingAttribute?.verticalPadding ?? 0.0)),
      //  * (ratioTarget[1]),
      left: 2 * (5 + (project.paddingAttribute?.horizontalPadding ?? 0.0)),
      // *(ratioTarget[0]),
      right: 2 * (5 + (project.paddingAttribute?.horizontalPadding ?? 0.0)),
      // *(ratioTarget[0]),
      bottom: 2 * (5 + (project.paddingAttribute?.verticalPadding ?? 0.0)),
      // *(ratioTarget[1]),
    ),
    // alignment: project.alignmentAttribute?.alignmentMode,
    child: _buildCorePDFLayoutMedia(
        indexPage, project, layoutExtractList[indexPage], ratioTarget),
  );
}

pw.Widget _buildCorePDFLayoutMedia(
  int indexPage,
  Project project,
  List<dynamic>? layoutExtractList,
  List<double> ratioTarget,
) {
  final double spacingHorizontalValue =
      ((project.spacingAttribute?.horizontalSpacing ?? 0.0)) * 3;
  final double spacingVerticalValue =
      ((project.spacingAttribute?.verticalSpacing ?? 0.0)) * 3;

  if (project.useAvailableLayout != true &&
      project.placements != null &&
      project.placements!.isNotEmpty) {
    return pw.Container(
        child: pw.Stack(
      children: layoutExtractList!.map((e) {
        final index = layoutExtractList.indexOf(e);
        return pw.Positioned(
          top: getPositionWithTop(index, project, ratioTarget),
          left: getPositionWithLeft(index, project, ratioTarget),
          child: _buildImageWidget(
            project,
            layoutExtractList[index],
            height: getRealHeight(index, project, ratioTarget),
            width: getRealWidth(index, project, ratioTarget),
          ),
        );
      }).toList(),
    ));
  } else { 
    final List<int> layoutSuggestion =
        LIST_LAYOUT_SUGGESTION[project.layoutIndex];
    List<pw.Widget> columnWidgets = [];
    for (int indexColumn = 0;
        indexColumn < layoutSuggestion.length;
        indexColumn++) {
      final rows =
          List.generate(layoutSuggestion[indexColumn], (index) => index);
      columnWidgets.add(pw.Flexible(
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: rows.map((childRow) {
              final indexRow = rows.indexOf(childRow);
              final imageData = layoutExtractList![indexColumn]![indexRow];
              return pw.Flexible(
                fit: pw.FlexFit.tight,
                child: _buildImageWidget(
                  project,
                  imageData,
                  width: double.infinity,
                  height: double.infinity,
                ),
              );
            }).toList()),
      ));
    }
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: columnWidgets,
    );
  }
}

pw.Widget _buildImageWidget(Project project, dynamic imageData,
    {double? width, double? height}) {
  final fit = renderPdfWidgetImageBoxfit(project.resizeAttribute);
  if (imageData == null) {
    return pw.SizedBox();
  } else {
    return pw.Container(
        margin: pw.EdgeInsets.only(
          top: 1.5 * (3 + (project.spacingAttribute?.verticalSpacing ?? 0.0)),
          left:
              1.5 * (3 + (project.spacingAttribute?.horizontalSpacing ?? 0.0)),
          right:
              1.5 * (3 + (project.spacingAttribute?.horizontalSpacing ?? 0.0)),
          bottom:
              1.5 * (3 + (project.spacingAttribute?.verticalSpacing ?? 0.0)),
        ),
        child: pw.Image(
          pw.MemoryImage(File(imageData.path).readAsBytesSync()),
          fit: fit,
          // width: 200,
          // height: 200
        )
        );
  }
}

PdfColor convertColorToPdfColor(Color color) {
  final r = color.red / 255.0;
  final g = color.green / 255.0;
  final b = color.blue / 255.0;
  return PdfColor(r, g, b);
}

double getDrawBoardWithPreviewBoardHeight(List<dynamic> ratioTarget) {
  return ratioTarget[0] / (LIST_RATIO_PLACEMENT_BOARD[0]);
}

double getDrawBoardWithPreviewBoardWidth(List<dynamic> ratioTarget) {
  return ratioTarget[1] / (LIST_RATIO_PLACEMENT_BOARD[1]);
}

double getRealHeight(
    int extractIndex, Project project, List<dynamic> ratioTarget) {
  final realHeight = getDrawBoardWithPreviewBoardHeight(ratioTarget) *
      (project.placements![extractIndex].height);
  return realHeight;
}

double getRealWidth(
    int extractIndex, Project project, List<dynamic> ratioTarget) {
  final realWidth = getDrawBoardWithPreviewBoardWidth(ratioTarget) *
      (project.placements![extractIndex].width);
  return realWidth;
}

double getPositionWithTop(
    int extractIndex, Project project, List<dynamic> ratioTarget) {
  return (project.placements![extractIndex].offset.dy) *
      getDrawBoardWithPreviewBoardHeight(ratioTarget);
}

double getPositionWithLeft(
    int extractIndex, Project project, List<dynamic> ratioTarget) {
  return (project.placements![extractIndex].offset.dx) *
      getDrawBoardWithPreviewBoardWidth(ratioTarget);
}


