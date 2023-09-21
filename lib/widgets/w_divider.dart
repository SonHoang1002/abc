import 'package:flutter/material.dart';

class WDivider extends StatelessWidget {
  double? height;
  double? width ;
  EdgeInsets? margin;
  Color? color;
  WDivider({super.key, this.height = 5, this.width = 0, this.color,this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      // width: width,
      color: color,
      margin:margin,
    );
  }
}
