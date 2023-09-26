import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/screens/module_editor/widgets/w_editor.dart';
import 'package:photo_to_pdf/widgets/w_button.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:photo_to_pdf/widgets/w_project_item.dart';

void showBottomSheetSelectedPhotos(
    {required BuildContext context,
    required Size size,
    required List datas,
    required void Function(int, int) onReorderFunction,
    required double sliderCompressionLevelValue,
    required Function(double value) onSliderChanged}) {
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStatefull) {
          return Container(
            height: size.height * 0.95,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: WTextContent(
                    value: "Selected Photos",
                    textSize: 14,
                    textLineHeight: 16.71,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: size.height * 404 / 791 * 0.9,
                    decoration: BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 0, 0.03),
                        borderRadius: BorderRadius.circular(10)),
                    child: ReorderableGridView.count(
                      padding:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      shrinkWrap: true,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      crossAxisCount: 3,
                      onReorder: (oldIndex, newIndex) {
                        onReorderFunction(oldIndex, newIndex);
                        setStatefull(() {});
                      },
                      onDragStart: (dragIndex) {},
                      children: datas.map((e) {
                        final index = datas.indexOf(e);
                        return WProjectItemHomeBottom(
                          key: ValueKey(datas[index]),
                          src: datas[index],
                          isFocusByLongPress: true,
                          index: index,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                WSpacer(
                  height: 5,
                ),
                SizedBox(
                  width: size.width * 0.7,
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [
                      Flexible(
                        flex: 2,
                        child: WButtonFilled(
                          message: "Add Photo",
                          textColor: colorBlue,
                          textLineHeight: 14.32,
                          textSize: 12,
                          height: 30,
                          backgroundColor:
                              const Color.fromRGBO(22, 115, 255, 0.08),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      WSpacer(
                        width: 10,
                      ),
                      Flexible(
                        flex: 2,
                        child: WButtonFilled(
                          message: "Add File",
                          height: 30,
                          textColor: colorBlue,
                          textLineHeight: 14.32,
                          textSize: 12,
                          backgroundColor:
                              const Color.fromRGBO(22, 115, 255, 0.08),
                          padding: EdgeInsets.zero,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                WSpacer(
                  height: 15,
                ),
                
                _buildCompressionLevelWidget(
                    sliderCompressionLevelValue: sliderCompressionLevelValue,
                    onSliderChanged:(value) {
                      onSliderChanged(value);
                      setStatefull((){});
                    },),
                buildBottomButton(context)
              ],
            ),
          );
        });
      },
      isScrollControlled: true,
      backgroundColor: transparent);
}

Widget _buildCompressionLevelWidget(
    {required double sliderCompressionLevelValue,
    required Function(double value) onSliderChanged}) {
  return Container(
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color.fromRGBO(0, 0, 0, 0.03)),
    child: Column(
      children: [
        Slider(
          value: sliderCompressionLevelValue,
          onChanged: onSliderChanged,
          min: 0,
          max: 1,
          thumbColor: colorWhite,
          activeColor: colorBlue,
        ),
      ],
    ),
  );
}
