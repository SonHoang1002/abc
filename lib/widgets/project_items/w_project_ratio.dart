import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/render_boxfit.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';

class LayoutMedia extends StatelessWidget {
  final int indexImage;
  final Project project;
  final List<dynamic>? layoutExtractList;
  final List<double> ratioTarget;
  const LayoutMedia(
      {super.key,
      required this.project,
      required this.indexImage,
      required this.layoutExtractList,
      required this.ratioTarget});

  double ratioTargetWithHeightPlacement() {
    // if (project.paper != null &&
    //     project.paper?.height != 0 &&
    //     project.paper?.width != 0) {
    //   final paperWidth = project.paper!.width;
    //   final paperHeight = project.paper!.height;
    //   return (paperWidth / paperHeight) /
    //       (LIST_RATIO_PLACEMENT_BOARD[0] / LIST_RATIO_PLACEMENT_BOARD[1]) *
    //       LIST_RATIO_PLACEMENT_BOARD[0];
    // } else {
      return ratioTarget[0] / LIST_RATIO_PLACEMENT_BOARD[0];
    // }
  }

  double ratioTargetWithWidthPlacement() {
    // if (project.paper != null &&
    //     project.paper?.height != 0 &&
    //     project.paper?.width != 0) {
    //   final paperWidth = project.paper!.width;
    //   final paperHeight = project.paper!.height;
    //   return (paperHeight / paperWidth) /
    //       (LIST_RATIO_PLACEMENT_BOARD[1] / LIST_RATIO_PLACEMENT_BOARD[0]) *
    //       LIST_RATIO_PLACEMENT_BOARD[1];
    // } else {
      return ratioTarget[1] / LIST_RATIO_PLACEMENT_BOARD[1];
    // }
  }

  Widget buildCoreLayoutMedia(
    int indexImage,
    Project project,
    List<dynamic>? layoutExtractList,
    List<double> ratioTarget,
  ) {
    final double spacingHorizontalValue =
        ((project.spacingAttribute?.horizontalSpacing ?? 0.0)) * 3;
    final double spacingVerticalValue =
        ((project.spacingAttribute?.verticalSpacing ?? 0.0)) * 3;
    if (project.useAvailableLayout != true &&
        project.placements != null &&
        project.placements!.isNotEmpty) {
      return Stack(
        children: layoutExtractList!.map((e) {
          final indexExtract = layoutExtractList.indexOf(e);
          return Positioned(
            top: getPositionWithTop(indexExtract),
            left: getPositionWithLeft(indexExtract),
            child: _buildImageWidget(
              project,
              layoutExtractList[indexExtract],
              height: getRealHeight(indexExtract),
              width: getRealWidth(indexExtract),
            ),
          );
        }).toList(),
      );
    } else {
      if (project.layoutIndex == 0 && layoutExtractList == null) {
        return _buildImageWidget(project, project.listMedia[indexImage]);
      } else if (layoutExtractList != null && layoutExtractList.isNotEmpty) {
        if (project.layoutIndex == 1) {
          return Column(
            children: [
              Flexible(
                  child: _buildImageWidget(
                project,
                layoutExtractList[0],
                height: 150,
                width: 150,
              )),
              WSpacer(
                height: spacingVerticalValue,
              ),
              Flexible(
                  child: _buildImageWidget(
                project,
                layoutExtractList[1],
                height: 150,
                width: 150,
              )),
            ],
          );
        } else if (project.layoutIndex == 2) {
          return Flex(
            direction: Axis.vertical,
            children: [
              Flexible(
                  child: _buildImageWidget(
                project,
                layoutExtractList[0],
                width: 150,
              )),
              WSpacer(height: spacingVerticalValue),
              Flexible(
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                        child: _buildImageWidget(
                      project,
                      layoutExtractList[1],
                    )),
                    WSpacer(
                      width: spacingHorizontalValue,
                    ),
                    Flexible(
                      child: _buildImageWidget(project, layoutExtractList[2]),
                    ),
                  ],
                ),
              )
            ],
          );
        } else {
          return Flex(
            direction: Axis.vertical,
            children: [
              Flexible(
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                        child:
                            _buildImageWidget(project, layoutExtractList[0])),
                    WSpacer(width: spacingHorizontalValue),
                    Flexible(
                      child: _buildImageWidget(project, layoutExtractList[1]),
                    ),
                  ],
                ),
              ),
              WSpacer(height: spacingVerticalValue),
              Flexible(
                  child: _buildImageWidget(
                project,
                layoutExtractList[2],
                width: 150,
              )),
            ],
          );
        }
      } else {
        return const SizedBox();
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
        return Image.file(
          imageData,
          fit: fit,
          height: height,
          width: width,
          filterQuality: FilterQuality.high,
        );
      } else {
        if (imageData is String) {
          return Image.asset(
            imageData,
            fit: fit,
            height: height,
            width: width,
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
    print("paper ${project.paper?.getInfor()}");
    return Container(
      padding: EdgeInsets.only(
          top: 2 + (project.paddingAttribute?.verticalPadding ?? 0.0),
          left: 3 + (project.paddingAttribute?.horizontalPadding ?? 0.0),
          right: 3 + (project.paddingAttribute?.horizontalPadding ?? 0.0),
          bottom: 3 + (project.paddingAttribute?.verticalPadding ?? 0.0)),
      alignment: project.alignmentAttribute?.alignmentMode,
      color: project.backgroundColor,
      child: buildCoreLayoutMedia(
          indexImage, project, layoutExtractList, ratioTarget),
    );
  }

  double getRealHeight(int extractIndex) {
    return ratioTargetWithHeightPlacement() *
        (project.placements![extractIndex].height);
  }

  double getRealWidth(int extractIndex) {
    return ratioTargetWithWidthPlacement() *
        (project.placements![extractIndex].width);
  }

  double getPositionWithTop(int extractIndex) {
    return (project.placements![extractIndex].offset.dy) *
        ratioTargetWithHeightPlacement();
  }

  double getPositionWithLeft(int extractIndex) {
    return (project.placements![extractIndex].offset.dx) *
        ratioTargetWithWidthPlacement();
  }
}
