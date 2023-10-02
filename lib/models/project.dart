import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';

class Project {
  int id;
  final String title;
  final List<dynamic> listMedia;
  final PaperAttribute? paper;

  /// 0: 1 vertical image
  ///
  /// 1: 2 vertical image
  ///
  /// 2: 3 grid image ( 1 - 2 )
  ///
  /// 3: 3 grid image ( 2 - 1 )
  ///
  final int layoutIndex;
  final Color backgroundColor;
  final PaddingAttribute? paddingAttribute;
  final SpacingAttribute? spacingAttribute;
  final ResizeAttribute? resizeAttribute;
  final double compression;

  Project(
      {required this.id,
      this.title = "Untitled",
      required this.listMedia,
      this.paper,
      this.layoutIndex = 0,
      this.backgroundColor = colorWhite,
      this.paddingAttribute,
      this.spacingAttribute,
      this.resizeAttribute,
      this.compression = 1.0});

  void getInfor() {
    final id = "id: ${this.id},";
    final title = "title: ${this.title},";
    final listMedia = "listMedia: ${this.listMedia},";
    final layoutIndex = "layoutIndex: ${this.layoutIndex},";
    final backgroundColor = "backgroundColor: ${this.backgroundColor},";
    final paddingAttribute = "paddingAttribute: ${this.paddingAttribute},";
    final spacingAttribute = "spacingAttribute: ${this.spacingAttribute},";
    final resizeAttribute = "resizeAttribute: ${this.resizeAttribute},";
    final compression = "compression: ${this.compression},";
    final paper = "paper: ${this.paper},";
    print(id +
        title +
        listMedia +
        layoutIndex +
        backgroundColor +
        paddingAttribute +
        spacingAttribute +
        resizeAttribute +
        compression +
        paper);
  }

  Project copyWith(
      {String? title,
      List<dynamic>? listMedia,
      PaperAttribute? paper,
      int? layoutIndex,
      Color? backgroundColor,
      PaddingAttribute? paddingAttribute,
      SpacingAttribute? spacingAttribute,
      ResizeAttribute? resizeAttribute,
      double? compression}) {
    return Project(
        id: id,
        title: title ?? this.title,
        listMedia: listMedia ?? this.listMedia,
        paper: paper ?? this.paper,
        layoutIndex: layoutIndex ?? this.layoutIndex,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        resizeAttribute: resizeAttribute ?? this.resizeAttribute,
        paddingAttribute: paddingAttribute ?? this.paddingAttribute,
        spacingAttribute: spacingAttribute ?? this.spacingAttribute,
        compression: compression ?? this.compression);
  }
}

class PaddingAttribute {
  final double verticalPadding;
  final double horizontalPadding;
  final Unit? unit;
  PaddingAttribute(
      {this.horizontalPadding = 0.0, this.verticalPadding = 0.0, this.unit});

  PaddingAttribute copyWith(
      {double? verticalPadding, double? horizontalPadding, Unit? unit}) {
    return PaddingAttribute(
        verticalPadding: verticalPadding ?? this.verticalPadding,
        horizontalPadding: horizontalPadding ?? this.horizontalPadding,
        unit: unit ?? this.unit);
  }
}

class SpacingAttribute {
  double verticalSpacing;
  double horizontalSpacing;
  final Unit? unit;
  SpacingAttribute(
      {this.horizontalSpacing = 0, this.verticalSpacing = 0, this.unit});

  SpacingAttribute copyWith(
      {double? verticalSpacing, double? horizontalSpacing, Unit? unit}) {
    return SpacingAttribute(
        verticalSpacing: verticalSpacing ?? this.verticalSpacing,
        horizontalSpacing: horizontalSpacing ?? this.horizontalSpacing,
        unit: unit ?? this.unit);
  }
}

class ResizeAttribute {
  final String title;
  final String mediaSrc;
  ResizeAttribute({this.title = "", this.mediaSrc = ''});
}

class AlignmentAttribute {
  final Alignment alignmentMode;
  final String title;
  final String mediaSrc;
  AlignmentAttribute(
      {this.alignmentMode = Alignment.center,
      this.title = "Center",
      this.mediaSrc = ""});
}

class PaperAttribute {
  final String title;
  final double width;
  final double height;
  final Unit? unit;
  PaperAttribute(
      {this.title = "", this.width = 0.0, this.height = 0.0, this.unit});
  PaperAttribute copyWith(
      {double? height, double? width, String? title, Unit? unit}) {
    return PaperAttribute(
        height: height ?? this.height,
        width: width ?? this.width,
        unit: unit ?? this.unit,
        title: title ?? this.title);
  }
}

class Unit {
  final String title;
  final String value;
  Unit({this.title = "", this.value = ""});
}

// {"title": "A3", "width": 29.7, "height": 42, "unit": CENTIMET},