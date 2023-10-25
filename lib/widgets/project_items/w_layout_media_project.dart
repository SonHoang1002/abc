import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/caculate_padding.dart';
import 'package:photo_to_pdf/helpers/caculate_spacing.dart';
import 'package:photo_to_pdf/helpers/convert.dart';
import 'package:photo_to_pdf/helpers/render_boxfit.dart';
import 'package:photo_to_pdf/models/project.dart';

class LayoutMedia extends ConsumerStatefulWidget {
  final int indexImage;
  final Project project;
  final List<dynamic>? layoutExtractList;
  final List<double> widthAndHeight;
  final List<double>? listWH;
  const LayoutMedia(
      {super.key,
      required this.project,
      required this.indexImage,
      required this.layoutExtractList,
      required this.widthAndHeight,
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
    if (project.listMedia.isEmpty ||
        (project.listMedia.length == 1 && project.listMedia[0] is String)) {
      return Container(
        margin: caculateSpacing(project, widthAndHeight,
            project.spacingAttribute?.unit, project.paper?.unit),
        padding: caculatePadding(widget.project, widget.widthAndHeight,
            widget.project.paddingAttribute?.unit, widget.project.paper?.unit),
        child: _buildImageWidget(
          project,
          (layoutExtractList?[0]) ?? "${pathPrefixImage}blank_page.jpg",
          width: double.infinity,
          height: double.infinity,
        ),
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
              // margin: caculateSpacing(
              //     project,
              //     widthAndHeight,
              //     project.placements![indexExtract].placementAttribute?.unit,
              //     project.paper?.unit),
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
      if (project.listMedia.length == 1 && project.listMedia[0] is String) {
        return Container(
          padding: caculatePadding(
              widget.project,
              widget.widthAndHeight,
              widget.project.paddingAttribute?.unit,
              widget.project.paper?.unit),
          margin: caculateSpacing(project, widthAndHeight,
              project.spacingAttribute?.unit, project.paper?.unit),
          child: _buildImageWidget(
            project,
            (layoutExtractList?[0]) ?? "${pathPrefixImage}blank_page.jpg",
            width: double.infinity,
            height: double.infinity,
          ),
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
          padding: caculatePadding(
              widget.project,
              widget.widthAndHeight,
              widget.project.paddingAttribute?.unit,
              widget.project.paper?.unit),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: widgetColumn,
          ),
        );
      }
    }
  }

  Widget _buildImageWidget(Project project, dynamic imageData,
      {double? width, double? height}) {
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
    final result = itemHeight *
        (widget.project.placements![extractIndex].ratioHeight -
            convertUnit(
                    widget.project.placements![extractIndex].placementAttribute!
                        .unit!,
                    widget.project.paper!.unit!,
                    ((widget.project.placements![extractIndex]
                            .placementAttribute?.vertical) ??
                        0)) /
                widget.project.paper!.height);
    return result;
  }

  double getRealWidth(int extractIndex, double itemWidth) {
    final result = itemWidth *
        (widget.project.placements![extractIndex].ratioWidth -
            convertUnit(
                    widget.project.placements![extractIndex].placementAttribute!
                        .unit!,
                    widget.project.paper!.unit!,
                    ((widget.project.placements![extractIndex]
                            .placementAttribute?.horizontal) ??
                        0)) /
                widget.project.paper!.width);
    return result;
  }

  double getPositionWithTop(int extractIndex, double itemHeight) {
    final result = (widget.project.placements![extractIndex].ratioOffset[1] +
            convertUnit(
                    widget.project.placements![extractIndex].placementAttribute!
                        .unit!,
                    widget.project.paper!.unit!,
                    ((widget.project.placements![extractIndex]
                                .placementAttribute?.vertical) ??
                            0) /
                        2) /
                widget.project.paper!.height) *
        itemHeight;
    return result;
  }

  double getPositionWithLeft(int extractIndex, double itemWidth) {
    var result = (widget.project.placements![extractIndex].ratioOffset[0] +
            convertUnit(
                    widget.project.placements![extractIndex].placementAttribute!
                        .unit!,
                    widget.project.paper!.unit!,
                    ((widget.project.placements![extractIndex]
                                .placementAttribute?.horizontal) ??
                            0) /
                        2) /
                widget.project.paper!.width) *
        itemWidth;
    return result;
  }
}
