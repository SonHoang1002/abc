// import 'package:flutter/material.dart';
// import 'package:photo_to_pdf/helpers/navigator_route.dart';
// import 'package:photo_to_pdf/screens/module_editor/widgets/w_editor.dart';
// import 'package:photo_to_pdf/widgets/w_spacer.dart';
// import 'package:photo_to_pdf/widgets/w_text_content.dart';

// class LayoutBody extends StatefulWidget {
//   const LayoutBody({super.key});

//   @override
//   State<LayoutBody> createState() => _LayoutBodyState();
// }

// class _LayoutBodyState extends State<LayoutBody> {
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
//                         _segmentCurrentIndex = value;
//                       });
//                       setStatefull(() {});
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
//                                                   setStatefull(() {});
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
//                                                   setStatefull(() {});
//                                                 },
//                                               ),
//                                             );
//                                           },
//                                         ).toList())
//                                   ],
//                                 )))
//                         : _buildCustomArea(() {
//                             setStatefull(() {});
//                           }),
//                   ),
//                   _buildLayoutConfigs(() {
//                     setStatefull(() {});
//                   }, _segmentCurrentIndex == 0),
//                   buildBottomButton(context, () {
//                     // layout
//                     _project = _project.copyWith(layoutIndex: )
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
// }