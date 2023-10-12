import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/extract_list.dart';
import 'package:photo_to_pdf/helpers/random_number.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/project_items/w_project_ratio.dart';
import 'package:photo_to_pdf/widgets/w_button.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class PreviewProject extends StatefulWidget {
  final Project project;
  final int indexPage;
  const PreviewProject({
    super.key,
    required this.project,
    required this.indexPage,
  });

  @override
  State<PreviewProject> createState() => _PreviewState();
}

class _PreviewState extends State<PreviewProject> {
  late Project _project;
  late List _previewExtractList;
  @override
  void initState() {
    _project = widget.project;
    _previewExtractList = [];
    if (_project.useAvailableLayout == true) {
      if (_project.layoutIndex == 0) {
        _previewExtractList = _project.listMedia;
      } else if (_project.layoutIndex == 0) {
        _previewExtractList = extractList(2, _project.listMedia);
      } else if ([2, 3].contains(_project.layoutIndex)) {
        _previewExtractList = extractList(3, _project.listMedia);
      }
    } else {
      _previewExtractList =
          extractList(_project.placements!.length, _project.listMedia);
    }
    if (_project.coverPhoto != null) {
      _previewExtractList
          .insert(0, {"front_cover": _project.coverPhoto!.frontPhoto});
    }
    if (_project.coverPhoto?.backPhoto != null) {
      _previewExtractList.add({"back_cover": _project.coverPhoto!.backPhoto});
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _previewExtractList = [];
    _project = Project(id: 0, listMedia: []);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: const Color.fromRGBO(0, 0, 0, 0.1),
            ),
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: WTextContent(
                    value: "Preview",
                    textSize: 16,
                    textLineHeight: 19.09,
                    textColor: Theme.of(context).textTheme.displayLarge!.color,
                  ),
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: size.height * (589 / 844) * 0.95,
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      CarouselSlider.builder(
                        itemCount: _previewExtractList.length,
                        itemBuilder: (context, currentIndex, afterIndex) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildImageContent(widget.project, currentIndex),
                              WSpacer(
                                width: 40,
                              ),
                              WTextContent(
                                value: "Page ${currentIndex + 1}",
                                textSize: 12,
                                textFontWeight: FontWeight.w600,
                                textLineHeight: 14.32,
                                textColor: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              )
                            ],
                          );
                        },
                        options: CarouselOptions(
                          height: size.height * 0.8,
                          aspectRatio: size.height / size.width + 1,
                          initialPage: 0,
                          scrollPhysics: const BouncingScrollPhysics(),
                          enableInfiniteScroll: false,
                          autoPlayCurve: Curves.fastOutSlowIn,
                          onPageChanged: (index, reason) {},
                          scrollDirection: Axis.horizontal,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    Container(
                      margin: const EdgeInsets.only(bottom: 30),
                      width: size.width * 0.8,
                      child: WButtonFilled(
                        message: "Close",
                        textColor: colorBlue,
                        height: 60,
                        backgroundColor: colorWhite,
                        onPressed: () {
                          /// không hiểu tại sao lại data binding 2 chiều ?? -> đành phải làm chiêu này
                          setState(() {
                            if (_project.coverPhoto?.frontPhoto != null) {
                              _previewExtractList.removeAt(
                                0,
                              );
                            }
                            if (_project.coverPhoto?.backPhoto != null) {
                              _previewExtractList.removeLast();
                            }
                          });
                          // Future.delayed(const Duration(milliseconds: 200), () {
                          Navigator.of(context).pop();
                          // });
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent(Project project, int currentIndex) {
    if (_previewExtractList[currentIndex] is! List &&
        _previewExtractList[currentIndex] is! File &&
        _previewExtractList[currentIndex]?['front_cover'] != null) {
      return WProjectItemPreview(
        project: _project,
        indexImage: 0,
        coverFile: _previewExtractList[currentIndex]?['front_cover'],
      );
    }
    if (_previewExtractList[currentIndex] is! List &&
        _previewExtractList[currentIndex] is! File &&
        _previewExtractList[currentIndex]?['back_cover'] != null) {
      return WProjectItemPreview(
        project: _project,
        indexImage: 0,
        coverFile: _previewExtractList[currentIndex]?['back_cover'],
      );
    }
    return _buildPreviewItem(indexExtract: currentIndex);
  }

  Widget _buildPreviewItem({
    required int indexExtract,
  }) {
    if (_project.useAvailableLayout != true &&
        _project.placements != null &&
        _project.placements!.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: WProjectItemPreview(
          project: _project,
          indexImage: indexExtract,
          layoutExtractList: _previewExtractList[indexExtract],
          title: "",
        ),
      );
    } else {
      if (_project.listMedia.isEmpty) {
        final blankProject = Project(
            id: getRandomNumber(),
            listMedia: ["${pathPrefixImage}blank_page.jpg"]);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: WProjectItemPreview(
            project: blankProject,
            indexImage: 0,
            title: "",
          ),
        );
      } else {
        if (_project.layoutIndex == 0) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: WProjectItemPreview(
              project: _project,
              indexImage: indexExtract,
              title: "",
            ),
          );
        } else if (_project.layoutIndex == 1) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: WProjectItemPreview(
              project: _project,
              indexImage: indexExtract,
              layoutExtractList: _previewExtractList[indexExtract],
              title: "",
            ),
          );
        } else if ([2, 3].contains(_project.layoutIndex)) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: WProjectItemPreview(
              project: _project,
              indexImage: indexExtract,
              layoutExtractList: _previewExtractList[indexExtract],
              title: "",
            ),
          );
        } else {
          return Container();
        }
      }
    }
  }
}

class WProjectItemPreview extends StatelessWidget {
  final Project project;

  /// index of image on project
  final int indexImage;
  final Function? onRemove;
  final String? title;
  final File? coverFile;

  /// Use with layoutIndex is 1,2,3
  final List<dynamic>? layoutExtractList;

  const WProjectItemPreview(
      {super.key,
      required this.project,
      required this.indexImage,
      this.title,
      this.onRemove,
      this.layoutExtractList,
      this.coverFile});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          child: Column(
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width * LIST_RATIO_PREVIEW[0],
                height:
                    MediaQuery.sizeOf(context).width * LIST_RATIO_PREVIEW[1],
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
                      coverFile != null
                          ? const SizedBox()
                          : LayoutMedia(
                              indexImage: indexImage,
                              project: project,
                              layoutExtractList: layoutExtractList,
                              ratioTarget: LIST_RATIO_PREVIEW,
                            ),
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
        coverFile != null
            ? Positioned.fill(
                child: Container(
                margin: const EdgeInsets.fromLTRB(3, 3, 3, 29),
                child: Image.file(
                  coverFile!,
                  fit: BoxFit.fitHeight,
                  filterQuality: FilterQuality.medium,
                ),
              ))
            : const SizedBox()
      ],
    );
  }
}
