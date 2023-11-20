import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/caculate_padding.dart';
import 'package:photo_to_pdf/helpers/caculate_spacing.dart';
import 'package:photo_to_pdf/helpers/render_boxfit.dart';
import 'package:photo_to_pdf/models/project.dart';

class LayoutMedia extends ConsumerStatefulWidget {
  // final String type;
  final int indexImage;
  final Project project;
  final List<dynamic>? layoutExtractList;
  final List<double> widthAndHeight;
  final List<double>? listWH;
  final bool? useCoverPhoto;
  const LayoutMedia(
      {super.key,
      // required this.type,
      required this.project,
      required this.indexImage,
      required this.layoutExtractList,
      required this.widthAndHeight,
      this.useCoverPhoto,
      this.listWH});

  @override
  ConsumerState<LayoutMedia> createState() => _LayoutMediaState();
}

class _LayoutMediaState extends ConsumerState<LayoutMedia> {
  Widget buildCoreLayoutMedia(
    int indexImage,
    Project project,
    List<dynamic>? layoutExtractList,
    List<double> widthAndHeight,
  ) {
    // truong hop co frontPhoto
    // truong hop kich thuoc pdf tu do
    // truong hop lay anh co chieu rong co dinh, chieu dai tu do
    // truong hop project rong hoac co 1 anh nhung ma la blank_image
    // truong hop layout co placement
    // truong hop su dung layout template
    if (widget.useCoverPhoto == true &&
        project.coverPhoto?.frontPhoto != null) {
      return Image.file(
        project.coverPhoto?.frontPhoto,
        fit: project.paper?.title == LIST_PAGE_SIZE[0].title
            ? BoxFit.fitWidth
            : BoxFit.cover,
        width: widget.listWH![0],
        height: widget.listWH![1],
        filterQuality: FilterQuality.high,
      );
    }
    if (project.listMedia.isEmpty ||
        (project.listMedia.length == 1 && project.listMedia[0] is String)) {
      return Container(
        margin: caculateSpacing(project, widthAndHeight,
            project.spacingAttribute?.unit, project.paper?.unit),
        padding: caculatePadding(widget.project, widget.widthAndHeight,
            widget.project.paddingAttribute?.unit, widget.project.paper?.unit),
        child: _buildImageWidget(
          project,
          (layoutExtractList?[0]) ?? BLANK_PAGE,
          width: double.infinity,
          height: double.infinity,
          color: widget.project.backgroundColor,
        ),
      );
    }
    if (project.paper?.title == LIST_PAGE_SIZE[0].title) {
      return Image.file(
        layoutExtractList![0][0],
        fit: BoxFit.fitWidth,
        width: widget.listWH![0], // delete height
        filterQuality: FilterQuality.high,
      );
    }
    if (project.useAvailableLayout != true &&
        project.placements != null &&
        project.placements!.isNotEmpty) {
      return Stack(
        children: layoutExtractList!.map((e) {
          final indexExtract = layoutExtractList.indexOf(e);
          return Positioned(
            top: getPositionWithTop(indexExtract, widthAndHeight[1]),
            left: getPositionWithLeft(indexExtract, widthAndHeight[0]),
            child: Container(
              child: _buildImageWidget(
                project,
                layoutExtractList[indexExtract],
                height: getRealHeight(indexExtract, widthAndHeight[1]),
                width: getRealWidth(indexExtract, widthAndHeight[0]),
              ),
            ),
          );
        }).toList(),
      );
    } else {
      final List<int> layoutSuggestion =
          LIST_LAYOUT_SUGGESTION[project.layoutIndex];
      List<Widget> widgetColumn = [];
      for (int indexColumn = 0;
          indexColumn < layoutSuggestion.length;
          indexColumn++) {
        final rows =
            List.generate(layoutSuggestion[indexColumn], (index) => index);
        widgetColumn.add(Flexible(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: rows.map((childRow) {
                final indexRow = rows.indexOf(childRow);
                return Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                    margin: caculateSpacing(project, widthAndHeight,
                        project.spacingAttribute?.unit, project.paper?.unit),
                    child: _buildImageWidget(
                      project,
                      layoutExtractList?[indexColumn]![indexRow],
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                );
              }).toList()),
        ));
      }
      return Container(
        padding: caculatePadding(widget.project, widget.widthAndHeight,
            widget.project.paddingAttribute?.unit, widget.project.paper?.unit),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widgetColumn,
        ),
      );
    }
  }

  Widget _buildImageWidget(Project project, dynamic imageData,
      {double? width, double? height, Color? color}) {
    final fit = renderImageBoxfit(project.resizeAttribute);
    if (imageData == null) {
      return Container();
    } else {
      if (imageData is File) {
        return Container(
          alignment: Alignment.center,
          child: Image.file(
            imageData,
            fit: fit,
            height: height,
            width: width,
            color: color,
            filterQuality: FilterQuality.high,
          ),
        );
      } else {
        if (imageData is String) {
          return Container(
            alignment: Alignment.center,
            child: Image.asset(
              imageData,
              fit: fit,
              height: height,
              color: color,
              width: width,
              filterQuality: FilterQuality.high,
            ),
          );
        } else {
          return const SizedBox();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: widget.project.alignmentAttribute?.alignmentMode,
      color: widget.project.backgroundColor,
      child: buildCoreLayoutMedia(widget.indexImage, widget.project,
          widget.layoutExtractList, widget.widthAndHeight),
    );
  }

  double getRealHeight(int extractIndex, double itemHeight) {
    final result =
        itemHeight * widget.project.placements![extractIndex].ratioHeight;
    return result;
  }

  double getRealWidth(int extractIndex, double itemWidth) {
    final result =
        itemWidth * widget.project.placements![extractIndex].ratioWidth;
    return result;
  }

  double getPositionWithTop(int extractIndex, double itemHeight) {
    final result =
        widget.project.placements![extractIndex].ratioOffset[1] * itemHeight;
    return result;
  }

  double getPositionWithLeft(int extractIndex, double itemWidth) {
    var result =
        widget.project.placements![extractIndex].ratioOffset[0] * itemWidth;
    return result;
  }
}
