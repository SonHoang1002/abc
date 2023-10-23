import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:photo_to_pdf/models/project.dart';

Future<List> savePdf(Uint8List uint8list, Project project) async {
  final outputDirectory = await getExternalStorageDirectory();
  final pdfFile = File(
      '${outputDirectory?.path}/${project.title != "" ? project.title : "Untitled"}.pdf');
  final result = await pdfFile.writeAsBytes(uint8list);
  final message = ('Tệp PDF đã được lưu tại: ${pdfFile.path}');
  return [result, message];
}
