import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/models/cover_photo.dart';
import 'package:photo_to_pdf/models/placement.dart';

class Project {
  int id;
  final String title;
  // [listMedia] is File or asset String
  final List<dynamic> listMedia;
  final PaperAttribute? paper;

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
      this.compression = 0.8,
      this.coverPhoto,
      this.placements,
      this.useAvailableLayout = true});
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
        id: this.id,
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

  Map<String, dynamic> toJson() {
    List<String?> mediaList = listMedia.map((media) {
      if (media is File) {
        return media.path;
      } else if (media is String) {
        return media;
      } else {
        return null;
      }
    }).toList();

    return {
      'id': id,
      'title': title,
      'listMedia': mediaList,
      'paper': paper?.toJson(),
      'layoutIndex': layoutIndex,
      'resizeAttribute': resizeAttribute?.toJson(),
      'alignmentAttribute': alignmentAttribute?.toJson(),
      'backgroundColor': backgroundColor.value,
      'paddingAttribute': paddingAttribute?.toJson(),
      'spacingAttribute': spacingAttribute?.toJson(),
      'compression': compression,
      'coverPhoto': coverPhoto?.toJson(),
      'placements': placements != null
          ? placements!.map((x) => x.toJson()).toList()
          : null,
      'useAvailableLayout': useAvailableLayout,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    List<dynamic> listMedia = [];

    listMedia = json['listMedia'].map((e) {
      if (e.contains(PATH_PREFIX_IMAGE) || e.contains(PATH_PREFIX_ICON)) {
        return e;
      } else {
        return File(e);
      }
    }).toList();
    return Project(
      id: json['id'],
      title: json['title'] ?? "Untitled",
      listMedia: listMedia,
      paper:
          json['paper'] != null ? PaperAttribute.fromJson(json['paper']) : null,
      layoutIndex: json['layoutIndex'] ?? 0,
      resizeAttribute: json['resizeAttribute'] != null
          ? ResizeAttribute.fromJson(json['resizeAttribute'])
          : null,
      alignmentAttribute: json['alignmentAttribute'] != null
          ? AlignmentAttribute.fromJson(json['alignmentAttribute'])
          : null,
      backgroundColor: Color(json['backgroundColor'] ?? colorWhite),
      paddingAttribute: json['paddingAttribute'] != null
          ? PaddingAttribute.fromJson(json['paddingAttribute'])
          : null,
      spacingAttribute: json['spacingAttribute'] != null
          ? SpacingAttribute.fromJson(json['spacingAttribute'])
          : null,
      compression: json['compression'] ?? 1.0,
      coverPhoto: json['coverPhoto'] != null
          ? CoverPhoto.fromJson(json['coverPhoto'])
          : null,
      placements: json['placements'] != null
          ? List<Placement>.from(
              json['placements'].map((x) => Placement.fromJson(x)))
          : null,
      useAvailableLayout: json['useAvailableLayout'] ?? true,
    );
  }

  List<dynamic> renderListMedia(List<dynamic> listMediaData) {
    if (listMediaData.isEmpty) {
      return [];
    }
    return listMediaData.map((e) {
      if (e.contains(PATH_PREFIX_IMAGE) || e.contains(PATH_PREFIX_ICON)) {
        return e;
      } else {
        return File(e);
      }
    }).toList();
  }

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

  Map<String, dynamic> toJson() {
    return {
      'verticalPadding': verticalPadding,
      'horizontalPadding': horizontalPadding,
      'unit': unit?.toJson(),
    };
  }

  factory PaddingAttribute.fromJson(Map<String, dynamic> json) {
    return PaddingAttribute(
      verticalPadding: json['verticalPadding'] ?? 0.0,
      horizontalPadding: json['horizontalPadding'] ?? 0.0,
      unit: json['unit'] != null ? Unit.fromJson(json['unit']) : null,
    );
  }
    String getInfor() {
    return "PaddingAttribute verticalPadding: ${this.verticalPadding}, PaddingAttribute horizontalPadding: ${this.horizontalPadding}, PaddingAttribute unit: ${this.unit?.getInfor()},";
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

  Map<String, dynamic> toJson() {
    return {
      'verticalSpacing': verticalSpacing,
      'horizontalSpacing': horizontalSpacing,
      'unit': unit?.toJson(),
    };
  }

  factory SpacingAttribute.fromJson(Map<String, dynamic> json) {
    return SpacingAttribute(
      verticalSpacing: json['verticalSpacing'] ?? 0,
      horizontalSpacing: json['horizontalSpacing'] ?? 0,
      unit: json['unit'] != null ? Unit.fromJson(json['unit']) : null,
    );
  }
}

class ResizeAttribute {
  final String title;
  final String mediaSrc;
  ResizeAttribute({this.title = "", this.mediaSrc = ''});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'mediaSrc': mediaSrc,
    };
  }

  factory ResizeAttribute.fromJson(Map<String, dynamic> json) {
    return ResizeAttribute(
      title: json['title'] ?? "",
      mediaSrc: json['mediaSrc'] ?? "",
    );
  }
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

  Map<String, dynamic> toJson() {
    return {
      'alignmentMode': [alignmentMode.x, alignmentMode.y],
      'title': title,
      'mediaSrc': mediaSrc,
    };
  }

  factory AlignmentAttribute.fromJson(Map<String, dynamic> json) {
    return AlignmentAttribute(
      alignmentMode: Alignment(json['alignmentMode'][0]?.toDouble() ?? 0.0,
          json['alignmentMode'][1]?.toDouble() ?? 0.0),
      title: json['title'] ?? "Center",
      mediaSrc: json['mediaSrc'] ?? "",
    );
  }
}

class PaperAttribute {
  final String title;
  final double width;
  final double height;
  final Unit? unit;
  final bool isPortrait;
  PaperAttribute(
      {this.title = "",
      this.width = 0.0,
      this.height = 0.0,
      this.unit,
      this.isPortrait = true});
  PaperAttribute copyWith(
      {double? height,
      double? width,
      String? title,
      Unit? unit,
      bool? isPortrait}) {
    return PaperAttribute(
        height: height ?? this.height,
        width: width ?? this.width,
        unit: unit ?? this.unit,
        title: title ?? this.title,
        isPortrait: isPortrait ?? this.isPortrait);
  }

  String getInfor() {
    return "PaperAttribute title: ${this.title}, PaperAttribute width: ${this.width}, PaperAttribute height: ${this.height},PaperAttribute isPortrait: ${this.isPortrait}, PaperAttribute unit: ${this.unit?.getInfor()},";
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'width': width,
      'height': height,
      "isPortrait": isPortrait,
      'unit': unit?.toJson(),
    };
  }

  factory PaperAttribute.fromJson(Map<String, dynamic> json) {
    return PaperAttribute(
      title: json['title'] ?? "",
      width: json['width'] ?? 0.0,
      height: json['height'] ?? 0.0,
      isPortrait: json['isPortrait'] ?? true,
      unit: json['unit'] != null ? Unit.fromJson(json['unit']) : null,
    );
  }
}

class Unit {
  final String title;
  final String value;
  Unit({this.title = "", this.value = ""});
  String getInfor() {
    return "Unit title: ${this.title}, Unit value: ${this.value}";
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'value': value,
    };
  }

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      title: json['title'] ?? "",
      value: json['value'] ?? "",
    );
  }
}
