import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/models/project.dart';
///
/// convert [point], [inch] to cm
///
double convertUnitToCm(Unit unit, double value) {
  if (unit.title == POINT.title) {
    return 0.0352777778 * value;
  }
  if (unit.title == INCH.title) {
    return 2.54 * value;
  }
  return value;
}
