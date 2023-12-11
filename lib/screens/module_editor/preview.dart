import 'dart:io';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/extract_list.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/providers/ratio_images_provider.dart';
import 'package:photo_to_pdf/widgets/project_items/w_layout_media_project.dart';
import 'package:photo_to_pdf/widgets/w_button.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class PreviewProject extends ConsumerStatefulWidget {
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
  ConsumerState<PreviewProject> createState() => _PreviewState();
}

class _PreviewState extends ConsumerState<PreviewProject>
    with SingleTickerProviderStateMixin {
  late Project _project;
  late List _previewExtractList;
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  late int _indexCurrentCarousel;
  List<double> _listRatioWHImage = [];
  late Size _size;
  @override
  void initState() {
    _project = widget.project;
    _previewExtractList = [];
    if (_project.listMedia.isNotEmpty) {
      if (_project.useAvailableLayout == true) {
        _previewExtractList = extractList1(
            LIST_LAYOUT_SUGGESTION[_project.layoutIndex], _project.listMedia);
        if (_project.paper?.title == LIST_PAGE_SIZE[0].title) {
          _listRatioWHImage =
              List.from(ref.read(ratioWHImagesControllerProvider).listRatioWH);
          if (_project.coverPhoto?.frontPhoto != null) {
            _listRatioWHImage.insert(0, 1 / INFINITY_NUMBER - 1);
          }
          if (_project.coverPhoto?.backPhoto != null) {
            _listRatioWHImage.add(1 / INFINITY_NUMBER - 1);
          }
        }
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

  Widget _buildTitleCarouselItem(int currentIndex) {
    String value = "";
    if (_project.coverPhoto?.frontPhoto != null) {
      value = "Page ${currentIndex}";
    } else {
      value = "Page ${currentIndex + 1}";
    }
    if (_project.coverPhoto?.frontPhoto != null && currentIndex == 0 ||
        _project.coverPhoto?.backPhoto != null &&
            currentIndex == _previewExtractList.length - 1) {
      value = "Cover";
    }

    return WTextContent(
      value: value,
      textSize: 12,
      textFontWeight: FontWeight.w600,
      textLineHeight: 14.32,
      textColor: Theme.of(context).textTheme.bodyMedium!.color,
    );
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.sizeOf(context);
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
                margin: EdgeInsets.only(
                    top: 20 + MediaQuery.of(context).padding.top),
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
                        height: _size.height * (589 / 844) * 0.95,
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      CarouselSlider.builder(
                        itemCount: _previewExtractList.length,
                        itemBuilder: (context, currentIndex, afterIndex) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const SizedBox(),
                                    _buildImageContent(
                                      _project,
                                      currentIndex,
                                      widget.ratioTarget!,
                                    ),
                                    const SizedBox(),
                                  ],
                                ),
                              ),
                              _buildTitleCarouselItem(currentIndex),
                              WSpacer(
                                height: 20,
                              ),
                            ],
                          );
                        },
                        options: CarouselOptions(
                          height: _size.height * (589 / 844) * 0.95,
                          aspectRatio: _size.height / _size.width + 1,
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
                    margin: EdgeInsets.only(
                        bottom: 30 + MediaQuery.of(context).padding.bottom),
                    width: _size.width * 0.8,
                    child: WButtonFilled(
                      message: "Close",
                      textColor: colorBlue,
                      height: 60,
                      padding: EdgeInsets.zero,
                      backgroundColor: colorWhite,
                      onPressed: () {
                        /// data binding 2 chiều ??
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
      if (project.paper?.title == LIST_PAGE_SIZE[0].title) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          constraints: BoxConstraints(maxHeight: _size.height * 0.45),
          alignment: Alignment.center,
          child: Image.file(
            _previewExtractList[currentIndex]?['front_cover'],
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        );
      }
      return WProjectItemPreview(
        project: _project,
        indexImage: 0,
        coverFile: _previewExtractList[currentIndex]?['front_cover'],
        ratioTarget: ratioTarget,
        ratioWHImages: _listRatioWHImage,
      );
    }
    if (_previewExtractList[currentIndex] is! List &&
        _previewExtractList[currentIndex] is! File &&
        _previewExtractList[currentIndex] is! String &&
        _previewExtractList[currentIndex]?['back_cover'] != null) {
      if (project.paper?.title == LIST_PAGE_SIZE[0].title) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          constraints: BoxConstraints(maxHeight: _size.height * 0.45),
          alignment: Alignment.center,
          child: Image.file(
            _previewExtractList[currentIndex]?['back_cover'],
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        );
      }
      return WProjectItemPreview(
        project: _project,
        indexImage: 0,
        coverFile: _previewExtractList[currentIndex]?['back_cover'],
        ratioTarget: ratioTarget,
        ratioWHImages: _listRatioWHImage,
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
      if (_project.listMedia.isEmpty) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: WProjectItemPreview(
            project: _project,
            indexImage: 0,
            title: "",
            ratioTarget: ratioTarget,
            ratioWHImages: _listRatioWHImage,
          ),
        );
      }
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: WProjectItemPreview(
          project: _project,
          indexImage: indexExtract,
          layoutExtractList: _previewExtractList[indexExtract],
          title: "",
          ratioTarget: ratioTarget,
          ratioWHImages: _listRatioWHImage,
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
            ratioWHImages: _listRatioWHImage,
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
            ratioWHImages: _listRatioWHImage,
          ),
        );
      }
    }
  }
}

// ignore: must_be_immutable
class WProjectItemPreview extends ConsumerWidget {
  final Project project;

  /// index of image on project
  final int indexImage;
  final Function? onRemove;
  final String? title;
  final File? coverFile;

  final List<dynamic>? layoutExtractList;
  final List<double> ratioTarget;
  final List<double> ratioWHImages;

  WProjectItemPreview(
      {super.key,
      required this.project,
      required this.indexImage,
      required this.ratioWHImages,
      this.title,
      this.onRemove,
      this.layoutExtractList,
      this.coverFile,
      required this.ratioTarget});
  late Size _size;
  List<double> _getRealWH(BuildContext context) {
    final MAXWIDTH = MediaQuery.sizeOf(context).width * 0.6;
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
  Widget build(BuildContext context, WidgetRef ref) {
    _size = MediaQuery.sizeOf(context);
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            child: Column(
              children: [
                Stack(
                  children: [
                    (project.paper?.title == LIST_PAGE_SIZE[0].title &&
                            layoutExtractList != null)
                        ? 1 / ratioWHImages[indexImage] > INFINITY_NUMBER
                            ? Image.file(
                                layoutExtractList![0][0],
                                fit: BoxFit.fill,
                                width: _getRealWH(context)[0],
                                filterQuality: FilterQuality.high,
                              )
                            : Container(
                                constraints: BoxConstraints(
                                    maxHeight: _size.height * 0.45),
                                alignment: Alignment.center,
                                child: AspectRatio(
                                  aspectRatio: ratioWHImages[indexImage],
                                  child: Image.file(
                                    layoutExtractList![0][0],
                                    fit: BoxFit.fill,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              )
                        : Container(
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
      ),
    );
  }
}
