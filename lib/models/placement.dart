import 'dart:math';

import 'package:flutter/material.dart';

class Placement {
  int id;
  double width;
  double height;
  Alignment alignment;
  Placement(
      {this.id = 0,
      required this.width,
      required this.height,
      required this.alignment});
}
