import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/caculate_padding.dart';
import 'package:photo_to_pdf/helpers/caculate_spacing.dart';
import 'package:photo_to_pdf/helpers/compress_file.dart';
import 'package:photo_to_pdf/helpers/convert.dart';
import 'package:photo_to_pdf/helpers/extract_list.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/helpers/render_boxfit.dart';
import 'package:printing/printing.dart';
import 'package:photo_to_pdf/helpers/pdf/save_pdf.dart';

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
                  await savePdf(result, title: project.title);
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
    pageOrientationValue = PORTRAIT;
  } else if (_project.paper != null &&
      _project.paper!.height < _project.paper!.width) {
    pageOrientationValue = LANDSCAPE;
  } else {
    pageOrientationValue = NATURAL;
  }

  PdfPageFormat? pdfPageFormat;
  if (project.paper?.title != null) {
    pdfPageFormat =
        PDF_PAGE_FORMAT[project.paper?.title]?[pageOrientationValue];
  }

  if (project.paper != null &&
      project.paper?.height != null &&
      project.paper?.width != null) {
    if (project.paper!.unit!.title == POINT.title) {
      pdfPageFormat = PdfPageFormat(project.paper!.width, project.paper!.height,
          marginAll: 2.0 * point);
    } else if (project.paper!.unit!.title == INCH.title) {
      pdfPageFormat = PdfPageFormat(
          project.paper!.width * inch, project.paper!.height * inch,
          marginAll: 2.0 * inch);
    } else if (project.paper!.unit!.title == CENTIMET.title) {
      pdfPageFormat = PdfPageFormat(
          project.paper!.width * cm, project.paper!.height * cm,
          marginAll: 2.0 * cm);
    } else {
      print("NONE");
    }
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
            child: _buildPdfPreview(context, _project, listExtract, index,
                [pdfPageFormat!.width, pdfPageFormat.height]));
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
    List layoutExtractList, int indexPage, List<double> widthAndHeight) {
  return pw.Container(
    color: convertColorToPdfColor(project.backgroundColor),
    alignment: convertAlignmentToPdfAlignment(
        project.alignmentAttribute?.alignmentMode),
    child: _buildCorePDFLayoutMedia(
        indexPage, project, layoutExtractList[indexPage], widthAndHeight),
  );
}

pw.Widget _buildCorePDFLayoutMedia(
  int indexPage,
  Project project,
  List<dynamic>? layoutExtractList,
  List<double> widthAndHeight,
) {
  if (project.useAvailableLayout != true &&
      project.placements != null &&
      project.placements!.isNotEmpty) {
    return pw.Container(
        child: pw.Stack(
      children: layoutExtractList!.map((e) {
        final index = layoutExtractList.indexOf(e);
        return pw.Positioned(
            top: _getPositionWithTop(index, project, widthAndHeight[1]),
            left: _getPositionWithLeft(index, project, widthAndHeight[0]),
            child: pw.Container(
              // margin: caculatePdfSpacing(project, widthAndHeight,
              //     project.spacingAttribute?.unit, project.paper?.unit),
              child: _buildImageWidget(
                project,
                layoutExtractList[index],
                height: _getRealHeight(index, project, widthAndHeight[1]),
                width: _getRealWidth(index, project, widthAndHeight[0]),
              ),
            ));
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
                  child: pw.Container(
                    margin: caculatePdfSpacing(project, widthAndHeight,
                        project.spacingAttribute?.unit, project.paper?.unit),
                    child: _buildImageWidget(
                      project,
                      imageData,
                    ),
                  ));
            }).toList()),
      ));
    }
    return pw.Container(
        padding: caculatePdfPadding(project, widthAndHeight,
            project.paddingAttribute?.unit, project.paper?.unit),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: columnWidgets,
        ));
  }
}

pw.Widget _buildImageWidget(Project project, dynamic imageData,
    {double? width, double? height}) {
  final fit = renderPdfWidgetImageBoxfit(project.resizeAttribute);
  if (imageData == null) {
    return pw.SizedBox();
  } else {
    return pw.Container(
        child: pw.Image(pw.MemoryImage(File(imageData.path).readAsBytesSync()),
            fit: fit, width: width, height: height));
  }
}

double _getRealHeight(int extractIndex, Project project, double pdfHeight) {
  final realHeight = pdfHeight * project.placements![extractIndex].ratioHeight;
  return realHeight;
}

double _getRealWidth(int extractIndex, Project project, double pdfWidth) {
  final realWidth = pdfWidth * project.placements![extractIndex].ratioWidth;
  return realWidth;
}

double _getPositionWithTop(
    int extractIndex, Project project, double pdfHeight) {
  final result = (project.placements![extractIndex].ratioOffset[1]) * pdfHeight;
  return result;
}

double _getPositionWithLeft(
    int extractIndex, Project project, double pdfWidth) {
  return (project.placements![extractIndex].ratioOffset[0]) * pdfWidth;
}
