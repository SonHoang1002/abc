import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/check_distance.dart';
import 'package:photo_to_pdf/helpers/convert.dart';
import 'package:photo_to_pdf/models/placement.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class WDragZoomImageTest extends StatefulWidget {
  final Color backgroundColor;
  final List<Placement> listPlacement;
  final List<ValueNotifier<Matrix4>> matrix4Notifiers;
  final Placement? selectedPlacement;
  final PaperAttribute? paperAttribute;
  final Function(
    List<Placement> placements,
    Placement? focusPlacement,
    ValueNotifier<Matrix4>? matrix4,
  ) onUpdatePlacement;
  final Function(
    Placement placement,
    ValueNotifier<Matrix4> matrix4,
  )? onFocusPlacement;
  final void Function()? onCancelFocusPlacement;
  final List<double>? ratioTarget;
  // dung de luu giu trang thai danh sach placement ban dau ( dung cho viec hien thi title index cho placement)
  final List<Placement>? listPlacementPreventive;
  const WDragZoomImageTest(
      {super.key,
      required this.backgroundColor,
      required this.listPlacement,
      required this.matrix4Notifiers,
      required this.onUpdatePlacement,
      this.selectedPlacement,
      this.onFocusPlacement,
      this.ratioTarget = LIST_RATIO_PLACEMENT_BOARD,
      this.paperAttribute,
      this.onCancelFocusPlacement,
      this.listPlacementPreventive});

  @override
  State<WDragZoomImageTest> createState() => _WDragZoomImageTestState();
}

class _WDragZoomImageTestState extends State<WDragZoomImageTest> {
  late Size _size;
  List<ValueNotifier<Matrix4>> _matrix4Notifiers = [];
  List<Placement> _listPlacement = [];
  final GlobalKey _drawAreaKey = GlobalKey();
  static const double minSizePlacement = 30;
  late List<double> _ratioTarget;
  late double _maxHeight;
  late double _maxWidth;
  Placement? _selectedPlacement;
  // [0]: override width // [1]: override height
  List<List<double>> _listOverride = [[], []];

  @override
  void dispose() {
    super.dispose();
    _matrix4Notifiers.clear();
    _listPlacement.clear();
    _listOverride.clear();
  }

  @override
  void initState() {
    super.initState();
    _selectedPlacement = widget.selectedPlacement;
    _ratioTarget = LIST_RATIO_PLACEMENT_BOARD;
    if (widget.paperAttribute != null &&
        widget.paperAttribute?.height != 0 &&
        widget.paperAttribute?.width != 0) {
      _ratioTarget = [
        _ratioTarget[0],
        widget.paperAttribute!.height /
            widget.paperAttribute!.width *
            _ratioTarget[0]
      ];
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _size = MediaQuery.sizeOf(context);
  }

  double _getHeightOfImage(int index) {
    final result = _listPlacement[index].ratioHeight * _maxHeight;
    return result;
  }

  double _getWidthOfImage(int index) {
    final result = _listPlacement[index].ratioWidth * _maxWidth;
    return result;
  }

  List<double> _getWidthAndHeight() {
    final MAXHEIGHT = _size.height * 404 / 791 * 0.9;
    final MAXWIDTH = _size.width * 0.9;

    double width = MAXWIDTH;
    double height = MAXHEIGHT;

    if (widget.paperAttribute != null) {
      final ratioHeightToWidth =
          widget.paperAttribute!.height / widget.paperAttribute!.width;

      if (widget.paperAttribute!.height > widget.paperAttribute!.width) {
        height = _size.width * ratioHeightToWidth;
        if (height > MAXHEIGHT) {
          height = MAXHEIGHT;
          width = height * (1 / ratioHeightToWidth);
        }
      } else if (widget.paperAttribute!.height < widget.paperAttribute!.width) {
        width = height * (1 / ratioHeightToWidth);
        if (width > MAXWIDTH) {
          width = MAXWIDTH;
          height = width * ratioHeightToWidth;
        }
      }
    } else {
      width = _size.width * _ratioTarget[1];
      height = _size.width * _ratioTarget[0];
    }

    return [width, height];
  }

  List<List<double>>? _getOrientationWithoutCurrentPlacement(
      Placement currentPlacement) {
    final listPlacementWithoutCurrent =
        _listPlacement.where((element) => element.id != currentPlacement.id);

    if (listPlacementWithoutCurrent.isNotEmpty) {
      // lay do cao cua cac chieu ngang
      List<double> listVerticalPosition = [];
      // lay do cao cua cac chieu doc
      List<double> listHorizontalPosition = [];

      listPlacementWithoutCurrent.forEach((element) {
        listVerticalPosition.addAll(
            _getAxisPositionOfPlacement(element, getTopAndBottom: true));
        listHorizontalPosition.addAll(
            _getAxisPositionOfPlacement(element, getTopAndBottom: false));
      });
      return [listVerticalPosition, listHorizontalPosition];
    }
    return null;
  }

  void _checkOverride(Placement? currentPlacement) {
    List<List<double>> newListOverride = [[], []];
    if (currentPlacement != null) {
      final orientationPositions =
          _getOrientationWithoutCurrentPlacement(currentPlacement);
      if (orientationPositions != null) {
        final offsetTopLeft = Offset(
            ratioToPixel(currentPlacement.ratioOffset[0], _maxWidth),
            ratioToPixel(currentPlacement.ratioOffset[1], _maxHeight));
        final offsetBottomRight = Offset(
            ratioToPixel(
                currentPlacement.ratioOffset[0] + currentPlacement.ratioWidth,
                _maxWidth),
            ratioToPixel(
                currentPlacement.ratioOffset[1] + currentPlacement.ratioHeight,
                _maxHeight));

        for (int i = 0; i < orientationPositions[0].length; i++) {
          // ratio offset se snap den khoang cach orientationPositions[0][i]
          if (checkInsideDistance(
              orientationPositions[0][i], offsetTopLeft.dy, 0.01)) {
            newListOverride[1].add(offsetTopLeft.dy);
          }
          if (checkInsideDistance(
              orientationPositions[0][i], offsetBottomRight.dy, 0.01)) {
            newListOverride[1].add(offsetBottomRight.dy);
          }
        }

        for (int i = 0; i < orientationPositions[1].length; i++) {
          if (checkInsideDistance(
              orientationPositions[1][i], offsetTopLeft.dx, 0.01)) {
            newListOverride[0].add(offsetTopLeft.dx);
          }
          if (checkInsideDistance(
              orientationPositions[1][i], offsetBottomRight.dx, 0.01)) {
            newListOverride[0].add(offsetBottomRight.dx);
          }
        }
      }
    } else {
      newListOverride = [[], []];
    }
    _listOverride = newListOverride;
  }

  // tra ra list bao gom cac offset doi dien nhau
  List<double> _getAxisPositionOfPlacement(Placement placement,
      {required bool getTopAndBottom}) {
    // getTopAndBottom - > lay do cao tu goc toa do xuong canh top va canh bottom
    List<double> results = [];

    if (getTopAndBottom) {
      results.add(ratioToPixel(placement.ratioOffset[1], _maxHeight));
      results.add(ratioToPixel(
          placement.ratioHeight + placement.ratioOffset[1], _maxHeight));
    } else {
      results.add(ratioToPixel(placement.ratioOffset[0], _maxWidth));
      results.add(ratioToPixel(
          placement.ratioWidth + placement.ratioOffset[0], _maxWidth));
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    _matrix4Notifiers = widget.matrix4Notifiers;
    _listPlacement = widget.listPlacement;
    _maxHeight = _getWidthAndHeight()[1];
    _maxWidth = _getWidthAndHeight()[0];
    _checkOverride(widget.selectedPlacement);
    return _buildCustomArea();
  }

  /// !!!! [haveVertical], [haveHorizontal] PROPERTY IS USED TO ANNOUNCE TO USE FOR APPLY VERTICAL, HORIZONTAL CHECK
  void _snapPosition(
    int index,
    DragUpdateDetails details,
    List<double> currentRatio,
    List<double> newRatio, {
    dynamic haveVertical,
    dynamic haveHorizontal,
  }) {
    final orientationPositions =
        _getOrientationWithoutCurrentPlacement(_listPlacement[index]);
    if (orientationPositions != null) {
      final offsetTopLeft = Offset(
          ratioToPixel(_listPlacement[index].ratioOffset[0], _maxWidth),
          ratioToPixel(_listPlacement[index].ratioOffset[1], _maxHeight));
      final offsetBottomRight = Offset(
          ratioToPixel(
              _listPlacement[index].ratioOffset[0] +
                  _listPlacement[index].ratioWidth,
              _maxWidth),
          ratioToPixel(
              _listPlacement[index].ratioOffset[1] +
                  _listPlacement[index].ratioHeight,
              _maxHeight));

      for (int i = 0; i < orientationPositions[1].length; i++) {
        // snap vao offsetTopLeft
        if (checkInsideDistance(
            orientationPositions[1][i], offsetTopLeft.dx, 5)) {
          _listPlacement[index] = _listPlacement[index].copyWith(
            ratioOffset: List.from([
              pixelToRatio(orientationPositions[1][i], _maxWidth),
              _listPlacement[index].ratioOffset[1],
            ]),
          );
        }
        // snap ra offsetTopLeft
        if (checkInsideDistance(ratioToPixel(currentRatio[0], _maxWidth),
            orientationPositions[1][i], 3)) {
          if ((ratioToPixel(_listPlacement[index].previewRatioOffset[0],
                          _maxWidth) -
                      orientationPositions[1][i])
                  .abs() >
              10) {
            _listPlacement[index] = _listPlacement[index].copyWith(
              ratioOffset: List.from([
                _listPlacement[index].previewRatioOffset[0],
                _listPlacement[index].ratioOffset[1],
              ]),
            );
          }
        }
        // snap vao offsetBottomRight
        if (checkInsideDistance(
            orientationPositions[1][i], offsetBottomRight.dx, 5)) {
          _listPlacement[index] = _listPlacement[index].copyWith(
            ratioOffset: List.from([
              pixelToRatio(orientationPositions[1][i], _maxWidth) -
                  _listPlacement[index].ratioWidth,
              _listPlacement[index].ratioOffset[1],
            ]),
          );
        }
        // snap ra offsetBottomRight
        if (checkInsideDistance(
            ratioToPixel(
                currentRatio[0] + _listPlacement[index].ratioWidth, _maxWidth),
            orientationPositions[1][i],
            3)) {
          if ((ratioToPixel(
                          _listPlacement[index].previewRatioOffset[0] +
                              _listPlacement[index].ratioWidth,
                          _maxWidth) -
                      orientationPositions[1][i])
                  .abs() >
              10) {
            _listPlacement[index] = _listPlacement[index].copyWith(
              ratioOffset: List.from([
                _listPlacement[index].previewRatioOffset[0],
                _listPlacement[index].ratioOffset[1],
              ]),
            );
          }
        }
      }

      for (int i = 0; i < orientationPositions[0].length; i++) {
        // snap vao offsetTopLeft
        if (checkInsideDistance(
            orientationPositions[0][i], offsetTopLeft.dy, 5)) {
          _listPlacement[index] = _listPlacement[index].copyWith(
            ratioOffset: List.from([
              _listPlacement[index].ratioOffset[0],
              pixelToRatio(orientationPositions[0][i], _maxHeight),
            ]),
          );
        }
        // snap ra offsetTopLeft
        if (checkInsideDistance(ratioToPixel(currentRatio[1], _maxHeight),
            orientationPositions[0][i], 3)) {
          if ((ratioToPixel(_listPlacement[index].previewRatioOffset[1],
                          _maxHeight) -
                      orientationPositions[0][i])
                  .abs() >
              10) {
            _listPlacement[index] = _listPlacement[index].copyWith(
              ratioOffset: List.from([
                _listPlacement[index].ratioOffset[0],
                _listPlacement[index].previewRatioOffset[1],
              ]),
            );
          }
        }

        // snap vao offsetBottomRight
        if (checkInsideDistance(
            orientationPositions[0][i], offsetBottomRight.dy, 5)) {
          _listPlacement[index] = _listPlacement[index].copyWith(
            ratioOffset: List.from([
              _listPlacement[index].ratioOffset[0],
              pixelToRatio(orientationPositions[0][i], _maxHeight) -
                  _listPlacement[index].ratioHeight,
            ]),
          );
        }
        // snap ra offsetBottomRight

        if (checkInsideDistance(
            ratioToPixel(currentRatio[1] + _listPlacement[index].ratioHeight,
                _maxHeight),
            orientationPositions[0][i],
            3)) {
          if ((ratioToPixel(
                          _listPlacement[index].previewRatioOffset[1] +
                              _listPlacement[index].ratioHeight,
                          _maxHeight) -
                      orientationPositions[0][i])
                  .abs() >
              10) {
            _listPlacement[index] = _listPlacement[index].copyWith(
              ratioOffset: List.from([
                _listPlacement[index].ratioOffset[0],
                _listPlacement[index].previewRatioOffset[1],
              ]),
            );
          }
        }
      }
    }
  }

  Widget _buildCustomArea() {
    final areaBox =
        _drawAreaKey.currentContext?.findRenderObject() as RenderBox?;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Container(
            key: _drawAreaKey,
            width: _maxWidth,
            height: _maxHeight,
            decoration:
                BoxDecoration(color: widget.backgroundColor, boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 0.5,
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ]),
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: _maxWidth + 15,
          height: _maxHeight + 15,
          child: Stack(
            children: [
              ..._listOverride[0]
                  .map<Widget>((e) => Positioned(
                      left: e,
                      top: 7,
                      child: Container(
                        margin: const EdgeInsets.only(left: 7),
                        height: _maxHeight,
                        width: 1,
                        color: colorRed,
                      )))
                  .toList(),
              ..._listOverride[1]
                  .map<Widget>((e) => Positioned(
                      top: e,
                      left: 8,
                      child: Container(
                        margin: const EdgeInsets.only(top: 7),
                        height: 1,
                        width: _maxWidth,
                        color: colorRed,
                      )))
                  .toList(),
              Stack(
                children: _listPlacement.map<Widget>(
                  (e) {
                    final index = _listPlacement.indexOf(e);
                    return GestureDetector(
                      onPanUpdate: (details) async {
                        // check real height of draw area
                        double maxAreaHeight = _size.width * _ratioTarget[1];
                        double maxAreaWidth = _size.width * _ratioTarget[0];
                        if (areaBox != null) {
                          if (areaBox.size.height <
                              _size.width * _ratioTarget[1]) {
                            maxAreaHeight = areaBox.size.height - 2;
                          }
                        }
                        double currentRatioOffsetX =
                            _listPlacement[index].ratioOffset[0];
                        double currentRatioOffsetY =
                            _listPlacement[index].ratioOffset[1];
                        double currentRatioOffsetPreviewX =
                            _listPlacement[index].previewRatioOffset[0];
                        double currentRatioOffsetPreviewY =
                            _listPlacement[index].previewRatioOffset[1];

                        double newRatioOffsetX = currentRatioOffsetX +
                            pixelToRatio(details.delta.dx, maxAreaWidth);
                        double newRatioOffsetY = currentRatioOffsetY +
                            pixelToRatio(details.delta.dy, maxAreaHeight);

                        double newRatioOffsetPreviewX =
                            currentRatioOffsetPreviewX +
                                pixelToRatio(details.delta.dx, maxAreaWidth);
                        double newRatioOffsetPreviewY =
                            currentRatioOffsetPreviewY +
                                pixelToRatio(details.delta.dy, maxAreaHeight);

                        _listPlacement[index].ratioOffset = [
                          newRatioOffsetX,
                          newRatioOffsetY
                        ];
                        _listPlacement[index].previewRatioOffset = [
                          newRatioOffsetPreviewX,
                          newRatioOffsetPreviewY
                        ];
                        _listPlacement[index].previewWidth =
                            _listPlacement[index].ratioWidth;
                        _listPlacement[index].previewHeight =
                            _listPlacement[index].ratioHeight;
                        _snapPosition(
                            index,
                            details,
                            [currentRatioOffsetX, currentRatioOffsetY],
                            [newRatioOffsetPreviewX, newRatioOffsetPreviewY],
                            haveHorizontal: 1,
                            haveVertical: 1);
                        //left
                        if (_listPlacement[index].ratioOffset[0] <= 0) {
                          _listPlacement[index].ratioOffset = [
                            0,
                            _listPlacement[index].ratioOffset[1]
                          ];
                          _listPlacement[index].previewRatioOffset = [
                            0,
                            _listPlacement[index].previewRatioOffset[1]
                          ];
                        }
                        //top
                        if (_listPlacement[index].ratioOffset[1] <= 0) {
                          _listPlacement[index].ratioOffset = [
                            _listPlacement[index].ratioOffset[0],
                            0
                          ];
                          _listPlacement[index].previewRatioOffset = [
                            _listPlacement[index].previewRatioOffset[0],
                            0
                          ];
                        }
                        //right
                        if (_listPlacement[index].ratioOffset[0] +
                                _listPlacement[index].ratioWidth >=
                            1) {
                          _listPlacement[index].ratioOffset = [
                            1 - _listPlacement[index].ratioWidth,
                            _listPlacement[index].ratioOffset[1]
                          ];
                          _listPlacement[index].previewRatioOffset = [
                            1 - _listPlacement[index].ratioWidth,
                            _listPlacement[index].previewRatioOffset[1]
                          ];
                        }
                        //bottom
                        if (_listPlacement[index].ratioOffset[1] +
                                _listPlacement[index].ratioHeight >=
                            1) {
                          _listPlacement[index].ratioOffset = [
                            _listPlacement[index].ratioOffset[0],
                            1 - _listPlacement[index].ratioHeight
                          ];
                          _listPlacement[index].previewRatioOffset = [
                            _listPlacement[index].previewRatioOffset[0],
                            1 - _listPlacement[index].ratioHeight
                          ];
                        }
                        widget.onFocusPlacement!(
                          _listPlacement[index],
                          _matrix4Notifiers[index],
                        );
                        setState(() {});
                      },
                      onTap: () {
                        if (_selectedPlacement == _listPlacement[index]) {
                          widget.onCancelFocusPlacement != null
                              ? widget.onCancelFocusPlacement!()
                              : null;
                          _selectedPlacement = null;
                          setState(() {});
                        } else {
                          if (widget.onFocusPlacement != null) {
                            widget.onFocusPlacement!(
                              _listPlacement[index],
                              _matrix4Notifiers[index],
                            );
                            _selectedPlacement = _listPlacement[index];
                            setState(() {});
                          }
                        }
                      },
                      onPanStart: (details) {
                        widget.onFocusPlacement != null
                            ? widget.onFocusPlacement!(
                                _listPlacement[index],
                                _matrix4Notifiers[index],
                              )
                            : null;
                      },
                      onPanEnd: (details) {},
                      child: AnimatedBuilder(
                        animation: _matrix4Notifiers[index],
                        builder: (context, child) {
                          return Stack(
                            children: [
                              Positioned(
                                top: _listPlacement[index].ratioOffset[1] *
                                    _maxHeight,
                                left: _listPlacement[index].ratioOffset[0] *
                                    _maxWidth,
                                child: Stack(children: [
                                  Container(
                                    margin: const EdgeInsets.all(7),
                                    child: Image.asset(
                                      "${pathPrefixImage}image_demo.png",
                                      fit: BoxFit.cover,
                                      height: _getHeightOfImage(index),
                                      width: _getWidthOfImage(index),
                                    ),
                                  ),
                                  Positioned.fill(
                                      child: Center(
                                    child: Container(
                                      height: 25,
                                      width: 25,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.5),
                                          color: colorBlue),
                                      child: Center(
                                          child: WTextContent(
                                        value:
                                            "${(widget.listPlacementPreventive!.indexWhere((element) => element.id == _listPlacement[index].id)) + 1}",
                                        textColor: colorWhite,
                                        textSize: 10,
                                      )),
                                    ),
                                  )),
                                  widget.selectedPlacement?.id ==
                                          _listPlacement[index].id
                                      ? Positioned.fill(
                                          child: _buildPanGestureWidget(index))
                                      : const SizedBox()
                                ]),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ).toList(),
              ),
            ],
          ),
        )
      ],
    );
  }

  // use for dot top left ok , dot top center , dot center left ok
  _snapPositionWidthPoint(
    int index,
  ) {
    final orientationPositions =
        _getOrientationWithoutCurrentPlacement(_listPlacement[index]);
    if (orientationPositions != null) {
      final offsetPoint = Offset(
          ratioToPixel(_listPlacement[index].ratioOffset[0], _maxWidth),
          ratioToPixel(_listPlacement[index].ratioOffset[1], _maxHeight));

      final currentRatio = List.from(_listPlacement[index].ratioOffset);

      for (int i = 0; i < orientationPositions[0].length; i++) {
        // snap vao
        if (checkInsideDistance(
            orientationPositions[0][i], offsetPoint.dy, 5)) {
          _listPlacement[index] = _listPlacement[index].copyWith(
            ratioOffset: List.from([
              _listPlacement[index].ratioOffset[0],
              pixelToRatio(orientationPositions[0][i], _maxHeight),
            ]),
            ratioHeight: _listPlacement[index].ratioHeight +
                _listPlacement[index].ratioOffset[1] -
                pixelToRatio(orientationPositions[0][i], _maxHeight),
          );
        }
        // snap ra
        if (checkInsideDistance(ratioToPixel(currentRatio[1], _maxHeight),
            orientationPositions[0][i], 3)) {
          if ((ratioToPixel(_listPlacement[index].previewRatioOffset[1],
                          _maxHeight) -
                      orientationPositions[0][i])
                  .abs() >
              10) {
            _listPlacement[index] = _listPlacement[index].copyWith(
                ratioOffset: List.from(
                  [
                    _listPlacement[index].previewRatioOffset[0],
                    _listPlacement[index].previewRatioOffset[1],
                  ],
                ),
                ratioHeight: _listPlacement[index].ratioHeight -
                    (_listPlacement[index].previewRatioOffset[1] -
                        pixelToRatio(orientationPositions[0][i], _maxHeight)));
          }
        }
      }
      for (int i = 0; i < orientationPositions[1].length; i++) {
        // snap vao
        if (checkInsideDistance(
            orientationPositions[1][i], offsetPoint.dx, 5)) {
          _listPlacement[index] = _listPlacement[index].copyWith(
            ratioOffset: List.from([
              pixelToRatio(orientationPositions[1][i], _maxWidth),
              _listPlacement[index].ratioOffset[1],
            ]),
            ratioWidth: _listPlacement[index].ratioWidth +
                _listPlacement[index].ratioOffset[0] -
                pixelToRatio(orientationPositions[1][i], _maxWidth),
          );
        }
        // snap ra
        if (checkInsideDistance(ratioToPixel(currentRatio[0], _maxWidth),
            orientationPositions[1][i], 3)) {
          if ((ratioToPixel(_listPlacement[index].previewRatioOffset[0],
                          _maxWidth) -
                      orientationPositions[1][i])
                  .abs() >
              10) {
            _listPlacement[index] = _listPlacement[index].copyWith(
                ratioOffset:
                    List.from(_listPlacement[index].previewRatioOffset),
                ratioWidth: _listPlacement[index].ratioWidth -
                    (_listPlacement[index].previewRatioOffset[0] -
                        pixelToRatio(orientationPositions[1][i], _maxWidth)));
          }
        }
      }
    }
  }

  // use for dot bottom left ok, , dot bottom center ok
  _snapPositionWidthPoint1(
    int index,
  ) {
    final orientationPositions =
        _getOrientationWithoutCurrentPlacement(_listPlacement[index]);
    if (orientationPositions != null) {
      final offsetPoint = Offset(
          ratioToPixel(_listPlacement[index].ratioOffset[0], _maxWidth),
          ratioToPixel(
              _listPlacement[index].ratioOffset[1] +
                  _listPlacement[index].ratioHeight,
              _maxHeight));

      final currentRatio = List.from([
        _listPlacement[index].ratioOffset[0],
        (_listPlacement[index].ratioOffset[1] +
            _listPlacement[index].ratioHeight)
      ]);
      for (int i = 0; i < orientationPositions[0].length; i++) {
        // snap vao
        if (checkInsideDistance(
            orientationPositions[0][i], offsetPoint.dy, 5)) {
          _listPlacement[index] = _listPlacement[index].copyWith(
            ratioHeight: pixelToRatio(orientationPositions[0][i], _maxHeight) -
                _listPlacement[index].ratioOffset[1],
          );
        }
        // snap ra
        if (checkInsideDistance(ratioToPixel(currentRatio[1], _maxHeight),
            orientationPositions[0][i], 3)) {
          if ((ratioToPixel(
                          _listPlacement[index].previewHeight +
                              _listPlacement[index].ratioOffset[1],
                          _maxHeight) -
                      orientationPositions[0][i])
                  .abs() >
              7) {
            _listPlacement[index] = _listPlacement[index]
                .copyWith(ratioHeight: _listPlacement[index].previewHeight);
          }
        }
      }
      for (int i = 0; i < orientationPositions[1].length; i++) {
        // snap vao
        if (checkInsideDistance(
            orientationPositions[1][i], offsetPoint.dx, 5)) {
          _listPlacement[index] = _listPlacement[index].copyWith(
            ratioOffset: List.from([
              pixelToRatio(orientationPositions[1][i], _maxWidth),
              _listPlacement[index].ratioOffset[1]
            ]),
            ratioWidth: _listPlacement[index].ratioWidth +
                _listPlacement[index].ratioOffset[0] -
                pixelToRatio(orientationPositions[1][i], _maxWidth),
          );
        }
        // snap ra
        if (checkInsideDistance(ratioToPixel(currentRatio[0], _maxWidth),
            orientationPositions[1][i], 3)) {
          if ((ratioToPixel(_listPlacement[index].previewRatioOffset[0],
                          _maxWidth) -
                      orientationPositions[1][i])
                  .abs() >
              10) {
            _listPlacement[index] = _listPlacement[index].copyWith(
                ratioOffset: List.from([
                  _listPlacement[index].previewRatioOffset[0],
                  _listPlacement[index].ratioOffset[1]
                ]),
                ratioWidth: _listPlacement[index].ratioWidth -
                    (_listPlacement[index].previewRatioOffset[0] -
                        pixelToRatio(orientationPositions[1][i], _maxWidth)));
          }
        }
      }
    }
  }

  // use for dot bottom right ok
  _snapPositionWidthPoint2(
    int index,
  ) {
    final orientationPositions =
        _getOrientationWithoutCurrentPlacement(_listPlacement[index]);
    if (orientationPositions != null) {
      final offsetPoint = Offset(
          ratioToPixel(
              _listPlacement[index].ratioOffset[0] +
                  _listPlacement[index].ratioWidth,
              _maxWidth),
          ratioToPixel(
              _listPlacement[index].ratioOffset[1] +
                  _listPlacement[index].ratioHeight,
              _maxHeight));

      final currentRatio = List.from([
        _listPlacement[index].ratioOffset[0] + _listPlacement[index].ratioWidth,
        (_listPlacement[index].ratioOffset[1] +
            _listPlacement[index].ratioHeight)
      ]);

      for (int i = 0; i < orientationPositions[0].length; i++) {
        // snap vao
        if (checkInsideDistance(
            orientationPositions[0][i], offsetPoint.dy, 5)) {
          _listPlacement[index] = _listPlacement[index].copyWith(
            ratioHeight: (pixelToRatio(orientationPositions[0][i], _maxHeight) -
                _listPlacement[index].ratioOffset[1]),
          );
        }
        // snap ra
        if (checkInsideDistance(ratioToPixel(currentRatio[1], _maxHeight),
            orientationPositions[0][i], 3)) {
          if ((ratioToPixel(
                          _listPlacement[index].previewHeight +
                              _listPlacement[index].ratioOffset[1],
                          _maxHeight) -
                      orientationPositions[0][i])
                  .abs() >
              10) {
            _listPlacement[index] = _listPlacement[index]
                .copyWith(ratioHeight: _listPlacement[index].previewHeight);
          }
        }
      }
      for (int i = 0; i < orientationPositions[1].length; i++) {
        // snap vao
        if (checkInsideDistance(
            orientationPositions[1][i], offsetPoint.dx, 5)) {
          _listPlacement[index] = _listPlacement[index].copyWith(
              ratioWidth: pixelToRatio(orientationPositions[1][i], _maxWidth) -
                  _listPlacement[index].ratioOffset[0]);
        }
        // snap ra
        if (checkInsideDistance(ratioToPixel(currentRatio[0], _maxWidth),
            orientationPositions[1][i], 3)) {
          if ((ratioToPixel(
                          _listPlacement[index].ratioOffset[0] +
                              _listPlacement[index].previewWidth,
                          _maxWidth) -
                      orientationPositions[1][i])
                  .abs() >
              7) {
            _listPlacement[index] = _listPlacement[index]
                .copyWith(ratioWidth: _listPlacement[index].previewWidth);
          }
        }
      }
    }
  }

  // use for dot top right ok, top center ok, center right ok
  _snapPositionWidthPoint3(
    int index,
  ) {
    final orientationPositions =
        _getOrientationWithoutCurrentPlacement(_listPlacement[index]);
    if (orientationPositions != null) {
      final offsetPoint = Offset(
          ratioToPixel(
              _listPlacement[index].ratioOffset[0] +
                  _listPlacement[index].ratioWidth,
              _maxWidth),
          ratioToPixel(_listPlacement[index].ratioOffset[1], _maxHeight));

      final currentRatio = List.from([
        _listPlacement[index].ratioOffset[0] + _listPlacement[index].ratioWidth,
        (_listPlacement[index].ratioOffset[1])
      ]);
      for (int i = 0; i < orientationPositions[0].length; i++) {
        // snap vao
        if (checkInsideDistance(
            orientationPositions[0][i], offsetPoint.dy, 5)) {
          _listPlacement[index] = _listPlacement[index].copyWith(
              ratioOffset: [
                _listPlacement[index].ratioOffset[0],
                pixelToRatio(orientationPositions[0][i], _maxHeight)
              ],
              ratioHeight: _listPlacement[index].ratioHeight +
                  (_listPlacement[index].ratioOffset[1] -
                      pixelToRatio(orientationPositions[0][i], _maxHeight)));
        }
        // snap ra
        if (checkInsideDistance(ratioToPixel(currentRatio[1], _maxHeight),
            orientationPositions[0][i], 3)) {
          if ((ratioToPixel(_listPlacement[index].previewRatioOffset[1],
                          _maxHeight) -
                      orientationPositions[0][i])
                  .abs() >
              7) {
            _listPlacement[index] = _listPlacement[index].copyWith(
                ratioOffset: List.from(
                  [
                    _listPlacement[index].ratioOffset[0],
                    _listPlacement[index].previewRatioOffset[1],
                  ],
                ),
                ratioHeight: _listPlacement[index].previewHeight);
          }
        }
      }
      for (int i = 0; i < orientationPositions[1].length; i++) {
        // snap vao
        if (checkInsideDistance(
            orientationPositions[1][i], offsetPoint.dx, 5)) {
          _listPlacement[index] = _listPlacement[index].copyWith(
              ratioWidth: pixelToRatio(orientationPositions[1][i], _maxWidth) -
                  _listPlacement[index].ratioOffset[0]);
        }
        // snap ra
        if (checkInsideDistance(ratioToPixel(currentRatio[0], _maxWidth),
            orientationPositions[1][i], 3)) {
          if ((ratioToPixel(
                          _listPlacement[index].ratioOffset[0] +
                              _listPlacement[index].previewWidth,
                          _maxWidth) -
                      orientationPositions[1][i])
                  .abs() >
              10) {
            _listPlacement[index] = _listPlacement[index]
                .copyWith(ratioWidth: _listPlacement[index].previewWidth);
          }
        }
      }
    }
  }

  _checkExceedingDrawBoard(int index) {
    if (_listPlacement[index].ratioHeight > 1) {
      _listPlacement[index].ratioHeight = 1;
    }
    if (_listPlacement[index].ratioWidth > 1) {
      _listPlacement[index].ratioWidth = 1;
    }
    if (_listPlacement[index].previewHeight > 1) {
      _listPlacement[index].previewHeight = 1;
    }
    if (_listPlacement[index].previewWidth > 1) {
      _listPlacement[index].previewWidth = 1;
    }
    if (_listPlacement[index].ratioOffset[0] < 0) {
      _listPlacement[index].ratioOffset[0] = 0;
    }
    if (_listPlacement[index].ratioOffset[1] < 0) {
      _listPlacement[index].ratioOffset[1] = 0;
    }
    if (_listPlacement[index].ratioOffset[0] > 1) {
      _listPlacement[index].ratioOffset[0] = 1;
    }
    if (_listPlacement[index].ratioOffset[1] > 1) {
      _listPlacement[index].ratioOffset[1] = 1;
    }
    if (_listPlacement[index].previewRatioOffset[0] < 0) {
      _listPlacement[index].previewRatioOffset[0] = 0;
    }
    if (_listPlacement[index].previewRatioOffset[1] < 0) {
      _listPlacement[index].previewRatioOffset[1] = 0;
    }
    if (_listPlacement[index].previewRatioOffset[0] > 1) {
      _listPlacement[index].previewRatioOffset[0] = 1;
    }
    if (_listPlacement[index].previewRatioOffset[0] > 1) {
      _listPlacement[index].previewRatioOffset[0] = 1;
    }
    widget.onFocusPlacement!(
      _listPlacement[index],
      _matrix4Notifiers[index],
    );
    setState(() {});
  }

  Widget _buildPanGestureWidget(int index) {
    return Stack(
      children: [
        Positioned.fill(
            child: Container(
          margin: const EdgeInsets.all(6),
          decoration:
              BoxDecoration(border: Border.all(color: colorBlue, width: 1.5)),
        )),
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // dot top left
                _buildDotDrag(
                  index,
                  13,
                  // ratioToPixel(_listPlacement[index].ratioWidth, _maxWidth) < minSizePlacement  ? 5   : 15,
                  margin: const EdgeInsets.only(bottom: 7, top: 1, left: 1),
                  onPanUpdate: (details) {
                    final ratioDeltaX =
                        pixelToRatio(details.delta.dx, _maxWidth);
                    final ratioDeltaY =
                        pixelToRatio(details.delta.dy, _maxHeight);

                    if (ratioDeltaX > 0 || ratioDeltaY > 0) {
                      if (_listPlacement[index].ratioHeight >
                              pixelToRatio(minSizePlacement, _maxHeight) &&
                          _listPlacement[index].ratioWidth >
                              pixelToRatio(minSizePlacement, _maxWidth)) {
                        _listPlacement[index].ratioOffset = [
                          _listPlacement[index].ratioOffset[0] + ratioDeltaX,
                          _listPlacement[index].ratioOffset[1] + ratioDeltaY,
                        ];
                        _listPlacement[index].previewRatioOffset = List.from([
                          _listPlacement[index].previewRatioOffset[0] +
                              ratioDeltaX,
                          _listPlacement[index].previewRatioOffset[1] +
                              ratioDeltaY,
                        ]);
                      }
                      if (_listPlacement[index].ratioWidth > ratioDeltaX) {
                        _listPlacement[index].ratioWidth -= ratioDeltaX;
                        _listPlacement[index].previewWidth -= ratioDeltaX;
                      }
                      if (_listPlacement[index].ratioHeight > ratioDeltaY) {
                        _listPlacement[index].ratioHeight -= ratioDeltaY;
                        _listPlacement[index].previewHeight -= ratioDeltaY;
                      }
                    } else {
                      _listPlacement[index].ratioOffset = [
                        _listPlacement[index].ratioOffset[0] +
                            (_listPlacement[index].ratioOffset[0] > 0
                                ? ratioDeltaX
                                : 0),
                        _listPlacement[index].ratioOffset[1] +
                            (_listPlacement[index].ratioOffset[1] > 0
                                ? ratioDeltaY
                                : 0),
                      ];
                      _listPlacement[index].previewRatioOffset = List.from([
                        _listPlacement[index].previewRatioOffset[0] +
                            (_listPlacement[index].ratioOffset[0] > 0
                                ? ratioDeltaX
                                : 0),
                        _listPlacement[index].previewRatioOffset[1] +
                            (_listPlacement[index].ratioOffset[1] > 0
                                ? ratioDeltaY
                                : 0),
                      ]);
                      if (_listPlacement[index].ratioWidth > ratioDeltaX) {
                        if (_listPlacement[index].ratioOffset[0] > 0) {
                          _listPlacement[index].ratioWidth -= ratioDeltaX;
                          _listPlacement[index].previewWidth -= ratioDeltaX;
                        }
                      }
                      if (_listPlacement[index].ratioHeight > ratioDeltaY) {
                        if (_listPlacement[index].ratioOffset[1] > 0) {
                          _listPlacement[index].ratioHeight -= ratioDeltaY;
                          _listPlacement[index].previewHeight -= ratioDeltaY;
                        }
                      }
                    }
                    _snapPositionWidthPoint(index);
                    _checkExceedingDrawBoard(index);
                  },
                  onPanEnd: (details) {},
                ),
                // dot top center
                _buildDotDrag(
                  index,
                  9,
                  margin: const EdgeInsets.only(bottom: 6),
                  onPanUpdate: (details) {
                    final ratioDeltaY =
                        pixelToRatio(details.delta.dy, _maxHeight);
                    if (ratioDeltaY > 0) {
                      _listPlacement[index].ratioOffset = [
                        _listPlacement[index].ratioOffset[0],
                        _listPlacement[index].ratioOffset[1] + ratioDeltaY
                      ];
                      _listPlacement[index].previewRatioOffset = List.from([
                        _listPlacement[index].previewRatioOffset[0],
                        _listPlacement[index].previewRatioOffset[1] +
                            ratioDeltaY,
                      ]);
                      if (_listPlacement[index].ratioHeight > ratioDeltaY) {
                        _listPlacement[index].ratioHeight -= ratioDeltaY;
                        _listPlacement[index].previewHeight -= ratioDeltaY;
                      }
                    } else {
                      if (_listPlacement[index].ratioOffset[1] > 0) {
                        _listPlacement[index].ratioOffset = [
                          _listPlacement[index].ratioOffset[0],
                          _listPlacement[index].ratioOffset[1] + ratioDeltaY
                        ];
                        _listPlacement[index].previewRatioOffset = List.from([
                          _listPlacement[index].previewRatioOffset[0],
                          _listPlacement[index].previewRatioOffset[1] +
                              ratioDeltaY,
                        ]);

                        if (_listPlacement[index].ratioHeight > ratioDeltaY) {
                          _listPlacement[index].ratioHeight -= ratioDeltaY;
                          _listPlacement[index].previewHeight -= ratioDeltaY;
                        }
                      }
                    }
                    _snapPositionWidthPoint3(index);
                    _checkExceedingDrawBoard(index);
                  },
                  onPanStart: (details) {
                    setState(() {});
                  },
                ),
                // dot top right
                _buildDotDrag(
                  index,
                  13,
                  margin: const EdgeInsets.only(bottom: 6),
                  onPanUpdate: (details) {
                    double ratioDeltaX =
                        pixelToRatio(details.delta.dx, _maxWidth);
                    double ratioDeltaY =
                        pixelToRatio(details.delta.dy, _maxHeight);
                    if (ratioDeltaY < 0) {
                      if (_listPlacement[index].ratioOffset[1] > 0) {
                        _listPlacement[index].ratioOffset = [
                          _listPlacement[index].ratioOffset[0],
                          _listPlacement[index].ratioOffset[1] + ratioDeltaY
                        ];
                        _listPlacement[index].previewRatioOffset = List.from([
                          _listPlacement[index].previewRatioOffset[0],
                          _listPlacement[index].previewRatioOffset[1] +
                              ratioDeltaY,
                        ]);
                        if (_listPlacement[index].ratioHeight > ratioDeltaY) {
                          _listPlacement[index].ratioHeight -= ratioDeltaY;
                          _listPlacement[index].previewHeight -= ratioDeltaY;
                        }
                      }
                    } else {
                      _listPlacement[index].ratioOffset = [
                        _listPlacement[index].ratioOffset[0],
                        _listPlacement[index].ratioOffset[1] + ratioDeltaY
                      ];
                      _listPlacement[index].previewRatioOffset = List.from([
                        _listPlacement[index].previewRatioOffset[0],
                        _listPlacement[index].previewRatioOffset[1] +
                            ratioDeltaY,
                      ]);
                      if (_listPlacement[index].ratioHeight > ratioDeltaY) {
                        _listPlacement[index].ratioHeight -= ratioDeltaY;
                        _listPlacement[index].previewHeight -= ratioDeltaY;
                      }
                    }
                    if (ratioDeltaX > 0) {
                      if (_listPlacement[index].ratioWidth +
                              _listPlacement[index].ratioOffset[0] <
                          1) {
                        _listPlacement[index].ratioWidth += ratioDeltaX;
                        _listPlacement[index].previewWidth += ratioDeltaX;
                      }
                    } else {
                      _listPlacement[index].ratioWidth += ratioDeltaX;
                      _listPlacement[index].previewWidth += ratioDeltaX;
                    }
                    _snapPositionWidthPoint3(index);
                    _checkExceedingDrawBoard(index);
                  },
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //dot center left
                _buildDotDrag(
                  index,
                  9,
                  margin: const EdgeInsets.only(left: 3),
                  onPanUpdate: (details) {
                    final ratioDeltaX =
                        pixelToRatio(details.delta.dx, _maxWidth);
                    if (ratioDeltaX > 0) {
                      _listPlacement[index].ratioOffset = [
                        _listPlacement[index].ratioOffset[0] + ratioDeltaX,
                        _listPlacement[index].ratioOffset[1]
                      ];
                      _listPlacement[index].previewRatioOffset = List.from([
                        _listPlacement[index].previewRatioOffset[0] +
                            ratioDeltaX,
                        _listPlacement[index].previewRatioOffset[1],
                      ]);
                      if (_listPlacement[index].ratioWidth > ratioDeltaX) {
                        _listPlacement[index].ratioWidth -= ratioDeltaX;
                        _listPlacement[index].previewWidth -= ratioDeltaX;
                      }
                    } else {
                      if (_listPlacement[index].ratioOffset[0] >= 0) {
                        _listPlacement[index].ratioOffset = [
                          _listPlacement[index].ratioOffset[0] + ratioDeltaX,
                          _listPlacement[index].ratioOffset[1]
                        ];
                        _listPlacement[index].previewRatioOffset = List.from([
                          _listPlacement[index].previewRatioOffset[0] +
                              ratioDeltaX,
                          _listPlacement[index].previewRatioOffset[1],
                        ]);
                        if (_listPlacement[index].ratioWidth > ratioDeltaX) {
                          _listPlacement[index].ratioWidth -= ratioDeltaX;
                          _listPlacement[index].previewWidth -= ratioDeltaX;
                        }
                      }
                    }
                    _snapPositionWidthPoint(index);
                    _checkExceedingDrawBoard(index);
                  },
                  onPanStart: (details) {},
                ),
                // dot center right
                _buildDotDrag(
                  index,
                  9,
                  margin: const EdgeInsets.only(right: 2),
                  onPanUpdate: (details) {
                    final ratioDeltaX =
                        pixelToRatio(details.delta.dx, _maxWidth);
                    if (ratioDeltaX < 0) {
                      _listPlacement[index].ratioWidth += ratioDeltaX;
                      _listPlacement[index].previewWidth += ratioDeltaX;
                    } else {
                      if (_listPlacement[index].ratioWidth +
                              _listPlacement[index].ratioOffset[0] <
                          1) {
                        _listPlacement[index].ratioWidth += ratioDeltaX;
                        _listPlacement[index].previewWidth += ratioDeltaX;
                      }
                    }
                    _snapPositionWidthPoint3(index);
                    _checkExceedingDrawBoard(index);
                  },
                  onPanStart: (details) {},
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // dot bottom left
                _buildDotDrag(
                  index,
                  13,
                  margin: const EdgeInsets.only(top: 11, left: 0.5),
                  onPanUpdate: (details) {
                    final ratioDeltaX =
                        pixelToRatio(details.delta.dx, _maxWidth);
                    final ratioDeltaY =
                        pixelToRatio(details.delta.dy, _maxHeight);
                    if (ratioDeltaY > 0) {
                      if (_listPlacement[index].ratioOffset[1] +
                              _listPlacement[index].ratioHeight <
                          1) {
                        _listPlacement[index].ratioHeight += ratioDeltaY;
                        _listPlacement[index].previewHeight += ratioDeltaY;
                      }
                    } else if (ratioDeltaX < 0) {
                      if (_listPlacement[index].ratioOffset[0] >= 0) {
                        _listPlacement[index].ratioOffset = [
                          _listPlacement[index].ratioOffset[0] + ratioDeltaX,
                          _listPlacement[index].ratioOffset[1]
                        ];
                        _listPlacement[index].previewRatioOffset = List.from([
                          _listPlacement[index].previewRatioOffset[0] +
                              ratioDeltaX,
                          _listPlacement[index].previewRatioOffset[1],
                        ]);
                        if (_listPlacement[index].ratioWidth > ratioDeltaX) {
                          _listPlacement[index].ratioWidth -= ratioDeltaX;
                          _listPlacement[index].previewWidth -= ratioDeltaX;
                        }
                      }
                    } else {
                      _listPlacement[index].ratioOffset = [
                        _listPlacement[index].ratioOffset[0] + ratioDeltaX,
                        _listPlacement[index].ratioOffset[1]
                      ];
                      _listPlacement[index].previewRatioOffset = List.from([
                        _listPlacement[index].previewRatioOffset[0] +
                            ratioDeltaX,
                        _listPlacement[index].previewRatioOffset[1],
                      ]);
                      if (_listPlacement[index].ratioWidth > ratioDeltaX) {
                        _listPlacement[index].ratioWidth -= ratioDeltaX;
                        _listPlacement[index].previewWidth -= ratioDeltaX;
                      }
                      _listPlacement[index].ratioHeight += ratioDeltaY;
                      _listPlacement[index].previewHeight += ratioDeltaY;
                    }
                    _snapPositionWidthPoint1(index);
                    _checkExceedingDrawBoard(index);
                  },
                  onPanStart: (details) {},
                ),
                // dot bottom center
                _buildDotDrag(
                  index,
                  9,
                  margin: const EdgeInsets.only(top: 12, bottom: 0.5),
                  onPanUpdate: (details) {
                    final ratioDeltaY =
                        pixelToRatio(details.delta.dy, _maxHeight);
                    if (ratioDeltaY > 0) {
                      if (_listPlacement[index].ratioHeight +
                              _listPlacement[index].ratioOffset[1] <
                          1) {
                        _listPlacement[index].ratioHeight += ratioDeltaY;
                        _listPlacement[index].previewHeight += ratioDeltaY;
                      }
                    } else {
                      _listPlacement[index].ratioHeight += ratioDeltaY;
                      _listPlacement[index].previewHeight += ratioDeltaY;
                    }
                    _snapPositionWidthPoint1(index);
                    _checkExceedingDrawBoard(index);
                  },
                  onPanStart: (details) {},
                ),
                // dot bottom right
                _buildDotDrag(
                  index,
                  13,
                  margin: const EdgeInsets.only(top: 11),
                  onPanUpdate: (details) {
                    final ratioDeltaX =
                        pixelToRatio(details.delta.dx, _maxWidth);
                    final ratioDeltaY =
                        pixelToRatio(details.delta.dy, _maxHeight);
                    if (ratioDeltaX > 0) {
                      if (_listPlacement[index].ratioOffset[0] +
                              _listPlacement[index].ratioWidth <
                          1) {
                        _listPlacement[index].ratioWidth += ratioDeltaX;
                        _listPlacement[index].previewWidth += ratioDeltaX;
                      }
                    } else if (ratioDeltaY > 0) {
                      if (_listPlacement[index].ratioOffset[1] +
                              _listPlacement[index].ratioHeight <
                          1) {
                        _listPlacement[index].ratioHeight += ratioDeltaY;
                        _listPlacement[index].previewHeight += ratioDeltaY;
                      }
                    } else if (ratioDeltaY > 0 && ratioDeltaX > 0) {
                      _listPlacement[index].ratioWidth += ratioDeltaX;
                      _listPlacement[index].ratioHeight += ratioDeltaY;
                      _listPlacement[index].previewWidth += ratioDeltaX;
                      _listPlacement[index].previewHeight += ratioDeltaY;
                    } else {
                      _listPlacement[index].ratioWidth += ratioDeltaX;
                      _listPlacement[index].ratioHeight += ratioDeltaY;
                      _listPlacement[index].previewWidth += ratioDeltaX;
                      _listPlacement[index].previewHeight += ratioDeltaY;
                    }
                    _snapPositionWidthPoint2(index);
                    _checkExceedingDrawBoard(index);
                  },
                  onPanStart: (details) {},
                )
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDotDrag(int index, double size,
      {void Function(DragUpdateDetails details)? onPanUpdate,
      void Function(DragStartDetails)? onPanStart,
      void Function(DragEndDetails)? onPanEnd,
      void Function()? onTap,
      EdgeInsets? margin,
      Key? key}) {
    return GestureDetector(
      key: key,
      onPanUpdate: (details) {
        onPanUpdate!(details);
        widget.onUpdatePlacement(
            _listPlacement, _listPlacement[index], _matrix4Notifiers[index]);
      },
      onTap: onTap,
      onPanStart: onPanStart,
      child: Container(
        height: size,
        width: size,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(color: Colors.blue, width: 2),
        ),
      ),
    );
  }
}
