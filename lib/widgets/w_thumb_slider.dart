import 'package:flutter/material.dart';

class CustomSliderThumbCircle extends SliderComponentShape {
  final double thumbRadius;
  final Color borderColor;
  final double borderWidth;
  final Color backgroundColor;
  final double thumbHeight;

  const CustomSliderThumbCircle(
      {required this.thumbRadius,
      required this.borderColor,
      required this.borderWidth,
      required this.backgroundColor,
      required this.thumbHeight});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final Canvas canvas = context.canvas;

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final Paint fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbHeight / 2 - borderWidth, borderPaint);
    canvas.drawCircle(
        center, thumbHeight - thumbRadius - borderWidth, fillPaint);

    // final double radius = thumbRadius - borderWidth;
    // final double top = center.dy - radius;
    // final double bottom = top + thumbHeight;
    // final Rect rect = Rect.fromLTRB(center.dx - radius, top, center.dx + radius, bottom);
    // canvas.drawRect(rect, fillPaint);
  }
}
