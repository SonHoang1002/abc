import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/constants.dart';

// ignore: must_be_immutable
class WTextContent extends StatelessWidget {
  final String value;
  double? textSize;
  TextAlign? textAlign;
  Color? textColor;
  double? textLineHeight;
  FontWeight? textFontWeight;
  Function()? onTap;
  WTextContent(
      {required this.value,
      super.key,
      this.textAlign,
      this.textColor,
      this.textFontWeight = FontWeight.w700,
      this.textLineHeight,
      this.textSize,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return onTap != null
        ? GestureDetector(
            onTap: onTap,
            child: Text(
              value,
              textAlign: textAlign,
              style: TextStyle(
                  fontSize: textSize,
                  color: textColor,
                  fontWeight: textFontWeight,
                  fontFamily: myCustomFont,
                  height: textLineHeight != null && textSize != null
                      ? (textLineHeight! / textSize!)
                      : null),
            ),
          )
        : Text(
            value,
            textAlign: textAlign,
            style: TextStyle(
                fontSize: textSize,
                color: textColor,
                fontWeight: textFontWeight,
                fontFamily: myCustomFont,
                height: textLineHeight != null && textSize != null
                    ? (textLineHeight! / textSize!)
                    : null),
          );
  }
}
