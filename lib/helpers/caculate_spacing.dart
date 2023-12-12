import 'package:flutter/material.dart';
import 'package:photo_to_pdf/helpers/convert.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:pdf/widgets.dart' as pw;

EdgeInsets? caculateSpacing(Project project, List<double> widthAndHeight,
    Unit? inputUnit, Unit? targetUnit) {
  if (inputUnit == null || targetUnit == null) {
    return null;
  }
  final convertVerticalSpacing = convertUnit(
      inputUnit, targetUnit, project.spacingAttribute?.verticalSpacing ?? 0);
  final convertHorizontalSpacing = convertUnit(
      inputUnit, targetUnit, project.spacingAttribute?.horizontalSpacing ?? 0);
  final verticalValue = 1 /
      2 *
      convertVerticalSpacing *
      (widthAndHeight[1] / project.paper!.height);
  final horizontalValue = 1 /
      2 *
      convertHorizontalSpacing *
      (widthAndHeight[0] / project.paper!.width);
  return EdgeInsets.symmetric(
    vertical: verticalValue,
    horizontal: horizontalValue,
  );
}

pw.EdgeInsets? caculatePdfSpacing(Project project, List<double> widthAndHeight,
    Unit? inputUnit, Unit? targetUnit) {
  if (inputUnit == null || targetUnit == null) {
    return null;
  }
  final convertVerticalSpacing = convertUnit(
      inputUnit, targetUnit, project.spacingAttribute?.verticalSpacing ?? 0);
  final convertHorizontalSpacing = convertUnit(
      inputUnit, targetUnit, project.spacingAttribute?.horizontalSpacing ?? 0);
  final verticalValue = 1 /
      2 *
      convertVerticalSpacing *
      (widthAndHeight[1] / project.paper!.height);
  final horizontalValue = 1 /
      2 *
      convertHorizontalSpacing *
      (widthAndHeight[0] / project.paper!.width);
  return pw.EdgeInsets.symmetric(
    vertical: verticalValue,
    horizontal: horizontalValue,
  );
}
