import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/render_boxfit.dart';
import 'package:photo_to_pdf/models/project.dart';

class LayoutMedia1 extends ConsumerStatefulWidget {
  final int indexImage;
  final Project project;
  final List<dynamic>? layoutExtractList;
  final List<double> ratioTarget;
  final List<double>? listWH;
  const LayoutMedia1(
      {super.key,
      required this.project,
      required this.indexImage,
      required this.layoutExtractList,
      required this.ratioTarget,
      this.listWH});

  @override
  ConsumerState<LayoutMedia1> createState() => _LayoutMedia1State();
}

class _LayoutMedia1State extends ConsumerState<LayoutMedia1> {
  Widget buildCoreLayoutMedia(
    int indexImage,
    Project project,
    List<dynamic>? layoutExtractList,
    List<double> ratioTarget,
  ) {
    // const double spaceWidth = 3;
    // const double spaceheight = 3;
    if (project.useAvailableLayout != true &&
        project.placements != null &&
        project.placements!.isNotEmpty) {
      return Stack(
        children: layoutExtractList!.map((e) {
          final indexExtract = layoutExtractList.indexOf(e);
          return Positioned(
            top: getPositionWithTop(indexExtract),
            left: getPositionWithLeft(indexExtract),
            child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: ((project.placements![indexExtract]
                          .placementAttribute?.horizontal) ??
                      0),
                  vertical: ((project.placements![indexExtract]
                          .placementAttribute?.vertical) ??
                      0)),
              child: _buildImageWidget(
                project,
                layoutExtractList[indexExtract],
                height: getRealHeight(indexExtract),
                width: getRealWidth(indexExtract),
              ),
            ),
          );
        }).toList(),
      );
    } else {
      if (project.listMedia.length == 1 && project.listMedia[0] is String) {
        return _buildImageWidget(
          project,
          (layoutExtractList?[0]) ?? "${pathPrefixImage}blank_page.jpg",
          width: double.infinity,
          height: double.infinity,
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
                    child: _buildImageWidget(
                      project,
                      layoutExtractList?[indexColumn]![indexRow],
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  );
                }).toList()),
          ));
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widgetColumn,
        );
      }
    }
  }

  Widget _buildImageWidget(Project project, dynamic imageData,
      {double? width, double? height}) {
    EdgeInsets margin = EdgeInsets.only(
      top: (2 + (project.spacingAttribute?.verticalSpacing ?? 0.0)),
      left: (2 + (project.spacingAttribute?.horizontalSpacing ?? 0.0)),
      right: (2 + (project.spacingAttribute?.horizontalSpacing ?? 0.0)),
      bottom: (2 + (project.spacingAttribute?.verticalSpacing ?? 0.0)),
    );
    final fit = renderImageBoxfit(project.resizeAttribute);
    if (imageData == null) {
      return Container();
    } else {
      if (imageData is File) {
        return Container(
          margin: margin,
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
            margin: margin,
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
      padding: EdgeInsets.only(
          top: 2 + (widget.project.paddingAttribute?.verticalPadding ?? 0.0),
          left: 3 + (widget.project.paddingAttribute?.horizontalPadding ?? 0.0),
          right:
              3 + (widget.project.paddingAttribute?.horizontalPadding ?? 0.0),
          bottom:
              3 + (widget.project.paddingAttribute?.verticalPadding ?? 0.0)),
      alignment: widget.project.alignmentAttribute?.alignmentMode,
      color: widget.project.backgroundColor,
      child: buildCoreLayoutMedia(widget.indexImage, widget.project,
          widget.layoutExtractList, widget.ratioTarget),
    );
  }

  double getRealHeight(int extractIndex) {
    return ratioTargetWithHeightPlacement() *
        (widget.project.placements![extractIndex].height);
  }

  double getRealWidth(int extractIndex) {
    return ratioTargetWithWidthPlacement() *
        (widget.project.placements![extractIndex].width);
  }

  double ratioTargetWithHeightPlacement() {
    return widget.ratioTarget[0] / LIST_RATIO_PLACEMENT_BOARD[0];
  }

  double ratioTargetWithWidthPlacement() {
    return widget.ratioTarget[1] / LIST_RATIO_PLACEMENT_BOARD[1];
  }

  double getPositionWithTop(int extractIndex) {
    var result;
    result = (widget.project.placements![extractIndex].offset.dy) *
        ratioTargetWithHeightPlacement();
    return result;
  }

  double getPositionWithLeft(int extractIndex) {
    var result;
    // if (widget.listWH != null &&
    //     widget.project.placements![extractIndex].listWHBoard[0] != 0) {
    //   result = (widget.project.placements![extractIndex].offset.dx /
    //           widget.project.placements![extractIndex].listWHBoard[0] *
    //           widget.listWH![0]) *
    //       ratioTargetWithWidthPlacement();
    //        print(
    //     "result getPositionWithLeft ${widget.project.placements![extractIndex].offset.dx} / ${widget.project.placements![extractIndex].listWHBoard[0]} -  ${result} / ${widget.listWH![0]}");

    // } else {
    result = (widget.project.placements![extractIndex].offset.dx) *
        ratioTargetWithWidthPlacement();
    // }
    return result;
  }
}
