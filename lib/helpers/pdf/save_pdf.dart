import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<List> savePdf(Uint8List uint8list,{String? title}) async {
  final outputDirectory = await getExternalStorageDirectory();
  final pdfFile = File(
      '${outputDirectory?.path}/${ title != "" ? title : "Untitled"}.pdf');
  final result = await pdfFile.writeAsBytes(uint8list);
  final message = ('Tệp PDF đã được lưu tại: ${pdfFile.path}');
  return [result, message];
}
