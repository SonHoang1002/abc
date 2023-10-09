import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/models/project.dart';

class PreviewPdf extends StatefulWidget {
  final Project project;
  const PreviewPdf({super.key, required this.project});

  @override
  State<PreviewPdf> createState() => _PreviewPdfState();
}

class _PreviewPdfState extends State<PreviewPdf> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.pink,
        child: PdfPreview(
          allowPrinting: false,
          allowSharing: false,
          build: (context) => makePdf(),
        ),
      ),
    );
  }

  Future<Uint8List> makePdf() async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
        margin: const pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.SizedBox(),
                pw.Expanded(child: DottedBorder(child: pw.Container()))
              ]);
        }));
    return pdf.save();
  }
}

class DottedBorder extends pw.StatelessWidget {
  final pw.EdgeInsets padding;
  final pw.Widget child;
  final PdfColor color;
  final double strokeWidth;
  final List<double> dashPattern;
  final BorderType borderType;
  final pw.Radius radius;

  DottedBorder({
    required this.child,
    this.padding = const pw.EdgeInsets.all(2),
    this.color = PdfColors.black,
    this.strokeWidth = 1.0,
    this.borderType = BorderType.Rect,
    this.dashPattern = const [3, 1],
    this.radius = const pw.Radius.circular(0),
  });

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
        color: const PdfColor.fromInt(0xFF0000FF),
        child: pw.Stack(
          children: [
            pw.Positioned(
                top: 20,
                left: 30,
                child: pw.Container(
                    color: const PdfColor.fromInt(0xFF0000),
                    height: 300,
                    width: 400)),
            pw.Positioned(
                top: 50,
                left: 80,
                child: pw.Container(
                    color: const PdfColor.fromInt(0xFF0000),
                    height: 300,
                    width: 400)),
          ],
        ));
  }

  void _getCirclePath(PdfGraphics canvas, PdfPoint size) {
    double w = size.x;
    double h = size.y;
    double s = size.x > size.y ? size.y : size.x;

    canvas.drawRRect(
      w > s ? (w - s) / 2 : 0,
      h > s ? (h - s) / 2 : 0,
      s,
      s,
      s / 2,
      s / 2,
    );
  }

  void _getRRectPath(PdfGraphics canvas, PdfPoint size, double radius) {
    canvas.drawRRect(0, 0, size.x, size.y, radius, radius);
  }

  void _getRectPath(PdfGraphics canvas, PdfPoint size) {
    canvas.drawRect(0, 0, size.x, size.y);
  }

  void _getOvalPath(PdfGraphics canvas, PdfPoint size) {
    canvas.drawEllipse(size.x, size.y, 8, 8);
  }
}

/// The different supported BorderTypes
enum BorderType { Circle, RRect, Rect, Oval }
