import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/models/placement.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

Widget buildRectangle(Rectangle1? rectangle1, List<Rectangle1> listRectangle1,
    List<GlobalKey> listGlobalKey, List<Placement> oldEditingPlacementList) {
  int _index = 0;
  // int _indexOld = listRectangle1.length;
  if (rectangle1 != null) {
    _index = listRectangle1
        .map(
          (e) => e.id,
        )
        .toList()
        .indexOf(rectangle1.id);
    // final indexOld = oldEditingPlacementList
    //     .map((e) => e.id)
    //     .toList()
    //     .indexOf(rectangle1.id);
    // if (indexOld != -1) {
    //   _indexOld = indexOld;
    // }
  }
  if (_index == -1) {
    return const SizedBox();
  }

  return Stack(
    children: [
      Positioned(
        key: listGlobalKey[_index],
        top: listRectangle1[_index].y,
        left: listRectangle1[_index].x,
        child: Stack(children: [
          Image.asset(
            "${PATH_PREFIX_IMAGE}image_demo.png",
            fit: BoxFit.cover,
            height: listRectangle1[_index].height,
            width: listRectangle1[_index].width,
          ),
          Positioned.fill(
              child: Center(
            child: Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.5), color: colorBlue),
              child: Center(
                  child: WTextContent(
                value: "${_index + 1}",
                textColor: colorWhite,
                textSize: 10,
              )),
            ),
          )),
        ]),
      ),
    ],
  );
}
