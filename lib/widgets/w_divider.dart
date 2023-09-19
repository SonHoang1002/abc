import 'package:flutter/material.dart';

class WDivider extends StatelessWidget {
  double? height = 5;
  double? width = 0;
  EdgeInsets? margin;
  Color? color;
  WDivider({super.key, this.height = 5, this.width = 0, this.color,this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: color,
      margin:margin,
    );
  }
}
