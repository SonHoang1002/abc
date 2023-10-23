import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/commons/themes.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/project_items/w_layout_media_project.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import "package:provider/provider.dart" as pv;

class WProjectItemEditor extends StatefulWidget {
  final Project project;
  final bool isFocusByLongPress;

  /// index of image on project
  final int indexImage;
  final Function()? onRemove;
  final String? title;
  final List<dynamic>? layoutExtractList;
  final Function()? onTap;
  final List<double>? ratioTarget;

  const WProjectItemEditor(
      {super.key,
      required this.project,
      this.isFocusByLongPress = false,
      required this.indexImage,
      this.title,
      this.onRemove,
      this.layoutExtractList,
      this.onTap,
      this.ratioTarget = LIST_RATIO_PROJECT_ITEM});

  @override
  State<WProjectItemEditor> createState() => _WProjectItemEditorState();
}

class _WProjectItemEditorState extends State<WProjectItemEditor> {
  double? maxHeight;
  double? maxWidth;
  late Size _size;
  GlobalKey _key = GlobalKey();
  double _getWidth(BuildContext context) {
    return (MediaQuery.sizeOf(context).width * 0.4) *
        (1 + widget.ratioTarget![0]);
  }

  double _getHeight(BuildContext context) {
    return (MediaQuery.sizeOf(context).width * 0.3) *
        (1 + widget.ratioTarget![1]);
  }

  List<double> _getRealWH() {
    double realHeight;
    double realWidth = maxWidth!;
    if (widget.project.paper != null &&
        widget.project.paper!.height != 0 &&
        widget.project.paper!.width != 0) {
      final ratioHW =
          widget.project.paper!.height / widget.project.paper!.width;
      // height > width
      if (ratioHW > 1) { 
        realHeight = maxHeight!;
        realWidth = realHeight * (1 / ratioHW);
        // height < width
      } else if (ratioHW < 1) {
        realWidth = maxWidth!;
        realHeight = realWidth * ratioHW;
        // height = width
      } else {
        realHeight = realWidth = maxWidth!;
      }
      return [realWidth, realHeight];
    } else {
      return [_getWidth(context), _getHeight(context)];
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.sizeOf(context);
    maxHeight ??= _size.width * 0.45;
    maxWidth ??= _size.width * 0.45;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(),
                Container(
                  key: _key,
                  width: _getRealWH()[0],
                  height: _getRealWH()[1],
                  decoration: BoxDecoration(
                      color: widget.project.backgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 0.5,
                          blurRadius: 5,
                          offset: const Offset(0, 1),
                        ),
                      ]),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      LayoutMedia(
                          indexImage: widget.indexImage,
                          project: widget.project,
                          layoutExtractList: widget.layoutExtractList,
                          widthAndHeight: _getRealWH(),
                          listWH: _getRealWH()),
                      widget.isFocusByLongPress
                          ? Positioned.fill(
                              top: -15,
                              left: -15,
                              child: GestureDetector(
                                onTap: widget.onRemove,
                                child: Container(
                                  alignment: Alignment.topLeft,
                                  child: Image.asset(
                                    pv.Provider.of<ThemeManager>(context)
                                            .isDarkMode
                                        ? "${pathPrefixIcon}icon_remove_dark.png"
                                        : "${pathPrefixIcon}icon_remove_light.png",
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                              ))
                          : const SizedBox(),
                    ],
                  ),
                ),
                const SizedBox(),
              ],
            ),
            WSpacer(
              height: 10,
            ),
            WTextContent(
              value: widget.title ?? "",
              textFontWeight: FontWeight.w600,
              textLineHeight: 14.32,
              textSize: 12,
              textColor: Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ],
        ),
      ),
    );
  }
}

// class WProjectItemEditor extends StatelessWidget {
//   final Project project;
//   final bool isFocusByLongPress;
//   /// index of image on project
//   final int indexImage;
//   final Function()? onRemove;
//   final String? title;
//   /// Use with layoutIndex is 0,1,2,3
//   final List<dynamic>? layoutExtractList;
//   final Function()? onTap;
//   final List<double>? ratioTarget;
//   const WProjectItemEditor(
//       {super.key,
//       required this.project,
//       this.isFocusByLongPress = false,
//       required this.indexImage,
//       this.title,
//       this.onRemove,
//       this.layoutExtractList,
//       this.onTap,
//       this.ratioTarget = LIST_RATIO_PROJECT_ITEM});
//   double _getWidth(BuildContext context) {
//     return MediaQuery.sizeOf(context).width * ratioTarget![0];
//   }
//   double _getHeight(BuildContext context) {
//     return MediaQuery.sizeOf(context).width * ratioTarget![1];
//   }
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(3),
//         constraints: const BoxConstraints(minHeight: 180),
//         child: Column(
//           children: [
//             Container(
//               width: _getWidth(context),
//               height: _getHeight(context) - 20,
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
//                     LayoutMedia(
//                       indexImage: indexImage,
//                       project: project,
//                       layoutExtractList: layoutExtractList,
//                       ratioTarget: ratioTarget!,
//                     ),
//                     isFocusByLongPress
//                         ? Positioned(
//                             top: -10,
//                             left: -10,
//                             child: GestureDetector(
//                               onTap: onRemove,
//                               child: Container(
//                                 alignment: Alignment.topLeft,
//                                 child: Image.asset(
//                                   pv.Provider.of<ThemeManager>(context)
//                                           .isDarkMode
//                                       ? "${pathPrefixIcon}icon_remove_dark.png"
//                                       : "${pathPrefixIcon}icon_remove_light.png",
//                                   width: 50,
//                                   height: 50,
//                                 ),
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
