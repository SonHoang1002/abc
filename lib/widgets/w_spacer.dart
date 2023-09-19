import 'package:flutter/material.dart';


// ignore: must_be_immutable
class WBuildSpacer extends StatelessWidget {
  double? height = 5;
  double? width = 0;
  Color? color;
  WBuildSpacer({super.key, this.height = 5, this.width = 0, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: color,
    );
  }
}
