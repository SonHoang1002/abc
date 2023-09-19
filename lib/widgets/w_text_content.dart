import 'package:flutter/material.dart';

class WBuildTextContent extends StatelessWidget {
  final String value;
  double? textSize;
  TextAlign? textAlign;
  Color? textColor;
  double? textLineHeight;
  FontWeight? textFontWeight;
  Function()? onTap;
  WBuildTextContent(
      {required this.value,
      super.key,
      this.textAlign,
      this.textColor,
      this.textFontWeight,
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
                height: textLineHeight != null && textSize != null
                    ? (textLineHeight! / textSize!)
                    : null),
          );
  }
}
