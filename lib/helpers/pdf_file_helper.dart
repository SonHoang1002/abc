import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> savePdf(Widget child, String nameFile) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      build: (context) {
        return pw.Center(
            child: pw.Container(
                // color:pw.PdfColors.red)
                ));
      },
    ),
  );

  final outputDirectory = await getApplicationDocumentsDirectory();
  final pdfFile = File('${outputDirectory.path}/${nameFile}.pdf');
  final pdfBytes = await pdf.save();
  await pdfFile.writeAsBytes(pdfBytes);
  print('Tệp PDF đã được lưu tại: ${pdfFile.path}');
}

Future<void> listFilesInDocumentsDirectory() async {
  final documentsDirectory = await getApplicationDocumentsDirectory();
  final directory = Directory(documentsDirectory.path);

  if (await directory.exists()) {
    final files = directory.listSync();
    for (var file in files) {
      print('Tên tệp: ${file.path}');
    }
  } else {
    print('Thư mục không tồn tại.');
  }
}

class FileStorage {
  static Future<String> getExternalDocumentPath() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    Directory _directory = Directory("");
    if (Platform.isAndroid) {
      _directory = Directory("/storage/emulated/0/Download");
    } else {
      _directory = await getApplicationDocumentsDirectory();
    }

    final exPath = _directory.path;
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  static Future<String> get _localPath async {
    final String directory = await getExternalDocumentPath();
    return directory;
  }

  static Future<File> writeCounter(String bytes, String name) async {
    final path = await _localPath;
    File file = File('$path/$name');
    print("Save file");
    return file.writeAsString(bytes);
  }
}

Future<List<File?>?> loadListPdfFiles() async {
  List<File?> results = [];
  final documentsDirectory = await getApplicationDocumentsDirectory();
  final directory = Directory(documentsDirectory.path);

  if (await directory.exists()) {
    final pdfFilesList = directory.listSync().where((file) {
      return file.path.endsWith('.pdf');
    }).toList();
    results = pdfFilesList.cast<File>();
  }
  return results;
}
