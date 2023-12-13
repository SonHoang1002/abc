import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<dynamic> savePdf(Uint8List uint8list, {String? title}) async {
  final outputDirectory = await getExternalStorageDirectory();
  final fileExtension = "${title != "" ? title : "Untitled"}.pdf";
  final pdfFile = File('${outputDirectory?.path}/$fileExtension');
  final result = await pdfFile.writeAsBytes(uint8list);
  final message = ('Tệp PDF đã được lưu tại: ${pdfFile.path}');
  return {"data": result, "fileName": fileExtension, "message": message};
}
