// import 'package:flutter/material.dart';
// import 'package:photo_to_pdf/commons/constants.dart';
// import 'package:photo_to_pdf/helpers/navigator_route.dart';
// import 'package:photo_to_pdf/models/project.dart';
// import 'package:photo_to_pdf/screens/module_editor/editor_padding_spacing.dart';
// import 'package:photo_to_pdf/widgets/w_drag_zoom_image.dart';
// import 'package:photo_to_pdf/widgets/w_editor.dart';
// import 'package:photo_to_pdf/widgets/w_spacer.dart';
// import 'package:photo_to_pdf/widgets/w_text_content.dart';

// class LayoutBody extends StatefulWidget {
//   final Function() reRenderFunction;
//   final int segmentCurrentIndex;
//   final List listLayoutStatus;
//   final Color currentLayoutColor;
//   const LayoutBody({super.key,required this.reRenderFunction,required this.segmentCurrentIndex,required this.listLayoutStatus,required this.currentLayoutColor});

//   @override
//   State<LayoutBody> createState() => _LayoutBodyState();
// }

// class _LayoutBodyState extends State<LayoutBody> {
//   late int _segmentCurrentIndex ; 
//   late List _listLayoutStatus;
//   late Color _currentLayoutColor;
//   @override
//   void initState() {
//     _segmentCurrentIndex = widget.segmentCurrentIndex;
//     _listLayoutStatus = widget.listLayoutStatus;
//     _currentLayoutColor = widget.currentLayoutColor;
//     super.initState();
//   }
//     void _resetLayoutSelections() {
//     _listLayoutStatus = _listLayoutStatus = LIST_LAYOUT.map((e) {
//       return {"mediaSrc": e, "isFocus": false};
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final _size = MediaQuery.sizeOf(context);
//     return 
//     Column(
//                 children: [
//                   Container(
//                     margin: const EdgeInsets.only(top: 20),
//                     child: WTextContent(
//                       value: "Layout",
//                       textSize: 14,
//                       textLineHeight: 16.71,
//                       textColor: Theme.of(context).textTheme.bodyMedium!.color,
//                     ),
//                   ),
//                   WSpacer(
//                     height: 20,
//                   ),
//                   buildSegmentControl(
//                     context: context,
//                     groupValue: _segmentCurrentIndex,
//                     onValueChanged: (value) {
//                       setState(() {
//                         _segmentCurrentIndex = value!;
//                       });
//                       widget.reRenderFunction();
//                     },
//                   ),
//                   Expanded(
//                     child: _segmentCurrentIndex == 0
//                         ? Container(
//                             height: _size.height * 404 / 791 * 0.9,
//                             decoration: BoxDecoration(
//                                 color: Theme.of(context).cardColor,
//                                 borderRadius: BorderRadius.circular(10)),
//                             margin: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 10),
//                             child: SingleChildScrollView(
//                                 padding: const EdgeInsets.symmetric(
//                                     vertical: 20, horizontal: 20),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.center,
//                                         children: _listLayoutStatus
//                                             .sublist(0, 2)
//                                             .toList()
//                                             .map(
//                                           (e) {
//                                             final index =
//                                                 _listLayoutStatus.indexOf(e);
//                                             return Container(
//                                               margin:
//                                                   const EdgeInsets.symmetric(
//                                                       horizontal: 10),
//                                               child: buildLayoutWidget(
//                                                 context: context,
//                                                 mediaSrc: e['mediaSrc'],
//                                                 title: "Layout ${index + 1}",
//                                                 isFocus: e['isFocus'],
//                                                 backgroundColor:
//                                                     _currentLayoutColor,
//                                                 indexLayoutItem: index,
//                                                 onTap: () {
//                                                   _resetLayoutSelections();
//                                                   setState(() {
//                                                     _listLayoutStatus[index]
//                                                         ['isFocus'] = true;
//                                                   });
//                                                   widget.reRenderFunction();
//                                                 },
//                                               ),
//                                             );
//                                           },
//                                         ).toList()),
//                                     WSpacer(
//                                       height: 20,
//                                     ),
//                                     Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.center,
//                                         children: _listLayoutStatus
//                                             .sublist(
//                                                 2, _listLayoutStatus.length)
//                                             .toList()
//                                             .map(
//                                           (e) {
//                                             final index =
//                                                 _listLayoutStatus.indexOf(e);
//                                             return Container(
//                                               margin:
//                                                   const EdgeInsets.symmetric(
//                                                       horizontal: 10),
//                                               child: buildLayoutWidget(
//                                                 context: context,
//                                                 mediaSrc: e['mediaSrc'],
//                                                 title: "Layout ${index + 1}",
//                                                 isFocus: e['isFocus'],
//                                                 indexLayoutItem: index,
//                                                 backgroundColor:
//                                                     _currentLayoutColor,
//                                                 onTap: () {
//                                                   setState(() {
//                                                     _resetLayoutSelections();
//                                                     _listLayoutStatus[index]
//                                                         ['isFocus'] = true;
//                                                   });
//                                                   widget.reRenderFunction();
//                                                 },
//                                               ),
//                                             );
//                                           },
//                                         ).toList())
//                                   ],
//                                 )))
//                         : _buildCustomArea(() {
//                             widget.reRenderFunction();
//                           }),
//                   ),
//                   _buildLayoutConfigs(() {
//                     widget.reRenderFunction();
//                   }, _segmentCurrentIndex == 0),
//                   buildBottomButton(context, () {
//                     // layout
//                     // resize mode
//                     // alignment
//                     // background
//                     // padding 
//                     // spacing
//                     popNavigator(context);
//                   })
//                 ],
//               );
//   }
//     Widget _buildLayoutConfigs(
//       void Function() rerenderFunction, bool showPaddingAndSpacing) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       child: Column(
//         children: [
//           Flex(
//             direction: Axis.horizontal,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Flexible(
//                 child: buildLayoutConfigItem(
//                     context: context,
//                     key: _keyResizeMode,
//                     title: "Resize Mode",
//                     content: _resizeModeSelectedValue.title,
//                     width: _size.width * 0.3,
//                     onTap: () {
//                       final renderBoxResize = _keyResizeMode.currentContext
//                           ?.findRenderObject() as RenderBox;
//                       final widgetPosition =
//                           renderBoxResize.localToGlobal(Offset.zero);
//                       showLayoutDialogWithOffset(
//                           context: context,
//                           offset: widgetPosition,
//                           dialogWidget: buildDialogResizeMode(
//                             context,
//                             (value) {
//                               setState(() {
//                                 _resizeModeSelectedValue = value;
//                               });
//                               rerenderFunction();
//                               popNavigator(context);
//                             },
//                           ));
//                     }),
//               ),
//               Flexible(
//                   child: buildLayoutConfigItem(
//                       context: context,
//                       title: "Alignment",
//                       content: _listAlignment
//                           .where((element) => element['isFocus'] == true)
//                           .toList()
//                           .first['title'],
//                       width: _size.width * 0.3,
//                       key: _keyAlignment,
//                       onTap: () {
//                         final renderBoxAlignment = _keyAlignment.currentContext
//                             ?.findRenderObject() as RenderBox;
//                         final widgetOffset =
//                             renderBoxAlignment.localToGlobal(Offset.zero);
//                         showLayoutDialogWithOffset(
//                             context: context,
//                             offset: Offset(_size.width * (1 - (200 / 390)) / 2,
//                                 widgetOffset.dy),
//                             dialogWidget:
//                                 buildDialogAlignment(context, _listAlignment,
//                                     onSelected: (index, value) {
//                               setState(() {
//                                 _listAlignment = LIST_ALIGNMENT.map((e) {
//                                   return {
//                                     "mediaSrc": e.mediaSrc,
//                                     "title": e.title,
//                                     "isFocus": false
//                                   };
//                                 }).toList();
//                                 _listAlignment[index]["isFocus"] = true;
//                               });
//                               rerenderFunction();
//                               popNavigator(context);
//                             }));
//                       })),
//               Flexible(
//                 child: buildLayoutConfigItem(
//                   context: context,
//                   title: "Background",
//                   content: "",
//                   width: _size.width * 0.3,
//                   contentWidgetColor: _currentLayoutColor,
//                   onTap: () {
//                     _showBottomSheetBackground(
//                         rerenderFunction: rerenderFunction);
//                   },
//                 ),
//               ),
//             ],
//           ),
//           WSpacer(
//             height: 10,
//           ),
//           showPaddingAndSpacing
//               ? Flex(
//                   direction: Axis.horizontal,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Flexible(
//                         child: buildLayoutConfigItem(
//                       context: context,
//                       title: TITLE_PADDING,
//                       content: _renderPreviewPaddingOptions(),
//                       width: _size.width * 0.46,
//                       onTap: () {
//                         pushCustomVerticalMaterialPageRoute(
//                             context,
//                             EditorPaddingSpacing(
//                                 unit: _paddingOptions.unit!,
//                                 title: TITLE_PADDING,
//                                 controllers: [
//                                   _paddingHorizontalController,
//                                   _paddingVerticalController
//                                 ],
//                                 onChanged: (index, value) {
//                                   if (index == 0) {
//                                     _paddingHorizontalController.text = value;
//                                   }
//                                   if (index == 1) {
//                                     _paddingVerticalController.text = value;
//                                   }
//                                 },
//                                 onUnitDone: (Unit newUnit) {
//                                   setState(() {
//                                     _paddingOptions =
//                                         _paddingOptions.copyWith(unit: newUnit);
//                                   });
//                                   rerenderFunction();
//                                 }));
//                       },
//                     )),
//                     Flexible(
//                       child: buildLayoutConfigItem(
//                         context: context,
//                         title: TITLE_SPACING,
//                         content: _renderPreviewSpacingOptions(),
//                         width: _size.width * 0.46,
//                         onTap: () {
//                           pushCustomVerticalMaterialPageRoute(
//                               context,
//                               EditorPaddingSpacing(
//                                   unit: _spacingOptions.unit!,
//                                   title: TITLE_SPACING,
//                                   controllers: [
//                                     _spacingHorizontalController,
//                                     _spacingVerticalController
//                                   ],
//                                   onChanged: (index, value) {
//                                     if (index == 0) {
//                                       _spacingHorizontalController.text = value;
//                                     }
//                                     if (index == 1) {
//                                       _spacingVerticalController.text = value;
//                                     }
//                                   },
//                                   onUnitDone: (Unit newUnit) {
//                                     setState(() {
//                                       _spacingOptions = _spacingOptions
//                                           .copyWith(unit: newUnit);
//                                     });
//                                     rerenderFunction();
//                                   }));
//                         },
//                       ),
//                     ),
//                   ],
//                 )
//               : const SizedBox(),
//         ],
//       ),
//     );
//   }


//   Widget _buildCustomArea(
//     Function rerenderFunction,
//   ) {
//     void disablePlacement() {
//       setState(() {
//         _seletedPlacement = null;
//       });
//       rerenderFunction();
//     }

//     return GestureDetector(
//       onTap: () {
//         disablePlacement();
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         height: _size.height * 404 / 791 * 0.9,
//         width: _size.width,
//         decoration: BoxDecoration(
//             color: Theme.of(context).cardColor,
//             borderRadius: BorderRadius.circular(10)),
//         margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         child: GestureDetector(
//           onTap: () {
//             disablePlacement();
//           },
//           child: Column(children: [
//             Expanded(
//                 child: WDragZoomImage(
//               reRenerFunction: rerenderFunction,
//               listPlacement: _listPlacement,
//               matrix4Notifiers: _matrix4Notifiers,
//               updatePlacement: (placements) {
//                 setState(() {
//                   _listPlacement = placements;
//                 });
//                 rerenderFunction();
//               },
//               onFocusPlacement: (placement, matrix4) {
//                 setState(() {
//                   int index = _listPlacement.indexWhere(
//                     (element) {
//                       return element.id == placement.id;
//                     },
//                   );
//                   if (index != -1) {
//                     _matrix4Notifiers.removeAt(index);
//                     _matrix4Notifiers.add(matrix4);
//                     _listPlacement.removeAt(index);
//                     _listPlacement.add(placement);
//                   }
//                 });
//                 rerenderFunction();
//                 setState(() {
//                   _seletedPlacement = placement;
//                 });
//                 rerenderFunction();
//               },
//               seletedPlacement: _seletedPlacement,
//             )),
//             WSpacer(height: 10),
//             SizedBox(
//               width: _size.width * 0.7,
//               child: Flex(
//                 direction: Axis.horizontal,
//                 children: [
//                   Flexible(
//                     flex: 4,
//                     child: WButtonFilled(
//                       message: "Add Placement",
//                       textColor: colorBlue,
//                       textLineHeight: 14.32,
//                       textSize: 12,
//                       height: 30,
//                       backgroundColor: const Color.fromRGBO(22, 115, 255, 0.08),
//                       onPressed: () {
//                         setState(() {
//                           _matrix4Notifiers
//                               .add(ValueNotifier(Matrix4.identity()));
//                           _listPlacement.add(Placement(
//                               width: 70,
//                               height: 70,
//                               alignment: Alignment.center,
//                               offset: Offset(_size.width * 0.4 - 35,
//                                   _size.width * 0.4 - 35),
//                               id: getRandomNumber()));
//                           _seletedPlacement = _listPlacement.last;
//                         });
//                         rerenderFunction();
//                       },
//                       padding: EdgeInsets.zero,
//                     ),
//                   ),
//                   _seletedPlacement != null
//                       ? WSpacer(
//                           width: 10,
//                         )
//                       : const SizedBox(),
//                   _seletedPlacement != null
//                       ? Flexible(
//                           flex: 2,
//                           child: WButtonFilled(
//                             message: "Edit",
//                             height: 30,
//                             textColor: colorBlue,
//                             textLineHeight: 14.32,
//                             textSize: 12,
//                             backgroundColor:
//                                 const Color.fromRGBO(22, 115, 255, 0.08),
//                             padding: EdgeInsets.zero,
//                             onPressed: () {
//                               pushCustomVerticalMaterialPageRoute(
//                                   context,
//                                   EditorPaddingSpacing(
//                                     unit: _placementOptions.unit!,
//                                     title: TITLE_EDIT_PLACEMENT,
//                                     // width and height is 0 and 1 to comparable with EditorPaddingSpacing (2 controller)
//                                     controllers: [
//                                       _placementWidthController,
//                                       _placementHeightController,
//                                       _placementTopController,
//                                       _placementLeftController,
//                                       _placementRightController,
//                                       _placementBottomController,
//                                     ],
//                                     onChanged: (index, value) {
//                                       _onChangedEditPlacement(index, value);
//                                     },
//                                     onUnitDone: (newUnit) {
//                                       setState(() {
//                                         _placementOptions = _placementOptions
//                                             .copyWith(unit: newUnit);
//                                       });
//                                       rerenderFunction();
//                                     },
//                                   ));
//                             },
//                           ),
//                         )
//                       : const SizedBox(),
//                   _seletedPlacement != null
//                       ? WSpacer(
//                           width: 10,
//                         )
//                       : const SizedBox(),
//                   _seletedPlacement != null
//                       ? Flexible(
//                           flex: 2,
//                           child: WButtonFilled(
//                             message: "Delete",
//                             height: 30,
//                             textColor: const Color.fromRGBO(255, 63, 51, 1),
//                             textLineHeight: 14.32,
//                             textSize: 12,
//                             backgroundColor:
//                                 const Color.fromRGBO(255, 63, 51, 0.1),
//                             padding: EdgeInsets.zero,
//                             onPressed: () {
//                               final index =
//                                   _listPlacement.indexOf(_seletedPlacement!);
//                               _listPlacement.removeAt(index);
//                               _matrix4Notifiers.removeAt(index);
//                               _seletedPlacement = null;
//                               setState(() {});
//                               rerenderFunction();
//                             },
//                           ),
//                         )
//                       : const SizedBox()
//                 ],
//               ),
//             )
//           ]),
//         ),
//       ),
//     );
//   }

// }