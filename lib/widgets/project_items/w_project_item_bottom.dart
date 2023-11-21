import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/commons/themes.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class WProjectItemHomeBottom extends StatelessWidget {
  final Project project;
  final bool isFocusByLongPress;
  final int index;
  final Function(dynamic srcMedia) onRemove;
  final List<GlobalKey>? imageKeys;
  final bool? isHaveTitle;
  const WProjectItemHomeBottom({
    super.key,
    required this.project,
    required this.isFocusByLongPress,
    required this.index,
    required this.onRemove,
    this.imageKeys,
    this.isHaveTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    print("imageKeys ${imageKeys?.length}");
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
                              key: imageKeys?[index],
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              project.listMedia[index],
                              key: imageKeys?[index],
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
                                Provider.of<ThemeManager>(context).isDarkMode
                                    ? "${PATH_PREFIX_ICON}icon_remove_dark.png"
                                    : "${PATH_PREFIX_ICON}icon_remove_light.png",
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
