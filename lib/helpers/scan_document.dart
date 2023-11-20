import 'package:cunning_document_scanner/cunning_document_scanner.dart';

Future<List<String>?> scanDocument() async {
  List<String>? imagesPath = await CunningDocumentScanner.getPictures(true);
  return imagesPath;
}
