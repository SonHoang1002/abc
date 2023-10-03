import 'dart:math';

import 'package:flutter/material.dart';

class Placement {
  int id;
  double width;
  double height;
  Alignment alignment;
  Offset offset;
  Placement(
      {this.id = 0,
      required this.width,
      required this.height,
      required this.alignment,
      required this.offset});
  Placement copyWith(
      {double? width, double? height, Alignment? alignment, Offset? offset}) {
    return Placement(
        width: width ?? this.width,
        height: height ?? this.height,
        alignment: alignment ?? this.alignment,
        offset: offset ?? this.offset);
  }

  void getInfor() {
    print(
        "id: ${this.id}, height: ${this.height}, width: ${this.width}, alignment: ${this.alignment}, offset: ${this.offset}");
  }
} 