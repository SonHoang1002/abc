import 'package:photo_to_pdf/models/project.dart';

class Placement {
  int id;
  double ratioWidth;
  double ratioHeight;
  // String titleIndex;
  // double ratioWidth;
  // double ratioHeight;
  // ratio of width, height
  List<double> ratioOffset;
  List<double> previewRatioOffset;
  PlacementAttribute? placementAttribute;
  Placement({
    required this.id,
    required this.ratioWidth,
    required this.ratioHeight,
    required this.ratioOffset,
    required this.placementAttribute,
    required this.previewRatioOffset
  });

  Placement copyWith({
    double? ratioWidth,
    double? ratioHeight,
    List<double>? ratioOffset,
    PlacementAttribute? placementAttribute,
    List<double>? previewRatioOffset
  }) {
    return Placement(
      id: id,
      ratioWidth: ratioWidth ?? this.ratioWidth,
      ratioHeight: ratioHeight ?? this.ratioHeight,
      ratioOffset: ratioOffset ?? this.ratioOffset,
      placementAttribute: placementAttribute ?? this.placementAttribute,
      previewRatioOffset:previewRatioOffset ?? this.previewRatioOffset
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ratioWidth': ratioWidth,
      'ratioHeight': ratioHeight,
      'ratioOffset': ratioOffset, 
      "previewRatioOffset":previewRatioOffset,
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
      previewRatioOffset: [json['previewRatioOffset'][0], json['previewRatioOffset'][1]],
      placementAttribute: json['placementAttribute'] != null
          ? PlacementAttribute.fromJson(json['placementAttribute'])
          : null,
    );
  }

  void getInfor() {
    print(
        "Placement id: ${this.id}, Placement ratioHeight: ${this.ratioHeight}, Placement ratioWidth: ${this.ratioWidth}, Placement ratioOffset: ${this.ratioOffset}, Placement placementAttribute: ${this.placementAttribute?.getInfor()} ");
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
