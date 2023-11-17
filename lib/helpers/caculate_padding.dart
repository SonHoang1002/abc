import 'package:flutter/material.dart';
import 'package:photo_to_pdf/helpers/convert.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:pdf/widgets.dart' as pw;

EdgeInsets? caculatePadding(Project project, List<double> widthAndHeight,
    Unit? inputUnit, Unit? targetUnit) {
  if (inputUnit == null || targetUnit == null) {
    return null;
  }
  final convertVerticalPadding = convertUnit(
      inputUnit, targetUnit, project.paddingAttribute?.verticalPadding ?? 0);
  final convertHorizontalPadding = convertUnit(
      inputUnit, targetUnit, project.paddingAttribute?.horizontalPadding ?? 0);
  final verticalValue = 1 /
      2 *
      convertVerticalPadding *
      widthAndHeight[1] /
      project.paper!.height;
  return EdgeInsets.symmetric(
    vertical: verticalValue > 0 ? verticalValue : 0.0,
    horizontal: 1 /
        2 *
        convertHorizontalPadding *
        widthAndHeight[0] /
        project.paper!.width,
  );
}

pw.EdgeInsets? caculatePdfPadding(Project project, List<double> widthAndHeight,
    Unit? inputUnit, Unit? targetUnit) {
  if (inputUnit == null || targetUnit == null) {
    return null;
  }
  final convertVerticalPadding = convertUnit(
      inputUnit, targetUnit, project.paddingAttribute?.verticalPadding ?? 0);
  final convertHorizontalPadding = convertUnit(
      inputUnit, targetUnit, project.paddingAttribute?.horizontalPadding ?? 0);
  final verticalValue = 1 /
      2 *
      convertVerticalPadding *
      widthAndHeight[1] /
      project.paper!.height;

  return pw.EdgeInsets.symmetric(
    vertical: verticalValue > 0 ? verticalValue : 0.0,
    horizontal: 1 /
        2 *
        convertHorizontalPadding *
        widthAndHeight[0] /
        project.paper!.width,
  );
}
