import 'dart:io';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/extract_list.dart';
import 'package:photo_to_pdf/helpers/random_number.dart';
import 'package:photo_to_pdf/helpers/render_boxfit.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/project_items/w_layout_media_project.dart';
import 'package:photo_to_pdf/widgets/w_button.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class PreviewProject extends StatefulWidget {
  final Project project;
  final int indexPage;
  final List<double>? ratioTarget;
  final Function()? onClose;
  const PreviewProject(
      {super.key,
      required this.project,
      required this.indexPage,
      this.ratioTarget = LIST_RATIO_PREVIEW,
      this.onClose});

  @override
  State<PreviewProject> createState() => _PreviewState();
}

class _PreviewState extends State<PreviewProject>
    with SingleTickerProviderStateMixin {
  late Project _project;
  late List _previewExtractList;
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  late int _indexCurrentCarousel;

  @override
  void initState() {
    _project = widget.project;
    _previewExtractList = [];
    if (_project.listMedia.isNotEmpty) {
      if (_project.useAvailableLayout == true) {
        _previewExtractList = extractList1(
            LIST_LAYOUT_SUGGESTION[_project.layoutIndex], _project.listMedia);
      } else {
        _previewExtractList =
            extractList(_project.placements!.length, _project.listMedia);
      }
    } else {
      _previewExtractList = [BLANK_PAGE];
    }

    if (_project.coverPhoto?.frontPhoto != null) {
      _previewExtractList
          .insert(0, {"front_cover": _project.coverPhoto!.frontPhoto});
    }
    if (_project.coverPhoto?.backPhoto != null) {
      _previewExtractList.add({"back_cover": _project.coverPhoto!.backPhoto});
    }

    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.ease);
    controller.addListener(() {
      setState(() {});
    });
    controller.forward();
    _indexCurrentCarousel = widget.indexPage;
    if (_project.coverPhoto?.frontPhoto != null) {
      _indexCurrentCarousel = widget.indexPage + 1;
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _previewExtractList = [];
    _project = Project(id: 0, listMedia: []);
    _previewExtractList.clear();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.project.coverPhoto?.frontPhoto != null) {
    //   _indexCurrentCarousel = widget.indexPage + 1;
    // } else {
    //   _indexCurrentCarousel = widget.indexPage;
    // }
    final size = MediaQuery.sizeOf(context);
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            color: const Color.fromRGBO(0, 0, 0, 0.1),
          ),
        ),
        ScaleTransition(
          scale: scaleAnimation,
          child: Column(
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
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
                                _project,
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
                          height: size.height * 0.9,
                          aspectRatio: size.height / size.width + 1,
                          initialPage: _indexCurrentCarousel,
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
                        controller.reverse().then((value) {
                          widget.onClose != null ? widget.onClose!() : null;
                        });
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
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
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: WProjectItemPreview(
            project: _project,
            indexImage: 0,
            title: "",
            ratioTarget: ratioTarget,
          ),
        );
      } else {
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

  List<double> _getRealWH(BuildContext context) {
    final MAXWIDTH = MediaQuery.sizeOf(context).width * 0.7;
    final MAXHEIGHT = MediaQuery.sizeOf(context).height * 0.55;

    double height = MAXHEIGHT;
    double width = MAXWIDTH;
    if (project.paper != null &&
        project.paper!.height != 0 &&
        project.paper!.width != 0) {
      final ratioHW = project.paper!.height / project.paper!.width;
      // height > width
      if (ratioHW > 1) {
        height = width * ratioHW;
        if (height > MAXHEIGHT) {
          height = MAXHEIGHT;
          width = height * (1 / ratioHW);
        }
        // height < width
      } else if (ratioHW < 1) {
        width = height * (1 / ratioHW);
        if (width > MAXWIDTH) {
          width = MAXWIDTH;
          height = width * ratioHW;
        }
        // height = width
      } else {
        height = width;
      }
    }
    return [width, height];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                      width: _getRealWH(context)[0],
                      height: _getRealWH(context)[1],
                      decoration: BoxDecoration(
                          color: project.backgroundColor,
                          boxShadow: [
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
                              widthAndHeight: _getRealWH(context),
                              listWH: _getRealWH(context),
                            )),
                  coverFile != null
                      ? Positioned.fill(
                          child: Image.file(
                          coverFile!,
                          fit: project.paper?.title == LIST_PAGE_SIZE[0].title
                              ? BoxFit.fitWidth
                              : BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ))
                      : const SizedBox()
                ],
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
      ],
    );
  }
}
