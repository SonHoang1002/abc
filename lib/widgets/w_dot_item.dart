import 'package:flutter/material.dart';

Widget buildDotItem(double size, Offset offset, {EdgeInsets? margin}) {
    return Positioned(
      top: offset.dy,
      left: offset.dx,
      child: Container(
        height: size,
        width: size,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(color: Colors.blue, width: 2),
        ),
      ),
    );
  }