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
  final List<double>? ratioTarget;
  const PreviewProject(
      {super.key,
      required this.project,
      required this.indexPage,
      this.ratioTarget = LIST_RATIO_PREVIEW});

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
      } else if (_project.layoutIndex == 1) {
        _previewExtractList = extractList(2, _project.listMedia);
      } else if ([2, 3].contains(_project.layoutIndex)) {
        _previewExtractList = extractList(3, _project.listMedia);
      }
    } else {
      _previewExtractList =
          extractList(_project.placements!.length, _project.listMedia);
    }

    if (_project.coverPhoto?.frontPhoto != null) {
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
    print(
        "extractList1(LIST_LAYOUT_SUGGESTION[0], _project.listMedia) ${extractList1(LIST_LAYOUT_SUGGESTION[0], _project.listMedia)}");
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
                              _buildImageContent(
                                widget.project,
                                currentIndex,
                                widget.ratioTarget!,
                              ),
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
                          /// không hiểu tại sao lại data binding 2 chiều ??
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
                          Navigator.of(context).pop();
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

  Widget _buildImageContent(
      Project project, int currentIndex, List<double> ratioTarget) {
    if (_previewExtractList[currentIndex] is! List &&
        _previewExtractList[currentIndex] is! File &&
        _previewExtractList[currentIndex] is! String &&
        _previewExtractList[currentIndex]?['front_cover'] != null) {
      return Container(
        margin: const EdgeInsets.only(right: 10),
        child: WProjectItemPreview(
          project: _project,
          indexImage: 0,
          coverFile: _previewExtractList[currentIndex]?['front_cover'],
          ratioTarget: ratioTarget,
        ),
      );
    }
    if (_previewExtractList[currentIndex] is! List &&
        _previewExtractList[currentIndex] is! File &&
        _previewExtractList[currentIndex] is! String &&
        _previewExtractList[currentIndex]?['back_cover'] != null) {
      return Container(
        margin: const EdgeInsets.only(right: 10),
        child: WProjectItemPreview(
          project: _project,
          indexImage: 0,
          coverFile: _previewExtractList[currentIndex]?['back_cover'],
          ratioTarget: ratioTarget,
        ),
      );
    }

    return _buildPreviewItem(
        indexExtract: currentIndex, ratioTarget: ratioTarget);
  }

  Widget _buildPreviewItem({
    required int indexExtract,
    required List<double> ratioTarget,
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
          ratioTarget: ratioTarget,
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
            ratioTarget: ratioTarget,
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
              ratioTarget: ratioTarget,
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
              ratioTarget: ratioTarget,
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
              ratioTarget: ratioTarget,
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
  final List<double> ratioTarget;

  const WProjectItemPreview(
      {super.key,
      required this.project,
      required this.indexImage,
      this.title,
      this.onRemove,
      this.layoutExtractList,
      this.coverFile,
      required this.ratioTarget});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          child: Column(
            children: [
              Container(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height *
                          (589 / 844) *
                          0.95),
                  width: MediaQuery.sizeOf(context).width * ratioTarget[0],
                  height: MediaQuery.sizeOf(context).width * ratioTarget[1],
                  decoration:
                      BoxDecoration(color: project.backgroundColor, boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 0.5,
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ]),
                  child: coverFile != null
                      ? const SizedBox()
                      : LayoutMedia(
                          indexImage: indexImage,
                          project: project,
                          layoutExtractList: layoutExtractList,
                          ratioTarget: ratioTarget,
                        )),
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
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
              ))
            : const SizedBox()
      ],
    );
  }
}
