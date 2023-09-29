import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/screens/module_editor/widgets/w_editor.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

void showBottomSheetPageSize(
    {required BuildContext context,
    required Size size,
    required dynamic pageConfig,
    // width - height
    required List<TextEditingController> listController,
    required int? indexSelected,
    required bool overflowValueInput,
    required double renderPreviewHeight,
    required double renderPreviewWidth,
    required bool pageSizeIsPortrait,
    required Function(int value) onChangeIndexWidget,
    required Function(dynamic value) onSelectedPreset,
    required Function(String label, String value) onInputChanged,
    required Function(String label) onChangedOrientation}) {
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom >= 100
                  ? MediaQuery.of(context).viewInsets.bottom - 100
                  : 0.0),
          child: StatefulBuilder(builder: (context, setStatefull) {
            return Container(
              height: size.height * 0.55,
              decoration:  BoxDecoration(
             color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: WTextContent(
                          value: "Paper Size",
                          textSize: 14,
                          textLineHeight: 16.71,
                        ),
                      ),
                      Expanded(
                          child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // page size selections
                          Container(
                            padding: const EdgeInsets.only(left: 10, top: 20),
                            child: Column(
                              children: [
                                // preset
                                buildPageSizePreset(
                                  context: context,
                                  item: pageConfig,
                                  onTap: () {
                                    onChangeIndexWidget(0);
                                    setStatefull(() {});
                                  },
                                  isFocus: indexSelected == 0,
                                  onSelected: (value) {
                                    onSelectedPreset(value);
                                    setStatefull(() {});
                                  },
                                ),
                                WSpacer(
                                  height: 10,
                                ),
                                // width
                                buildCupertinoInput(
                                    context: context,
                                    controller: listController[0],
                                    title: "Width",
                                    onTap: () {
                                      onChangeIndexWidget(1);
                                      setStatefull(() {});
                                    },
                                    onChanged: (value) {
                                      onInputChanged("Width", value);
                                    },
                                    suffixValue: pageConfig['content']['unit'],
                                    isFocus: indexSelected == 1),
                                WSpacer(
                                  height: 10,
                                ),
                                // height
                                buildCupertinoInput(
                                    context: context,
                                    controller: listController[1],
                                    title: "Height",
                                    onTap: () {
                                      onChangeIndexWidget(2);
                                      setStatefull(() {});
                                    },
                                    onChanged: (value) {
                                      onInputChanged("Height", value);
                                    },
                                    suffixValue: pageConfig['content']['unit'],
                                    isFocus: indexSelected == 2),
                                WSpacer(
                                  height: 10,
                                ),
                                // orientation
                                overflowValueInput
                                    ? const SizedBox()
                                    : Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          height: 70,
                                          width: 200,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color: const Color.fromRGBO(
                                                0, 0, 0, 0.03),
                                          ),
                                          child: Row(children: [
                                            Container(
                                              constraints: const BoxConstraints(
                                                  minWidth: 50, maxWidth: 70),
                                              padding: const EdgeInsets.only(
                                                  left: 5),
                                              child: WTextContent(
                                                value: "Orientation",
                                                textSize: 14,
                                                textLineHeight: 16.71,
                                                textColor: const Color.fromRGBO(
                                                    0, 0, 0, 0.5),
                                                textFontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            WSpacer(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  buildPageSizeOrientationItem(
                                                      mediaSrc:
                                                          "${pathPrefixIcon}icon_portrait.png",
                                                      isSelected:
                                                          pageSizeIsPortrait,
                                                      onTap: () {
                                                        onChangedOrientation(
                                                            PORTRAIT);
                                                        setStatefull(() {});
                                                      }),
                                                  buildPageSizeOrientationItem(
                                                      mediaSrc:
                                                          "${pathPrefixIcon}icon_landscape.png",
                                                      isSelected:
                                                          !pageSizeIsPortrait,
                                                      onTap: () {
                                                        onChangedOrientation(
                                                            LANDSCAPE);
                                                        setStatefull(() {});
                                                      }),
                                                ],
                                              ),
                                            )
                                          ]),
                                        ),
                                      )

                                // _buildOrientation(
                                //     onChangedOrientation: (String label) {
                                //       onChangedOrientation(label);
                                //       setStatefull(() {});
                                //     },
                                //     pageSizeIsPortrait: pageSizeIsPortrait)
                              ],
                            ),
                          ),
                          // page size preview
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(
                                  right: 20, left: 20, top: 20),
                              alignment: Alignment.topCenter,
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  AnimatedContainer(
                                    alignment: Alignment.topCenter,
                                    duration: const Duration(milliseconds: 400),
                                    constraints: const BoxConstraints(
                                        maxHeight: 150, maxWidth: 150),
                                    height: renderPreviewHeight,
                                    width: renderPreviewWidth,
                                    decoration: BoxDecoration(
                                        border: overflowValueInput
                                            ? null
                                            : Border.all(
                                                color: const Color.fromRGBO(
                                                    0, 0, 0, 0.1),
                                                width: 2)),
                                    padding: const EdgeInsets.all(10),
                                  ),
                                  !overflowValueInput
                                      ? Positioned.fill(
                                          child: Container(
                                              alignment: Alignment.center,
                                              child: WTextContent(
                                                value:
                                                    "${listController[0].text.trim()}x${listController[1].text.trim()}${pageConfig['content']['unit']}",
                                                textSize: 16,
                                                textLineHeight: 19.09,
                                                textFontWeight: FontWeight.w600,
                                                textColor: const Color.fromRGBO(
                                                    0, 0, 0, 0.5),
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                              )),
                                        )
                                      : Container(
                                          alignment: Alignment.topCenter,
                                          child: WTextContent(
                                            value:
                                                "${listController[0].text.trim()}x${listController[1].text.trim()}${pageConfig['content']['unit']}",
                                            textSize: 16,
                                            textLineHeight: 19.09,
                                            textFontWeight: FontWeight.w600,
                                            textColor: const Color.fromRGBO(
                                                0, 0, 0, 0.5),
                                            textOverflow: TextOverflow.ellipsis,
                                          ))
                                ],
                              ),
                            ),
                          )
                        ],
                      )),
                      buildBottomButton(context,(){})
                    ],
                  ),
                ],
              ),
            );
          }),
        );
      },
      isScrollControlled: true,
      backgroundColor: transparent);
}


//                                     showBottomSheetPageSize(
//                                     context: context,
//                                     size: _size,
//                                     pageConfig: _pageConfig,
//                                     listController: [
//                                       _pageSizeWidthController,
//                                       _pageSizeHeightController
//                                     ],
//                                     overflowValueInput: _overWHValue(),
//                                     indexSelected:
//                                         _indexPageSizeSelectionWidget,
//                                     renderPreviewHeight: _renderPreviewHeight(),
//                                     renderPreviewWidth: _renderPreviewWidth(),
//                                     onChangeIndexWidget: (value) {
//                                       setState(() {
//                                         _indexPageSizeSelectionWidget = value;
//                                       });
//                                     },
//                                     onSelectedPreset: (value) {
//                                       setState(() {
//                                         _pageConfig['content'] = value;
//                                         _pageSizeWidthController.text =
//                                             (_pageConfig['content']['width'])
//                                                 .toString();
//                                         _pageSizeHeightController.text =
//                                             (_pageConfig['content']['height'])
//                                                 .toString();
//                                       });
//                                     },
//                                     onInputChanged:
//                                         (String label, String value) {
//                                       if (label == 'Width' &&
//                                           _pageSizeWidthController.text
//                                                   .trim() !=
//                                               _pageConfig['content']['width']) {
//                                         setState(() {
//                                           _pageConfig['content'] =
//                                               LIST_PAGE_SIZE[7];
//                                         });
//                                       }
//                                       if (value.trim().isEmpty) {
//                                         _pageSizeWidthController.text = "1.0";
//                                       }
//                                       if (label == "Height" &&
//                                           _pageSizeHeightController.text
//                                                   .trim() !=
//                                               _pageConfig['content']
//                                                   ['height']) {
//                                         setState(() {
//                                           _pageConfig['content'] =
//                                               LIST_PAGE_SIZE[7];
//                                         });
//                                       }
//                                       if (value.trim().isEmpty) {
//                                         _pageSizeHeightController.text = "1.0";
//                                       }
//                                     },
//                                     pageSizeIsPortrait: _pageSizeIsPortrait,
//                                     onChangedOrientation: (label) {
//                                       if (label == PORTRAIT) {
//                                         setState(() {
//                                           if (_pageSizeIsPortrait == false) {
//                                             _tranferValuePageSize();
//                                           }
//                                           _pageSizeIsPortrait = true;
//                                         });
//                                       }

//                                       if (label == LANDSCAPE) {
//                                         setState(() {
//                                           if (_pageSizeIsPortrait == true) {
//                                             _tranferValuePageSize();
//                                           }
//                                           _pageSizeIsPortrait = false;
//                                         });
//                                       }
//                                     });