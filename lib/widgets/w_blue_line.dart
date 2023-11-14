  import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';

Widget buildBlueLineItem(
      double thickness, double top, double left,
      {bool isVertical = true}) {
    return Positioned(
        top: top,
        left: left,
        child: Container(
          margin: EdgeInsets.only(
              top: isVertical ? DOT_SIZE / 2 : 0,
              left: isVertical ? 0 : DOT_SIZE / 2),
          height: isVertical ? 1 : thickness,
          width: isVertical ? thickness : 1,
          color: colorBlue,
        ));
  }