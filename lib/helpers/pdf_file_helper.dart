import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:photo_to_pdf/models/project.dart';

Future<void> savePdf(Widget child, Project project) async {
  final pdf = pw.Document();

  final images = project.listMedia.map((e) {
    return pw.MemoryImage(File(e.path).readAsBytesSync());
  }).toList();

  pdf.addPage(
    pw.Page(
      build: (context) {
        return pw.Stack(
            children: images.map((e) {
          return pw.Positioned(
              top: (project.placements?[0].offset.dy ?? 10) *
                  Random().nextInt(100),
              left: (project.placements?[0].offset.dx ?? 10) *
                  Random().nextInt(100),
              child: pw.Image(e));
        }).toList());
      },
    ),
  );
  final outputDirectory = await getExternalStorageDirectory();
  final pdfFile = File(
      '${outputDirectory?.path}/${project.title != "" ? project.title : "Untitled"}.pdf');
  final pdfBytes = await pdf.save();
  await pdfFile.writeAsBytes(pdfBytes);
  print('Tệp PDF đã được lưu tại: ${pdfFile.path}');
}

Future<void> loadPdfFiles() async {
  final documentsDirectory = await getApplicationDocumentsDirectory();
  final directory = Directory(documentsDirectory.path);
  if (await directory.exists()) {
    final pdfFilesList = directory.listSync().where((file) {
      return file.path.endsWith('.pdf');
    }).toList();

    // pdfFiles.forEach((element) async {
    //   print('pdfFiles.length ${await element.length()/2024 } MB');
    // });
  }
}
