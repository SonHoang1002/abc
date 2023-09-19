import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/providers/project_provider.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class WProjectItemHome extends ConsumerWidget {
  final String src;
  final bool isFocusByLongPress;
  final int index;
  final Function? onLongPress;
  final bool? isHaveTitle;
  final double? width;
  const WProjectItemHome(
      {super.key,
      required this.src,
      required this.isFocusByLongPress,
      required this.index,
      this.onLongPress,
      this.isHaveTitle = true,
      this.width = 160});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(3),
      child: Column(
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: Center(
              child: Stack(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.only(top: 12, left: 12, right: 12),
                    child: Image.asset(
                      src,
                    ),
                  ),
                  isFocusByLongPress
                      ? Positioned(
                          top: -10,
                          left: -10,
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
                                "${pathPrefixIcon}icon_remove_1.png",
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
                      value: "Project ${index + 1}",
                      textFontWeight: FontWeight.w600,
                      textLineHeight: 14.32,
                      textSize: 12,
                    ),
                  ],
                )
              : const SizedBox()
        ],
      ),
    );
  }
}

class WProjectItemHomeBottom extends ConsumerWidget {
  final String src;
  final bool isFocusByLongPress;
  final int index;
  final Function? onLongPress;
  final bool? isHaveTitle;
  const WProjectItemHomeBottom({
    super.key,
    required this.src,
    required this.isFocusByLongPress,
    required this.index,
    this.onLongPress,
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
                      child: Image.asset(
                        src,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  isFocusByLongPress
                      ? Positioned(
                          top: -20,
                          left: -20,
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
                                "${pathPrefixIcon}icon_remove_1.png",
                                width: 50,
                                height: 50,
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

class WProjectItemEditor extends ConsumerWidget {
  final String src;
  final bool isFocusByLongPress;
  final int index;
  final Function? onLongPress;
  final String? title;
  const WProjectItemEditor({
    super.key,
    required this.src,
    required this.isFocusByLongPress,
    required this.index,
    this.title,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(3),
      height: 180,
      constraints: const BoxConstraints(minHeight: 180),
      child: Column(
        children: [
          Container(
            width: 125,
            height: 125,
            color: colorWhite,
            child: Center(
              child: Stack(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.only(top: 12, left: 12, right: 12),
                    constraints: const BoxConstraints(maxHeight: 110),
                    child: Image.asset(
                      src,
                    ),
                  ),
                  isFocusByLongPress
                      ? Positioned(
                          top: -10,
                          left: -10,
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
                                "${pathPrefixIcon}icon_remove_1.png",
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
            textColor: const Color.fromRGBO(0, 0, 0, 0.5),
          ),
        ],
      ),
    );
  }
}
