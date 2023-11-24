import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/commons/themes.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/project_items/w_layout_media_project.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import "package:provider/provider.dart" as pv;

// ignore: must_be_immutable
class WProjectItemEditor extends ConsumerWidget {
  final Project project;
  final bool isFocusByLongPress;

  /// index of image on project
  final int indexImage;
  final Function()? onRemove;
  final String? title;
  final List<dynamic>? layoutExtractList;
  final Function()? onTap;
  final List<double>? ratioTarget;
  // kiem tra xem co uu tien dung anh bia de hien thi khong
  final bool? useCoverPhoto;
  // chi su dung key nay trong truong hop paper size la none,
  // nham muc dich lay ra ratio width - height cua anh, phuc vu cho viec tao pdf
  final GlobalKey? imageKey;
  final List<double>? ratioWHImages;

  WProjectItemEditor(
      {super.key,
      required this.project,
      required this.indexImage,
      this.isFocusByLongPress = false,
      this.title,
      this.onRemove,
      this.layoutExtractList,
      this.onTap,
      this.useCoverPhoto,
      this.imageKey,
      this.ratioWHImages,
      this.ratioTarget = LIST_RATIO_PROJECT_ITEM});

  double? maxHeight;
  double? maxWidth;
  late Size _size;
  List<BoxShadow> listShadow = [
    const BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.3),
        // color: colorRed,
        // spreadRadius: -30,
        // blurRadius: 40,
        // offset: Offset(0, 7),
        spreadRadius: -20,
        blurRadius: 40,
        offset: Offset(0, 5),
        blurStyle: BlurStyle.normal)
  ];

  double _getWidth(BuildContext context) {
    return (MediaQuery.sizeOf(context).width * 0.4) * (1 + ratioTarget![0]);
  }

  double _getHeight(BuildContext context) {
    return (MediaQuery.sizeOf(context).width * 0.3) * (1 + ratioTarget![1]);
  }

  List<double> _getRealWH(BuildContext context) {
    double realHeight;
    double realWidth = maxWidth!;
    if (project.paper != null &&
        project.paper!.height != 0 &&
        project.paper!.width != 0) {
      final ratioHW = project.paper!.height / project.paper!.width;
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

  Widget _buildNormalLayoutMedia(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        width: _getRealWH(context)[0],
        height: _getRealWH(context)[1],
        decoration: BoxDecoration(
            // border: Border.all(color: grey.withOpacity(0.4), width: 0.4),
            color: project.backgroundColor,
            boxShadow: listShadow),
        child: Stack(
          alignment: Alignment.center,
          children: [
            LayoutMedia(
                indexImage: indexImage,
                project: project,
                layoutExtractList: layoutExtractList,
                widthAndHeight: _getRealWH(context),
                useCoverPhoto: useCoverPhoto,
                listWH: _getRealWH(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildNoneLayoutMedia(BuildContext context) {
    dynamic mediaValue = layoutExtractList?[0][0];

    if (project.listMedia.isEmpty ||
        (project.listMedia.length == 1 && project.listMedia[0] is String)) {
      mediaValue = BLANK_PAGE;
    }
    if (project.coverPhoto?.frontPhoto != null && useCoverPhoto == true) {
      mediaValue = project.coverPhoto?.frontPhoto;
    }
    return SizedBox(
      width: _getRealWH(context)[0],
      height: _size.width * 0.45,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  boxShadow: listShadow,
                  // border: Border.all(color: grey.withOpacity(0.4), width: 0.4),
                ),
                child: _buildImageWidget(context, project, mediaValue),
              ),
              Stack(
                children: [
                  const SizedBox(
                    width: 30,
                    height: 30,
                  ),
                  isFocusByLongPress
                      ? Positioned.fill(
                          top: -10,
                          left: -10,
                          child: GestureDetector(
                            onTap: onRemove,
                            child: Image.asset(
                              pv.Provider.of<ThemeManager>(context).isDarkMode
                                  ? "${PATH_PREFIX_ICON}icon_remove_dark.png"
                                  : "${PATH_PREFIX_ICON}icon_remove_light.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(
    BuildContext context,
    Project project,
    dynamic mediaValue,
  ) {
    if (mediaValue == null) {
      return Container();
    } else {
      if (mediaValue is File) {
        return Image.file(
          mediaValue,
          key: imageKey,
          fit: BoxFit.fitWidth,
          filterQuality: FilterQuality.high,
          // width: _getRealWH(context)[0],
        );
      } else {
        if (mediaValue is String) {
          return Image.asset(
            mediaValue,
            key: imageKey,
            fit: BoxFit.fitWidth,
            filterQuality: FilterQuality.high,
          );
        } else {
          return const SizedBox();
        }
      }
    }
  }

  // hien anh anh bia(cover photo) khi cho phep su dung coverphoto va data ko null,
  Widget _buildMainRootItem(BuildContext context) {
    if ((project.paper?.title != LIST_PAGE_SIZE[0].title)) {
      return Container(
          // color: colorRed.withOpacity(0.3),
          child: _buildNormalLayoutMedia(context));
    }
    return Container(
        // color: colorBlue.withOpacity(0.3),
        child: _buildNoneLayoutMedia(context));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _size = MediaQuery.sizeOf(context);
    maxHeight ??= _size.width * 0.415;
    maxWidth ??= _size.width * 0.415;
    return GestureDetector(
      onTap: onTap,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const SizedBox(), _buildMainRootItem(context)],
                ),
                Container(
                    height: _getRealWH(context)[1] + 20,
                    width: _getRealWH(context)[0] + 20,
                    alignment: Alignment.topLeft,
                    child: Stack(
                      children: [
                        const SizedBox(
                          width: 30,
                          height: 30,
                        ),
                        isFocusByLongPress &&
                                project.paper?.title != LIST_PAGE_SIZE[0].title
                            ? Positioned.fill(
                                top: -10,
                                left: -10,
                                child: GestureDetector(
                                  onTap: onRemove,
                                  child: Image.asset(
                                    pv.Provider.of<ThemeManager>(context)
                                            .isDarkMode
                                        ? "${PATH_PREFIX_ICON}icon_remove_dark.png"
                                        : "${PATH_PREFIX_ICON}icon_remove_light.png",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ))
              ],
            ),
            WSpacer(
              height: 5,
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
