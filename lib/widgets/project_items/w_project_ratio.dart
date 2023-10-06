import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/render_boxfit.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';

Widget buildLayoutMedia(int indexImage, Project project,
    List<dynamic>? layoutExtractList, List<double> ratioTarget,
    {double spacingVertical = 3, double spacingHorizontal = 3}) {
  if (project.useAvailableLayout != true &&
      project.placements != null &&
      project.placements!.isNotEmpty) {
    return PlacementLayoutMedia(
      indexImage: indexImage,
      project: project,
      layoutExtractList: layoutExtractList,
      ratioTarget: ratioTarget,
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
              height: spacingVertical,
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
            WSpacer(height: spacingVertical),
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
                    width: spacingHorizontal,
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
                      child: _buildImageWidget(project, layoutExtractList[0])),
                  WSpacer(width: spacingHorizontal),
                  Flexible(
                    child: _buildImageWidget(project, layoutExtractList[1]),
                  ),
                ],
              ),
            ),
            WSpacer(height: spacingVertical),
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
      );
    } else {
      return Image.asset(
        imageData,
        fit: fit,
        height: height,
        width: width,
      );
    }
  }
}

class PlacementLayoutMedia extends StatelessWidget {
  final int indexImage;
  final Project project;
  final List<dynamic>? layoutExtractList;
  final List<double> ratioTarget;
  const PlacementLayoutMedia(
      {super.key,
      required this.project,
      required this.indexImage,
      required this.layoutExtractList,
      required this.ratioTarget});

  double getDrawBoardWithPreviewBoardHeight() {
    return ratioTarget[0] / LIST_RATIO_PLACEMENT_BOARD[0];
  }

  double getDrawBoardWithPreviewBoardWidth() {
    return ratioTarget[1] / LIST_RATIO_PLACEMENT_BOARD[1];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: layoutExtractList!.map((e) {
        final index = layoutExtractList!.indexOf(e);
        return Positioned(
          top: getPositionWithTop(index),
          left: getPositionWithLeft(index),
          child: _buildImageWidget(
            project,
            layoutExtractList![index],
            height: getRealHeight(index),
            width: getRealWidth(index),
          ),
        );
      }).toList(),
    );
  }

  double getRealHeight(int extractIndex) {
    return getDrawBoardWithPreviewBoardHeight() *
        (project.placements![extractIndex].height);
  }

  double getRealWidth(int extractIndex) {
    return getDrawBoardWithPreviewBoardWidth() *
        (project.placements![extractIndex].width);
  }

  double getPositionWithTop(int extractIndex) {
    return (project.placements![extractIndex].offset.dy) *
        getDrawBoardWithPreviewBoardHeight();
  }

  double getPositionWithLeft(int extractIndex) {
    return (project.placements![extractIndex].offset.dx) *
        getDrawBoardWithPreviewBoardWidth();
  }
}
