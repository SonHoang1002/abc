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
    return ratioTarget[0] / LIST_RATIO_PLACEMENT_BOARD[0];
  }

  double ratioTargetWithWidthPlacement() {
    return ratioTarget[1] / LIST_RATIO_PLACEMENT_BOARD[1];
  }

  Widget buildCoreLayoutMedia(
    int indexImage,
    Project project,
    List<dynamic>? layoutExtractList,
    List<double> ratioTarget,
  ) {
    const double spaceWidth = 3;
    const double spaceheight = 3;
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
      if (project.layoutIndex == 0 && layoutExtractList == null) {
        return _buildImageWidget(
          project,
          project.listMedia[indexImage],
          width: double.infinity,
          height: double.infinity,
        );
      } else if (layoutExtractList != null && layoutExtractList.isNotEmpty) {
        if (project.layoutIndex == 1) {
          return Column(
            children: [
              Flexible(
                  child: _buildImageWidget(
                project,
                layoutExtractList[0],
                width: double.infinity,
                height: double.infinity,
              )),
              WSpacer(
                height: spaceheight,
              ),
              Flexible(
                  child: _buildImageWidget(
                project,
                layoutExtractList[1],
                width: double.infinity,
                height: double.infinity,
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
                width: double.infinity,
                height: double.infinity,
              )),
              WSpacer(height: spaceheight),
              Flexible(
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                        child: _buildImageWidget(
                      project,
                      layoutExtractList[1],
                      width: double.infinity,
                      height: double.infinity,
                    )),
                    WSpacer(
                      width: spaceWidth,
                    ),
                    Flexible(
                      child: _buildImageWidget(
                        project,
                        layoutExtractList[2],
                        width: double.infinity,
                        height: double.infinity,
                      ),
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
                      child: _buildImageWidget(
                        project,
                        layoutExtractList[0],
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    WSpacer(width: spaceWidth),
                    Flexible(
                      child: _buildImageWidget(
                        project,
                        layoutExtractList[1],
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),
              WSpacer(height: spaceheight),
              Flexible(
                  child: _buildImageWidget(
                project,
                layoutExtractList[2],
                width: double.infinity,
                height: double.infinity,
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
