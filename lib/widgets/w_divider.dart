import 'package:flutter/material.dart';

class WDivider extends StatelessWidget {
  final double? height;
  final double? width;
  final EdgeInsets? margin;
  final Color? color;
  const WDivider(
      {super.key, this.height = 5, this.width = 0, this.color, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: Theme.of(context).dividerTheme.color,
      margin: margin,
      width: width,
    );
  }
}
