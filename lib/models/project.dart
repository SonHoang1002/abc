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
  final List<Placement>? placements;
  final bool useAvailableLayout;

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
      this.placements,
      this.useAvailableLayout = true});

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
    final placementAttribute = "placements: ${this.placements},";
    final useAvailableLayout = "useAvailableLayout: ${this.useAvailableLayout}";
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
        placementAttribute +
        useAvailableLayout);
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
      AlignmentAttribute? alignmentAttribute,
      double? compression,
      CoverPhoto? coverPhoto,
      List<Placement>? placements,
      bool? useAvailableLayout}) {
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
        alignmentAttribute: alignmentAttribute ?? this.alignmentAttribute,
        placements: placements ?? this.placements,
        useAvailableLayout: useAvailableLayout ?? this.useAvailableLayout);
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

  String getInfor() {
    return "PaddingAttribute verticalPadding: ${this.verticalPadding}, PaddingAttribute verticalPadding: ${this.verticalPadding}, PaddingAttribute unit: ${this.unit?.getInfor()} ";
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

  String getInfor() {
    return "SpacingAttribute verticalSpacing: ${this.verticalSpacing}, SpacingAttribute horizontalSpacing: ${this.horizontalSpacing}, SpacingAttribute unit: ${this.unit?.getInfor()} ";
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

  String getInfor() {
    return "AlignmentAttribute alignmentMode: ${this.alignmentMode}, AlignmentAttribute title:${this.title}, AlignmentAttribute mediaSrc:${this.mediaSrc}";
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
    return "PaperAttribute title: ${this.title}, PaperAttribute width:${this.width}, PaperAttribute height:${this.height}, PaperAttribute unit:${this.unit?.getInfor()}";
  }
}

class Unit {
  final String title;
  final String value;
  Unit({this.title = "", this.value = ""});
  String getInfor() {
    return "Unit title: ${this.title}, Unit value: ${this.value}";
  }
}
