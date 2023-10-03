import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/models/cover_photo.dart';
import 'package:photo_to_pdf/models/placement.dart';

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
  final ResizeAttribute? resizeAttribute;
  final AlignmentAttribute? alignmentAttribute;
  final Color backgroundColor;
  final PaddingAttribute? paddingAttribute;
  final SpacingAttribute? spacingAttribute;
  final double compression;
  final CoverPhoto? coverPhoto;
  final PlacementAttribute? placementAttribute;

  Project(
      {required this.id,
      this.title = "Untitled",
      required this.listMedia,
      this.paper,
      this.layoutIndex = 0,
      this.resizeAttribute,
      this.alignmentAttribute,
      this.backgroundColor = colorWhite,
      this.paddingAttribute,
      this.spacingAttribute,
      this.compression = 1.0,
      this.coverPhoto,
      this.placementAttribute});

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
    final alignmentAttribute =
        "alignmentAttribute: ${this.alignmentAttribute},";
    final coverPhoto = "coverPhoto: ${this.coverPhoto},";
    final placementAttribute = "placement: ${this.placementAttribute},";
    print(id +
        title +
        listMedia +
        layoutIndex +
        backgroundColor +
        paddingAttribute +
        spacingAttribute +
        resizeAttribute +
        compression +
        paper +
        alignmentAttribute +
        coverPhoto +
        placementAttribute);
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
      double? compression,
      CoverPhoto? coverPhoto,
      PlacementAttribute? placementAttribute}) {
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
        compression: compression ?? this.compression,
        coverPhoto: coverPhoto ?? this.coverPhoto,
        placementAttribute: placementAttribute ?? this.placementAttribute);
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
  AlignmentAttribute copyWith(
      {Alignment? alignmentMode, String? title, String? mediaSrc}) {
    return AlignmentAttribute(
        alignmentMode: alignmentMode ?? this.alignmentMode,
        title: title ?? this.title,
        mediaSrc: mediaSrc ?? this.mediaSrc);
  }
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

  String getInfor() {
    return "title: ${this.title}, width:${this.width}, height:${this.height}, unit:${this.unit?.getInfor()}";
  }
}

class Unit {
  final String title;
  final String value;
  Unit({this.title = "", this.value = ""});
  String getInfor() {
    return "Unit title: ${this.title},Unit value:${this.value}";
  }
}

class PlacementAttribute {
  double horizontal, vertical, top, left, right, bottom;
  Unit? unit;
  PlacementAttribute(
      {this.horizontal = 0.0,
      this.vertical = 0.0,
      this.top = 0.0,
      this.left = 0.0,
      this.right = 0.0,
      this.bottom = 0.0,
      this.unit});
  PlacementAttribute copyWith(
      {double? horizontal,
      double? vertical,
      double? top,
      double? left,
      double? right,
      double? bottom,
      Unit? unit}) {
    return PlacementAttribute(
        horizontal: horizontal ?? this.horizontal,
        vertical: vertical ?? this.vertical,
        top: top ?? this.top,
        left: left ?? this.left,
        right: right ?? this.right,
        bottom: bottom ?? this.bottom,
        unit: unit ?? this.unit);
  }
}
