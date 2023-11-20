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
  required Function() onTap,
  required List<int> layoutSuggestion,
}) {
  return Column(
    children: [
      GestureDetector(
        onTap: onTap,
        child: Container(
            width: MediaQuery.sizeOf(context).width * 0.35,
            height: MediaQuery.sizeOf(context).width * 0.35 * 1.3,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 2,
                    color: isFocus
                        ? const Color.fromRGBO(22, 115, 255, 1)
                        : transparent)),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 18),
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
            child: WTextContent(
              value: title,
              textLineHeight: 14.32,
              textSize: 12,
              textColor: isFocus
                  ? colorWhite
                  : Theme.of(context).textTheme.bodyMedium!.color,
              textFontWeight: FontWeight.w600,
            ),
          ),
        ),
      )
    ],
  );
}
