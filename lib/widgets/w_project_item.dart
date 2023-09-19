import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class WProjectItem extends StatelessWidget {
  final String src;
  final bool isFocusByLongPress;
  final int index;
  final Function? onLongPress;
  const WProjectItem(
      {super.key,
      required this.src,
      required this.isFocusByLongPress,
      required this.index,
      this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      // decoration: BoxDecoration(
      //     color: Colors.grey.withOpacity(0.1),
      //     borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: Center(
              child: Stack(
                children: [
                  SizedBox(
                    // height: 155,
                    // width: 155,
                    child: Image.asset(
                      src,
                      // fit: BoxFit.fitHeight,
                    ),
                  ),
                  isFocusByLongPress
                      ? Positioned.fill(
                          child: Container(
                          color: Colors.grey.withOpacity(0.1),
                          alignment: Alignment.topLeft,
                          child: Image.asset(
                            "${pathPrefixIcon}icon_remove.png",
                            width: 30,
                            height: 30,
                            scale: 3,
                          ),
                        ))
                      : const SizedBox(),
                ],
              ),
            ),
          ),
          WBuildSpacer(
            height: 10,
          ),
          WBuildTextContent(
            value: "Project ${index + 1}",
            textFontWeight: FontWeight.w600,
            textLineHeight: 14.32,
            textSize: 12,
          )
        ],
      ),
    );
  }
}
