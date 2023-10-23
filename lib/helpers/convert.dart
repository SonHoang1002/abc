import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/random_number.dart';
import 'package:photo_to_pdf/models/project.dart';

double pixelToRatio(double child, double parent) {
  return child / parent;
}

double ratioToPixel(double ratio, double parent) {
  return ratio * parent;
}

/// [Input] is KB , [Output] is KB or MB
String convertByteUnit(double input) {
  final kToM = input / 1024;
  if (kToM > 1) {
    return "${kToM.toStringAsFixed(2)} MB";
  } else {
    return "${input.toStringAsFixed(2)} KB";
  }
}

///
/// convert [point], [inch] to cm
///
double convertUnit(Unit inputUnit, Unit targetUnit, double value) {
  const pointToCm = 0.0352777778;
  const inchToCm = 2.54;
  const pointToInch = pointToCm / inchToCm;
  var result = value;
  // inch
  if (inputUnit.title == INCH.title) {
    if (targetUnit.title == POINT.title) {
      result = value * (1 / pointToInch);
    } else if (targetUnit.title == CENTIMET.title) {
      result = value * inchToCm;
    }
  }
  // point
  if (inputUnit.title == POINT.title) {
    if (targetUnit.title == INCH.title) {
      result = value * pointToInch;
    } else if (targetUnit.title == CENTIMET.title) {
      result = value * pointToCm;
    }
  }
  // cm
  if (inputUnit.title == CENTIMET.title) {
    if (targetUnit.title == INCH.title) {
      result = value * (1 / inchToCm);
    } else if (targetUnit.title == POINT.title) {
      result = value * (1 / pointToCm);
    }
  }
  return result;
}

Future<File> convertUint8ListToFilePDF(Uint8List uint8list) async {
  final directory = await getTemporaryDirectory();
  final filePath = '${directory.path}/${getRandomNumber()}.pdf';
  final file = File(filePath);
  await file.writeAsBytes(uint8list);
  return file;
}

PdfColor convertColorToPdfColor(Color color) {
  final r = color.red / 255.0;
  final g = color.green / 255.0;
  final b = color.blue / 255.0;
  return PdfColor(r, g, b);
}
