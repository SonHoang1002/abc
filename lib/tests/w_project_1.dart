// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:photo_to_pdf/commons/constants.dart';
// import 'package:photo_to_pdf/commons/themes.dart';
// import 'package:photo_to_pdf/helpers/navigator_route.dart';
// import 'package:photo_to_pdf/helpers/render_boxfit.dart';
// import 'package:photo_to_pdf/models/placement.dart';
// import 'package:photo_to_pdf/models/project.dart';
// import 'package:photo_to_pdf/screens/module_editor/preview.dart';
// import 'package:photo_to_pdf/widgets/w_spacer.dart';
// import 'package:photo_to_pdf/widgets/w_text_content.dart';
// import "package:provider/provider.dart" as pv;

// class WProjectItemEditor1 extends ConsumerWidget {
//   final Project project;
//   final bool isFocusByLongPress;

//   /// index og image on project
//   final int indexImage;
//   final Function? onRemove;
//   final String? title;

//   /// Use with layoutIndex is 1,2,3
//   final List<dynamic>? layoutExtractList;
//   late Size _size ;

//    WProjectItemEditor1(
//       {super.key,
//       required this.project,
//       required this.isFocusByLongPress,
//       required this.indexImage,
//       this.title,
//       this.onRemove,
//       this.layoutExtractList});

//   EdgeInsets _getPaddingAtribute() {
//     return EdgeInsets.only(
//         top: 5 + (project.paddingAttribute?.verticalPadding ?? 0.0),
//         left: 5 + (project.paddingAttribute?.horizontalPadding ?? 0.0),
//         right: 5 + (project.paddingAttribute?.horizontalPadding ?? 0.0),
//         bottom: 5 + (project.paddingAttribute?.verticalPadding ?? 0.0));
//   }

//   double _getSpacingHorizontalValue() {
//     return 3 + (project.spacingAttribute?.horizontalSpacing ?? 0.0) * 5;
//   }

//   double _getSpacingVerticalValue() {
//     return 3 + (project.spacingAttribute?.verticalSpacing ?? 0.0) * 5;
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     _size= MediaQuery.sizeOf(context);
//     return GestureDetector(
//       onTap: () {
//         pushCustomMaterialPageRoute(
//             context,
//             Preview(
//               project: project,
//               layoutExtractList: layoutExtractList!,
//               indexPage: indexImage,
//             ));
//       },
//       child: Container(
//         padding: const EdgeInsets.all(3),
//         constraints: const BoxConstraints(minHeight: 180),
//         child: Column(
//           children: [
//             Container(
//               width: MediaQuery.sizeOf(context).width * 0.3,
//               height: 150,
//               decoration:
//                   BoxDecoration(color: project.backgroundColor, boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   spreadRadius: 0.5,
//                   blurRadius: 5,
//                   offset: const Offset(0, 1),
//                 ),
//               ]),
//               child: Center(
//                 child: Stack(
//                   children: [
//                     Container(
//                       padding: _getPaddingAtribute(),
//                       alignment: project.alignmentAttribute?.alignmentMode,
//                       child: _buildLayoutMedia(
//                           indexImage, project, layoutExtractList,
//                           spacingHorizontal: _getSpacingHorizontalValue(),
//                           spacingVertical: _getSpacingVerticalValue()),
//                     ),
//                     isFocusByLongPress
//                         ? Positioned(
//                             top: -10,
//                             left: -10,
//                             child: Container(
//                               alignment: Alignment.topLeft,
//                               child: Image.asset(
//                                 pv.Provider.of<ThemeManager>(context).isDarkMode
//                                     ? "${pathPrefixIcon}icon_remove_dark.png"
//                                     : "${pathPrefixIcon}icon_remove_light.png",
//                                 width: 50,
//                                 height: 50,
//                               ),
//                             ))
//                         : const SizedBox(),
//                   ],
//                 ),
//               ),
//             ),
//             WSpacer(
//               height: 10,
//             ),
//             WTextContent(
//               value: title ?? "",
//               textFontWeight: FontWeight.w600,
//               textLineHeight: 14.32,
//               textSize: 12,
//               textColor: Theme.of(context).textTheme.bodyMedium!.color,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// Widget _buildLayoutMedia(
//     int indexImage, Project project, List<dynamic>? layoutExtractList,
//     {double spacingVertical = 3, double spacingHorizontal = 3}) {
//   if (project.layoutIndex == 0 && layoutExtractList == null) {
//     return _buildImageWidget(project, project.listMedia[indexImage]);
//   } else if (layoutExtractList != null && layoutExtractList.isNotEmpty) {
//     if (project.layoutIndex == 1) {
//       return Column(
//         children: [
//           Flexible(
//               child: _buildImageWidget(
//             project,
//             layoutExtractList[0],
//             height: 150,
//             width: 150,
//           )),
//           WSpacer(
//             height: spacingVertical,
//           ),
//           Flexible(
//               child: _buildImageWidget(
//             project,
//             layoutExtractList[1],
//             height: 150,
//             width: 150,
//           )),
//         ],
//       );
//     } else if (project.layoutIndex == 2) {
//       return Flex(
//         direction: Axis.vertical,
//         children: [
//           Flexible(
//               child: _buildImageWidget(
//             project,
//             layoutExtractList[0],
//             width: 150,
//           )),
//           WSpacer(height: spacingVertical),
//           Flex(
//             direction: Axis.horizontal,
//             children: [
//               Flexible(
//                   child: _buildImageWidget(
//                 project,
//                 layoutExtractList[1],
//               )),
//               WSpacer(
//                 width: spacingHorizontal,
//               ),
//               Flexible(
//                 child: _buildImageWidget(project, layoutExtractList[2]),
//               ),
//             ],
//           )
//         ],
//       );
//     } else {
//       return Flex(
//         direction: Axis.vertical,
//         children: [
//           Flex(
//             direction: Axis.horizontal,
//             children: [
//               Flexible(child: _buildImageWidget(project, layoutExtractList[0])),
//               WSpacer(width: spacingHorizontal),
//               Flexible(
//                 child: _buildImageWidget(project, layoutExtractList[1]),
//               ),
//             ],
//           ),
//           WSpacer(height: spacingVertical),
//           Flexible(
//               child: _buildImageWidget(
//             project,
//             layoutExtractList[2],
//             width: 150,
//           )),
//         ],
//       );
//     }
//   } else {
//     return const SizedBox();
//   }
// }

// Widget _buildImageWidget(Project project, dynamic imageData,
//     {double? width, double? height}) {
//   final fit = renderImageBoxfit(project.resizeAttribute);
//   if (imageData == null) {
//     return Container();
//   } else {
//     if (imageData is File) {
//       return Image.file(
//         imageData,
//         fit: fit,
//         height: height,
//         width: width,
//       );
//     } else {
//       return Image.asset(
//         imageData,
//         fit: fit,
//         height: height,
//         width: width,
//       );
//     }
//   }
// }
