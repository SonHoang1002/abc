import 'dart:io';
import 'dart:math';
import 'package:photo_to_pdf/helpers/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_to_pdf/commons/colors.dart';
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
        alignment: project.alignmentAttribute?.alignmentMode,
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
            height: getRealHeight(indexExtract, widthAndHeight[1]),
            width: getRealWidth(indexExtract, widthAndHeight[0]),
            child: Container(
              alignment: project.alignmentAttribute?.alignmentMode,
              // color: colorRed,
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
      // use layout suggestions
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
              // mainAxisAlignment: MainAxisAlignment.center,
              children: rows.map((childRow) {
                final indexRow = rows.indexOf(childRow);
                // tinh width and height tung anh 1
                double newWidth = widthAndHeight[0];
                double newHeight = widthAndHeight[1];
                if (project.resizeAttribute?.title ==
                    LIST_RESIZE_MODE[1].title) {
                  // chuyen sang don vi point
                  final paddingHeight = (convertUnit(
                          project.paddingAttribute?.unit,
                          project.paper?.unit,
                          project.paddingAttribute?.verticalPadding ?? 0)) /
                      (project.paper?.height ?? 1) *
                      widthAndHeight[1];
                  final spaceHeight = (convertUnit(
                          project.spacingAttribute?.unit,
                          project.paper?.unit,
                          project.spacingAttribute?.verticalSpacing ?? 0)) /
                      (project.paper?.height ?? 1) *
                      widthAndHeight[1];
                  final paddingWidth = (convertUnit(
                          project.paddingAttribute?.unit,
                          project.paper?.unit,
                          project.paddingAttribute?.verticalPadding ?? 0)) /
                      (project.paper?.width ?? 1) *
                      widthAndHeight[0];
                  final spaceWidth = (convertUnit(
                          project.spacingAttribute?.unit,
                          project.paper?.unit,
                          project.spacingAttribute?.horizontalSpacing ?? 0)) /
                      (project.paper?.width ?? 1) *
                      widthAndHeight[0];

                  newWidth = (widthAndHeight[0] -
                          2 * paddingWidth -
                          (rows.length - 0.5) * spaceWidth) /
                      rows.length;
                  newHeight = (widthAndHeight[1] -
                          (2 * paddingHeight) -
                          (layoutSuggestion.length - 0.5) * spaceHeight) /
                      layoutSuggestion.length;
                }
                return Flexible(
                  child: Container(
                    margin: caculateSpacing(project, widthAndHeight,
                        project.spacingAttribute?.unit, project.paper?.unit),
                    alignment: project.alignmentAttribute?.alignmentMode,
                    child: _buildImageWidget(
                      project,
                      layoutExtractList?[indexColumn]![indexRow],
                      height: newHeight,
                      width: newWidth,
                    ),
                  ),
                );
              }).toList()),
        ));
      }
      return Container(
        padding: caculatePadding(widget.project, widget.widthAndHeight,
            widget.project.paddingAttribute?.unit, widget.project.paper?.unit),
        alignment: project.alignmentAttribute?.alignmentMode,
        child: Column(
          children: widgetColumn,
        ),
      );
    }
  }

  List<double?>? _getImageWHLayoutSuggetions(
      {double? width, double? height, required Project project}) {
    if (project.resizeAttribute?.title == LIST_RESIZE_MODE[0].title) {
      // fit - > giu nguyen ti le anh
      return null;
    } else if (project.resizeAttribute?.title == LIST_RESIZE_MODE[1].title) {
      // fill -> khong giu nguyen ti le anh
      final result = min(width!, height!);
      return [result, result];
    } else {
      // stretch
      return [double.infinity, double.infinity];
    }
  }

  List<double?>? _getImageWHPlacement(
      {double? width, double? height, required Project project}) {
    if (project.resizeAttribute?.title == LIST_RESIZE_MODE[0].title) {
      // fit - > giu nguyen ti le anh
      return null;
    } else if (project.resizeAttribute?.title == LIST_RESIZE_MODE[1].title) {
      // fill -> khong giu nguyen ti le anh
      final result = min(width!, height!);
      return [result, result];
    } else {
      // stretch
      return [width, height];
    }
  }

  Widget _buildImageWidget(Project project, dynamic imageData,
      {double? width, double? height, Color? color}) {
    final fit = renderImageBoxfit(project.resizeAttribute);
    double? _height;
    double? _width;
    if (project.useAvailableLayout) {
      final listWHLayoutSuggetions = _getImageWHLayoutSuggetions(
          width: width, height: height, project: project);
      _width = listWHLayoutSuggetions?[0];
      _height = listWHLayoutSuggetions?[1];
    } else {
      final listWHPlacement =
          _getImageWHPlacement(width: width, height: height, project: project);
      _width = listWHPlacement?[0];
      _height = listWHPlacement?[1];
    }
    if (imageData == null) {
      return Container();
    } else {
      if (imageData is File) {
        return Image.file(
          imageData,
          fit: fit,
          height: _height,
          width: _width,
          color: color,
          filterQuality: FilterQuality.high,
        );
      } else {
        if (imageData is String) {
          return Image.asset(
            imageData,
            fit: fit,
            height: _height,
            width: _width,
            color: color,
            filterQuality: FilterQuality.high,
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
