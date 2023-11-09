import 'package:photo_to_pdf/models/project.dart';

class Rectangle1 {
  int id;
  double x;
  double y;
  double width;
  double height;
  Rectangle1(
      {required this.id,
      required this.x,
      required this.y,
      required this.width,
      required this.height});
}

class Placement {
  int id;
  double ratioWidth;
  double ratioHeight;
  List<double> ratioOffset;
  PlacementAttribute? placementAttribute;
  Placement({
    required this.id,
    required this.ratioWidth,
    required this.ratioHeight,
    required this.ratioOffset,
    required this.placementAttribute,
  });

  Placement copyWith(
      {double? ratioWidth,
      double? ratioHeight,
      List<double>? ratioOffset,
      PlacementAttribute? placementAttribute,
      List<double>? previewRatioOffset,
      double? previewHeight,
      double? previewWidth}) {
    return Placement(
      id: id,
      ratioWidth: ratioWidth ?? this.ratioWidth,
      ratioHeight: ratioHeight ?? this.ratioHeight,
      ratioOffset: ratioOffset ?? this.ratioOffset,
      placementAttribute: placementAttribute ?? this.placementAttribute,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ratioWidth': ratioWidth,
      'ratioHeight': ratioHeight,
      'ratioOffset': ratioOffset,
      'placementAttribute':
          placementAttribute != null ? placementAttribute!.toJson() : null,

    };
  }

  factory Placement.fromJson(Map<String, dynamic> json) {
    return Placement(
      id: json['id'],
      ratioWidth: json['ratioWidth'],
      ratioHeight: json['ratioHeight'],
      ratioOffset: [json['ratioOffset'][0], json['ratioOffset'][1]],
    
      placementAttribute: json['placementAttribute'] != null
          ? PlacementAttribute.fromJson(json['placementAttribute'])
          : null,
    
    );
  }

  void getInfor() {
    print(
        "Placement id: ${id}, Placement ratioHeight: ${ratioHeight}, Placement ratioWidth: ${ratioWidth}, Placement ratioOffset: ${ratioOffset}, Placement placementAttribute: ${placementAttribute?.getInfor()} ");
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
    return "PlacementAttribute horizontal: ${horizontal}, PlacementAttribute vertical: ${vertical}, PlacementAttribute top: ${top}, PlacementAttribute left: ${left}, PlacementAttribute right: ${right}, PlacementAttribute bottom: ${bottom}, PlacementAttribute unit: ${unit?.getInfor()}";
  }
}
