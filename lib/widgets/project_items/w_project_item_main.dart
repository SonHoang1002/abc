import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/commons/themes.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/screens/module_editor/preview.dart';
import 'package:photo_to_pdf/widgets/project_items/w_project_ratio.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import "package:provider/provider.dart" as pv;

class WProjectItemEditor extends StatelessWidget {
  final Project project;
  final bool isFocusByLongPress;

  /// index of image on project
  final int indexImage;
  final Function? onRemove;
  final String? title;

  /// Use with layoutIndex is 1,2,3
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
  double _getWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width * ratioTarget![0];
  }

  double _getHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).width * ratioTarget![1];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        List<double> newRatioTarget = LIST_RATIO_PREVIEW;
        if (project.paper != null &&
            project.paper!.height != 0 &&
            project.paper!.width != 0) {
          newRatioTarget = [
            LIST_RATIO_PREVIEW[0],
            LIST_RATIO_PREVIEW[0] * project.paper!.height / project.paper!.width
          ];
        }
        pushCustomMaterialPageRoute(
            context,
            PreviewProject(
              project: project,
              indexPage: indexImage,
              ratioTarget: newRatioTarget,
            ));
      },
      child: Container(
        padding: const EdgeInsets.all(3),
        constraints: const BoxConstraints(minHeight: 180),
        child: Column(
          children: [
            Container(
              width: _getWidth(context),
              height: _getHeight(context),
              decoration:
                  BoxDecoration(color: project.backgroundColor, boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 0.5,
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ]),
              child: Center(
                child: Stack(
                  children: [
                    LayoutMedia(
                      indexImage: indexImage,
                      project: project,
                      layoutExtractList: layoutExtractList,
                      ratioTarget:
                          ratioTarget! ,
                    ),
                    isFocusByLongPress
                        ? Positioned(
                            top: -10,
                            left: -10,
                            child: Container(
                              alignment: Alignment.topLeft,
                              child: Image.asset(
                                pv.Provider.of<ThemeManager>(context).isDarkMode
                                    ? "${pathPrefixIcon}icon_remove_dark.png"
                                    : "${pathPrefixIcon}icon_remove_light.png",
                                width: 50,
                                height: 50,
                              ),
                            ))
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
            WSpacer(
              height: 10,
            ),
            WTextContent(
              value: title ?? "",
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
