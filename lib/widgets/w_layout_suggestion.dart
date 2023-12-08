import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

Widget buildLayoutWidget({
  required BuildContext context,
  required String title,
  required Color backgroundColor,
  required bool isFocus,
  required Project project,
  required Function() onTap,
  required List<int> layoutSuggestion,
}) {
  double maxWidth = MediaQuery.sizeOf(context).width * 0.35;
  double maxHeight = MediaQuery.sizeOf(context).width * 0.35 * 1.3;
  final paperHeight = project.paper?.height;
  final paperWidth = project.paper?.width;
  double realWidth = maxWidth, realHeight = maxHeight;
  if (project.paper != null && paperWidth != 0.0 && paperHeight != 0.0) {
    final ratioWH = paperWidth! / paperHeight!;
    // width. height
    if (ratioWH > 1) {
      realWidth = maxWidth;
      realHeight = realWidth * (1 / ratioWH);
      if (realHeight > maxHeight) {
        realHeight = maxHeight;
        realWidth = realHeight * ratioWH;
      }
      //height> width
    } else if (ratioWH < 1) {
      realHeight = maxHeight;
      realWidth = realHeight * ratioWH;
      if (realWidth > maxWidth) {
        realWidth = maxWidth;
        realHeight = realWidth * (1 / ratioWH);
      }
    } else {
      realHeight = realWidth = maxWidth;
    }
  }
  final padding = EdgeInsets.symmetric(
      horizontal: 5 / maxWidth * realWidth,
      vertical: 5 / maxHeight * realHeight);

  return Column(
    children: [
      GestureDetector(
        onTap: onTap,
        child: Container(
            width: realWidth,
            height: realHeight,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 2,
                    color: isFocus
                        ? const Color.fromRGBO(22, 115, 255, 1)
                        : transparent)),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(color: backgroundColor, boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 0.5,
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: layoutSuggestion.map((e) {
                  return Flexible(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(e, (index) => index)
                            .map((e) => Flexible(
                                  fit: FlexFit.tight,
                                  child: Container(
                                    margin: const EdgeInsets.all(2),
                                    child: Image.asset(
                                      "${PATH_PREFIX_ICON}icon_layout_1.png",
                                      fit: BoxFit.cover,
                                      height: realHeight,
                                      width: realWidth,
                                    ),
                                  ),
                                ))
                            .toList()),
                  );
                }).toList(),
              ),
            )),
      ),
      WSpacer(
        height: 15,
      ),
      GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isFocus ? const Color.fromRGBO(22, 115, 255, 1) : null),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          width: 80,
          child: Center(
              child: AutoSizeText(
            title,
            maxFontSize: 12,
            minFontSize: 8,
            style: TextStyle(
                color: isFocus
                    ? colorWhite
                    : Theme.of(context).textTheme.bodyMedium!.color,
                fontWeight: FontWeight.w600),
          )),
        ),
      )
    ],
  );
}
