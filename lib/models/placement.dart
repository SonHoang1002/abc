import 'package:flutter/material.dart';
import 'package:photo_to_pdf/models/project.dart';

class Placement {
  int id;
  double width;
  double height;
  Offset offset;
  PlacementAttribute? placementAttribute;
  Placement(
      {required this.id,
      required this.width,
      required this.height,
      required this.offset,
      required this.placementAttribute});

  Placement copyWith({
    double? width,
    double? height,
    Offset? offset,
    PlacementAttribute? placementAttribute,
  }) {
    return Placement(
      id: id,
      width: width ?? this.width,
      height: height ?? this.height,
      offset: offset ?? this.offset,
      placementAttribute: placementAttribute ?? this.placementAttribute,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'width': width,
      'height': height,
      'offset': {
        'dx': offset.dx,
        'dy': offset.dy,
      },
      'placementAttribute':
          placementAttribute != null ? placementAttribute!.toJson() : null,
    };
  }

  factory Placement.fromJson(Map<String, dynamic> json) {
    return Placement(
      id: json['id'],
      width: json['width'],
      height: json['height'],
      offset: Offset(json['offset']['dx'], json['offset']['dy']),
      placementAttribute: json['placementAttribute'] != null
          ? PlacementAttribute.fromJson(json['placementAttribute'])
          : null,
    );
  }

  void getInfor() {
    print(
        "Placement id: ${this.id}, Placement height: ${this.height}, Placement width: ${this.width}, Placement offset: ${this.offset}, Placement placementAttribute: ${this.placementAttribute?.getInfor()} ");
  }
}

class PlacementAttribute {
  double horizontal, vertical, top, left, right, bottom;
  Unit? unit;
  PlacementAttribute({
    this.horizontal = 0.0,
    this.vertical = 0.0,
    this.top = 0.0,
    this.left = 0.0,
    this.right = 0.0,
    this.bottom = 0.0,
    this.unit,
  });

  PlacementAttribute copyWith({
    double? horizontal,
    double? vertical,
    double? top,
    double? left,
    double? right,
    double? bottom,
    Unit? unit,
  }) {
    return PlacementAttribute(
      horizontal: horizontal ?? this.horizontal,
      vertical: vertical ?? this.vertical,
      top: top ?? this.top,
      left: left ?? this.left,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'horizontal': horizontal,
      'vertical': vertical,
      'top': top,
      'left': left,
      'right': right,
      'bottom': bottom,
      'unit': unit != null ? unit!.toJson() : null,
    };
  }
  

  factory PlacementAttribute.fromJson(Map<String, dynamic> json) {
    return PlacementAttribute(
      horizontal: json['horizontal'],
      vertical: json['vertical'],
      top: json['top'],
      left: json['left'],
      right: json['right'],
      bottom: json['bottom'],
      unit: json['unit'] != null ? Unit.fromJson(json['unit']) : null,
    );
  }

  String getInfor() {
    return "PlacementAttribute horizontal: ${this.horizontal}, PlacementAttribute vertical: ${this.vertical}, PlacementAttribute top: ${this.top}, PlacementAttribute left: ${this.left}, PlacementAttribute right: ${this.right}, PlacementAttribute bottom: ${this.bottom}, PlacementAttribute unit: ${this.unit?.getInfor()}";
  }
}

// class Placement {
//   int id;
//   double width;
//   double height;
//   Offset offset;
//   PlacementAttribute? placementAttribute;
//   Placement(
//       {required this.id,
//       required this.width,
//       required this.height,
//       required this.offset,
//       required this.placementAttribute});
//   Placement copyWith(
//       {double? width,
//       double? height,
//       Offset? offset,
//       PlacementAttribute? placementAttribute}) {
//     return Placement(
//         id: id,
//         width: width ?? this.width,
//         height: height ?? this.height,
//         offset: offset ?? this.offset,
//         placementAttribute: placementAttribute ?? this.placementAttribute);
//   }

//   void getInfor() {
//     print(
//         "Placement id: ${this.id}, Placement height: ${this.height}, Placement width: ${this.width}, Placement offset: ${this.offset}, Placement placementAttribute: ${this.placementAttribute} ");
//   }
// }

// class PlacementAttribute {
//   double horizontal, vertical, top, left, right, bottom;
//   Unit? unit;
//   PlacementAttribute(
//       {this.horizontal = 0.0,
//       this.vertical = 0.0,
//       this.top = 0.0,
//       this.left = 0.0,
//       this.right = 0.0,
//       this.bottom = 0.0,
//       this.unit});
//   PlacementAttribute copyWith(
//       {double? horizontal,
//       double? vertical,
//       double? top,
//       double? left,
//       double? right,
//       double? bottom,
//       Unit? unit}) {
//     return PlacementAttribute(
//         horizontal: horizontal ?? this.horizontal,
//         vertical: vertical ?? this.vertical,
//         top: top ?? this.top,
//         left: left ?? this.left,
//         right: right ?? this.right,
//         bottom: bottom ?? this.bottom,
//         unit: unit ?? this.unit);
//   }

//   String getInfor() {
//     return "PlacementAttribute horizontal: ${this.horizontal}, PlacementAttribute vertical: ${this.vertical}, PlacementAttribute top: ${this.top}, PlacementAttribute top: ${this.top}, PlacementAttribute top: ${this.top}, PlacementAttribute left: ${this.left}, PlacementAttribute right: ${this.right}, PlacementAttribute bottom: ${this.bottom}";
//   }
// }
