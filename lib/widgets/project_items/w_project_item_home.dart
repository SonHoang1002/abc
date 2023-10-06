import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/commons/themes.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/providers/project_provider.dart';
import 'package:photo_to_pdf/widgets/project_items/w_project_ratio.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import "package:provider/provider.dart" as pv;

class WProjectItemHome extends ConsumerStatefulWidget {
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
  ConsumerState<WProjectItemHome> createState() => _WProjectItemHomeState();
}

class _WProjectItemHomeState extends ConsumerState<WProjectItemHome> {
  final GlobalKey keyTest = GlobalKey();
  @override
  Widget build(BuildContext context) {
    // final renderBox = keyTest.currentContext?.findRenderObject() as RenderBox?;
    // print("keyTest ${renderBox?.size}");
    return GestureDetector(
      // key: keyTest,
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(3),
        child: Column(
          children: [
            Container(
              height: 155.6,
              width: MediaQuery.sizeOf(context).width * 0.3,
              child: Center(
                child: Stack(
                  alignment: !widget.isFocusByLongPress
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
                    widget.project.listMedia.isNotEmpty
                        ? Container(
                            key: keyTest,
                            padding: const EdgeInsets.all(3),
                            child: buildLayoutMedia(
                                0, widget.project, widget.layoutExtractList,LIST_RATIO_PROJECT_ITEM))
                        : Image.asset("${pathPrefixImage}blank_page.jpg"),
                    widget.isFocusByLongPress
                        ? Positioned(
                            top: -12,
                            left: -12,
                            child: GestureDetector(
                              onTap: () {
                                final listProject = ref
                                    .watch(projectControllerProvider)
                                    .listProject;
                                listProject.removeAt(widget.index);
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
            widget.isHaveTitle!
                ? Column(
                    children: [
                      WSpacer(
                        height: 10,
                      ),
                      WTextContent(
                        value: widget.project.title,
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
