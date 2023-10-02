import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/commons/themes.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/providers/project_provider.dart';
import 'package:photo_to_pdf/screens/module_editor/preview.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import "package:provider/provider.dart" as pv;

class WProjectItemHome extends ConsumerWidget {
  final Project project;
  final bool isFocusByLongPress;
  final int index;
  final Function? onRemove;
  final bool? isHaveTitle;
  final double? width;
  final void Function()? onTap;
  final List<dynamic>? layoutExtractList;
  const WProjectItemHome(
      {super.key,
      required this.project,
      required this.isFocusByLongPress,
      required this.index,
      this.onRemove,
      this.isHaveTitle = true,
      this.width = 160,
      this.onTap,
      this.layoutExtractList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(3),
        child: Column(
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: Center(
                child: Stack(
                  alignment: !isFocusByLongPress
                      ? AlignmentDirectional.center
                      : AlignmentDirectional.topStart,
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                            color: colorWhite,
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                  color: Color.fromRGBO(0, 0, 0, 0.1))
                            ]),
                      ),
                    ),
                    project.listMedia.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.all(9),
                            child:
                                _buildLayoutMedia(0, project, layoutExtractList)
                            // project.listMedia[0] is File
                            //     ? Image.file(project.listMedia[0])
                            //     : Image.asset(
                            //         project.listMedia[0],
                            //       ),
                            )
                        : const SizedBox(),
                    isFocusByLongPress
                        ? Positioned(
                            top: -12,
                            left: -12,
                            child: GestureDetector(
                              onTap: () {
                                final listProject = ref
                                    .watch(projectControllerProvider)
                                    .listProject;
                                listProject.removeAt(index);
                                ref
                                    .read(projectControllerProvider.notifier)
                                    .setProject(listProject);
                              },
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
            ),
            isHaveTitle!
                ? Column(
                    children: [
                      WSpacer(
                        height: 10,
                      ),
                      WTextContent(
                        value: project.title,
                        textFontWeight: FontWeight.w600,
                        textLineHeight: 14.32,
                        textSize: 12,
                        textColor:
                            Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ],
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}

class WProjectItemEditor extends ConsumerWidget {
  final Project project;
  final bool isFocusByLongPress;

  /// index og image on project
  final int indexImage;
  final Function? onRemove;
  final String? title;

  /// Use with layoutIndex is 1,2,3
  final List<dynamic>? layoutExtractList;

  const WProjectItemEditor(
      {super.key,
      required this.project,
      required this.isFocusByLongPress,
      required this.indexImage,
      this.title,
      this.onRemove,
      this.layoutExtractList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        pushCustomMaterialPageRoute(
            context,
            Preview(
              project: project,
            ));
      },
      child: Container(
        padding: const EdgeInsets.all(3),
        constraints: const BoxConstraints(minHeight: 180),
        child: Column(
          children: [
            Container(
              width: MediaQuery.sizeOf(context).width * 0.3,
              height: 150,
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
                    Container(
                      padding: const EdgeInsets.only(
                          top: 12, left: 12, right: 12, bottom: 12),
                      alignment: Alignment.center,
                      child: _buildLayoutMedia(
                          indexImage, project, layoutExtractList),
                    ),
                    isFocusByLongPress
                        ? Positioned(
                            top: -10,
                            left: -10,
                            child: GestureDetector(
                              onTap: () {
                                // final listProject = ref
                                //     .watch(projectControllerProvider)
                                //     .listProject;
                                // listProject.removeAt(index);
                                // ref
                                //     .read(projectControllerProvider.notifier)
                                //     .setProject(listProject);
                              },
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

Widget _buildImageWidget(dynamic imageData,
    {BoxFit? fit = BoxFit.cover, double? width, double? height}) {
  if (imageData == null) {
    return Image.asset(
      "${pathPrefixImage}blank_page.jpg",
      fit: fit,
      height: height,
      width: width,
    );
  } else {
    if (imageData is File) {
      return Image.file(
        imageData,
        fit: fit,
        height: height,
        width: width,
      );
    } else {
      return Image.asset(
        imageData,
        fit: fit,
        height: height,
        width: width,
      );
    }
  }
}

Widget _buildLayoutMedia(
    int indexImage, Project project, List<dynamic>? layoutExtractList) {
  if (project.layoutIndex == 0 && layoutExtractList == null) {
    return _buildImageWidget(project.listMedia[indexImage]);
  } else if (layoutExtractList != null && layoutExtractList.isNotEmpty) {
    if (project.layoutIndex == 1) {
      return Column(
        children: [
          Flexible(
              child: _buildImageWidget(
            layoutExtractList[0],
            height: 150,
            width: 150,
          )),
          WSpacer(
            height: 5,
          ),
          Flexible(
              child: _buildImageWidget(
            layoutExtractList[1],
            height: 150,
            width: 150,
          )),
        ],
      );
    } else if (project.layoutIndex == 2) {
      return Flex(
        direction: Axis.vertical,
        children: [
          Flexible(
              child: _buildImageWidget(
            layoutExtractList![0],
            width: 150,
          )),
          WSpacer(
            height: 5,
          ),
          Flex(
            direction: Axis.horizontal,
            children: [
              Flexible(
                  child: _buildImageWidget(
                layoutExtractList[1],
              )),
              WSpacer(
                width: 5,
              ),
              Flexible(
                child: _buildImageWidget(layoutExtractList[2]),
              ),
            ],
          )
        ],
      );
    } else {
      return Flex(
        direction: Axis.vertical,
        children: [
          Flex(
            direction: Axis.horizontal,
            children: [
              Flexible(child: _buildImageWidget(layoutExtractList![0])),
              WSpacer(
                width: 5,
              ),
              Flexible(
                child: _buildImageWidget(layoutExtractList![1]),
              ),
            ],
          ),
          WSpacer(
            height: 5,
          ),
          Flexible(
              child: _buildImageWidget(
            layoutExtractList![2],
            width: 150,
          )),
        ],
      );
    }
  } else {
    return SizedBox();
  }
}

class WProjectItemHomeBottom extends ConsumerWidget {
  final Project project;
  final bool isFocusByLongPress;
  final int index;
  final Function(dynamic srcMedia) onRemove;
  final bool? isHaveTitle;
  const WProjectItemHomeBottom({
    super.key,
    required this.project,
    required this.isFocusByLongPress,
    required this.index,
    required this.onRemove,
    this.isHaveTitle = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(3),
      child: Stack(
        children: [
          Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.29,
                    height: MediaQuery.sizeOf(context).width * 0.29,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: project.listMedia[index] is File
                          ? Image.file(
                              project.listMedia[index],
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              project.listMedia[index],
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  isFocusByLongPress
                      ? Positioned(
                          top: -13,
                          left: -13,
                          child: GestureDetector(
                            onTap: () {
                              onRemove(project.listMedia[index]);
                            },
                            child: Container(
                              alignment: Alignment.topLeft,
                              child: Image.asset(
                                pv.Provider.of<ThemeManager>(context).isDarkMode
                                    ? "${pathPrefixIcon}icon_remove_dark.png"
                                    : "${pathPrefixIcon}icon_remove_light.png",
                                width: 40,
                                height: 40,
                              ),
                            ),
                          ))
                      : const SizedBox()
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18), color: colorBlue),
                child: Center(
                  child: WTextContent(
                    value: (index + 1).toString(),
                    textAlign: TextAlign.center,
                    textColor: colorWhite,
                    textSize: 16,
                  ),
                )),
          )
        ],
      ),
    );
  }
}
