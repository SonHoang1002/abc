import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/convert.dart';
import 'package:photo_to_pdf/models/placement.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class WDragZoomImage extends StatefulWidget {
  final Color backgroundColor;
  final List<Placement> listPlacement;
  final List<ValueNotifier<Matrix4>> matrix4Notifiers;
  final Function(List<Placement> placements) updatePlacement;
  final Placement? seletedPlacement;
  final PaperAttribute? paperAttribute;
  final Function(Placement placement, ValueNotifier<Matrix4> matrix4)?
      onFocusPlacement;
  final void Function()? onCancelFocusPlacement;
  final List<double>? ratioTarget;
  const WDragZoomImage(
      {super.key,
      required this.backgroundColor,
      required this.listPlacement,
      required this.matrix4Notifiers,
      required this.updatePlacement,
      this.seletedPlacement,
      this.onFocusPlacement,
      this.ratioTarget = LIST_RATIO_PLACEMENT_BOARD,
      this.paperAttribute,
      this.onCancelFocusPlacement});

  @override
  State<WDragZoomImage> createState() => _WDragZoomImageState();
}

class _WDragZoomImageState extends State<WDragZoomImage> {
  late Size _size;
  List<ValueNotifier<Matrix4>> _matrix4Notifiers = [];
  List<Placement> _listPlacement = [];
  double lastBottom = 0.0;
  Size containerSize = Size.zero;
  final GlobalKey _placementFrame = GlobalKey();
  final GlobalKey _drawAreaKey = GlobalKey();
  static const double minSizePlacement = 30;
  late List<double> _ratioTarget;

  late double _maxHeight;
  late double _maxWidth;
  Placement? _seletedPlacement;

  @override
  void dispose() {
    super.dispose();
    _matrix4Notifiers = [];
    _listPlacement = [];
  }

  @override
  void initState() {
    super.initState();
    _seletedPlacement = widget.seletedPlacement;
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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        containerSize =
            (_placementFrame.currentContext?.findRenderObject() as RenderBox)
                .size;
      });
    });
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

  @override
  Widget build(BuildContext context) {
    _matrix4Notifiers = widget.matrix4Notifiers;
    _listPlacement = widget.listPlacement;
    _maxHeight = _getWidthAndHeight()[1];
    _maxWidth = _getWidthAndHeight()[0];
    return _buildCustomArea();
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
            key: _placementFrame,
            children: _listPlacement.map<Widget>(
              (e) {
                final index = _listPlacement.indexOf(e);
                return GestureDetector(
                  onPanUpdate: (details) {
                    // check real height of draw area
                    double maxAreaHeight = _size.width * _ratioTarget[1];
                    double maxAreaWidth = _size.width * _ratioTarget[0];
                    if (areaBox != null) {
                      if (areaBox.size.height < _size.width * _ratioTarget[1]) {
                        maxAreaHeight = areaBox.size.height - 2;
                      }
                    }
                    _listPlacement[index].ratioOffset = [
                      _listPlacement[index].ratioOffset[0] +
                          pixelToRatio(details.delta.dx, maxAreaWidth),
                      _listPlacement[index].ratioOffset[1] +
                          pixelToRatio(details.delta.dy, maxAreaHeight)
                    ];
                    //left
                    if (_listPlacement[index].ratioOffset[0] <= 0) {
                      _listPlacement[index].ratioOffset = [
                        0,
                        _listPlacement[index].ratioOffset[1]
                      ];
                    }
                    //top
                    if (_listPlacement[index].ratioOffset[1] <= 0) {
                      _listPlacement[index].ratioOffset = [
                        _listPlacement[index].ratioOffset[0],
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
                    }
                    //bottom
                    if (_listPlacement[index].ratioOffset[1] +
                            _listPlacement[index].ratioHeight >=
                        1) {
                      _listPlacement[index].ratioOffset = [
                        _listPlacement[index].ratioOffset[0],
                        1 - _listPlacement[index].ratioHeight
                      ];
                    }
                    widget.updatePlacement(_listPlacement);
                    setState(() {});
                  },
                  onTap: () {
                    if (_seletedPlacement == _listPlacement[index]) {
                      widget.onCancelFocusPlacement != null
                          ? widget.onCancelFocusPlacement!()
                          : null;
                      _seletedPlacement = null;
                      setState(() {});
                    } else {
                      if (widget.onFocusPlacement != null) {
                        widget.onFocusPlacement!(
                            _listPlacement[index], _matrix4Notifiers[index]);
                        _seletedPlacement = _listPlacement[index];
                        setState(() {});
                      }
                    }
                  },
                  onPanStart: (details) {
                    // widget.onFocusPlacement != null
                    //     ? widget.onFocusPlacement!(
                    //         _listPlacement[index], _matrix4Notifiers[index])
                    //     : null;
                  },
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
                                      borderRadius: BorderRadius.circular(12.5),
                                      color: colorBlue),
                                  child: Center(
                                      child: WTextContent(
                                    value: "${index + 1}",
                                    // value:
                                    //     "w:${_listPlacement[index].ratioWidth.toStringAsFixed(1)} h:${_listPlacement[index].ratioHeight.toStringAsFixed(1)} rw:${_listPlacement[index].ratioOffset[0].toStringAsFixed(1)} rh:${_listPlacement[index].ratioOffset[1].toStringAsFixed(1)}",
                                    textColor: colorWhite,
                                    textSize: 10,
                                  )),
                                ),
                              )),
                              _seletedPlacement == _listPlacement[index] &&
                                      widget.seletedPlacement ==
                                          _listPlacement[index]
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
        )
      ],
    );
  }

  double limitLeft(int index) {
    return ((_size.width * (1 - _ratioTarget[0]) / 2) -
        (ratioToPixel(_listPlacement[index].ratioWidth, _maxWidth) <
                    minSizePlacement
                ? 5
                : 15) /
            2);
  }

  double limitRight(int index) {
    return ((_size.width * _ratioTarget[0] +
            _size.width * (1 - _ratioTarget[0]) / 2) +
        (ratioToPixel(_listPlacement[index].ratioWidth, _maxWidth) <
                    minSizePlacement
                ? 5
                : 15) /
            2);
  }

  Widget _buildPanGestureWidget(int index) {
    return Stack(
      children: [
        Positioned.fill(
            child: Container(
          margin: const EdgeInsets.all(5),
          decoration:
              BoxDecoration(border: Border.all(color: colorBlue, width: 2)),
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
                  12,
                  // ratioToPixel(_listPlacement[index].ratioWidth, _maxWidth) < minSizePlacement  ? 5   : 15,
                  margin: const EdgeInsets.only(bottom: 10),
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
                          _listPlacement[index].ratioOffset[0] +
                              pixelToRatio(details.delta.dx, _maxWidth),
                          _listPlacement[index].ratioOffset[1] +
                              pixelToRatio(details.delta.dy, _maxHeight),
                        ];
                      }
                      if (_listPlacement[index].ratioWidth > ratioDeltaX) {
                        _listPlacement[index].ratioWidth -= ratioDeltaX;
                      }

                      if (_listPlacement[index].ratioHeight > ratioDeltaY) {
                        _listPlacement[index].ratioHeight -= ratioDeltaY;
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

                      if (_listPlacement[index].ratioWidth > ratioDeltaX) {
                        if (_listPlacement[index].ratioOffset[0] > 0) {
                          _listPlacement[index].ratioWidth -= ratioDeltaX;
                        }
                      }
                      if (_listPlacement[index].ratioHeight > ratioDeltaY) {
                        if (_listPlacement[index].ratioOffset[1] > 0) {
                          _listPlacement[index].ratioHeight -= ratioDeltaY;
                        }
                      }
                    }
                    widget.updatePlacement(_listPlacement);
                    setState(() {});
                  },
                  onPanEnd: (details) {},
                ),
                // dot top center
                _buildDotDrag(
                  index,
                  8,
                  // ratioToPixel(_listPlacement[index].ratioWidth, _maxWidth) < minSizePlacement ? 2  : 12,
                  margin: const EdgeInsets.only(bottom: 10),
                  onPanUpdate: (details) {
                    final ratioDeltaY =
                        pixelToRatio(details.delta.dy, _maxHeight);
                    if (ratioDeltaY > 0) {
                      _listPlacement[index].ratioOffset = [
                        _listPlacement[index].ratioOffset[0],
                        _listPlacement[index].ratioOffset[1] + ratioDeltaY
                      ];
                      if (_listPlacement[index].ratioHeight > ratioDeltaY) {
                        _listPlacement[index].ratioHeight -= ratioDeltaY;

                        widget.updatePlacement(_listPlacement);
                        setState(() {});
                      }
                    } else {
                      if (_listPlacement[index].ratioOffset[1] > 0) {
                        _listPlacement[index].ratioOffset = [
                          _listPlacement[index].ratioOffset[0],
                          _listPlacement[index].ratioOffset[1] + ratioDeltaY
                        ];
                        if (_listPlacement[index].ratioHeight > ratioDeltaY) {
                          _listPlacement[index].ratioHeight -= ratioDeltaY;
                        }
                        widget.updatePlacement(_listPlacement);
                        setState(() {});
                      }
                    }
                  },
                  onPanStart: (details) {
                    setState(() {});
                  },
                ),
                // dot top right
                _buildDotDrag(
                  index,
                  12,
                  // ratioToPixel(_listPlacement[index].ratioWidth, _maxWidth) <  minSizePlacement ? 5  : 15,
                  margin: const EdgeInsets.only(bottom: 10),
                  onPanUpdate: (details) {
                    final ratioDeltaX =
                        pixelToRatio(details.delta.dx, _maxWidth);
                    final ratioDeltaY =
                        pixelToRatio(details.delta.dy, _maxHeight);
                    //   rut gon
                    //   _listPlacement[index].offset +=
                    //         Offset(0, details.delta.dy);
                    //     if (checkMinArea(index) &&
                    //         _listPlacement[index].height > details.delta.dy) {
                    //       _listPlacement[index].height -= details.delta.dy;
                    //     }
                    //    _listPlacement[index].width += details.delta.dx;

                    // chi mo rong height -> deltaY <0
                    if (ratioDeltaY < 0) {
                      if (_listPlacement[index].ratioOffset[1] > 0) {
                        _listPlacement[index].ratioOffset = [
                          _listPlacement[index].ratioOffset[0],
                          _listPlacement[index].ratioOffset[1] + ratioDeltaY
                        ];

                        if (_listPlacement[index].ratioHeight > ratioDeltaY) {
                          _listPlacement[index].ratioHeight -= ratioDeltaY;
                        }
                      }
                      // chi mo rong width  -> deltaX >0
                    } else if (ratioDeltaX > 0) {
                      if (_listPlacement[index].ratioWidth +
                              _listPlacement[index].ratioOffset[0] <
                          1) {
                        _listPlacement[index].ratioWidth += ratioDeltaX;
                      }
                      // mo rong ca hai     -> deltaX >0 && deltaY < 0 va thu hep
                    } else {
                      _listPlacement[index].ratioOffset = [
                        _listPlacement[index].ratioOffset[0],
                        _listPlacement[index].ratioOffset[1] + ratioDeltaY
                      ];
                      _listPlacement[index].ratioWidth += ratioDeltaX;
                      if (_listPlacement[index].ratioHeight > ratioDeltaY) {
                        _listPlacement[index].ratioHeight -= ratioDeltaY;
                      }
                    }
                    setState(() {});
                  },
                  onPanStart: (p0) {},
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
                  8,
                  // ratioToPixel(_listPlacement[index].ratioWidth, _maxWidth) <  minSizePlacement ? 2 : 12,
                  margin: const EdgeInsets.only(left: 2),
                  onPanUpdate: (details) {
                    final ratioDeltaX =
                        pixelToRatio(details.delta.dx, _maxWidth);
                    if (ratioDeltaX > 0) {
                      _listPlacement[index].ratioOffset = [
                        _listPlacement[index].ratioOffset[0] + ratioDeltaX,
                        _listPlacement[index].ratioOffset[1]
                      ];
                      if (_listPlacement[index].ratioWidth > ratioDeltaX) {
                        _listPlacement[index].ratioWidth -= ratioDeltaX;
                      }
                      setState(() {});
                    } else {
                      if (_listPlacement[index].ratioOffset[0] >= 0) {
                        _listPlacement[index].ratioOffset = [
                          _listPlacement[index].ratioOffset[0] + ratioDeltaX,
                          _listPlacement[index].ratioOffset[1]
                        ];
                        if (_listPlacement[index].ratioWidth > ratioDeltaX) {
                          _listPlacement[index].ratioWidth -= ratioDeltaX;
                        }
                        setState(() {});
                      }
                    }
                  },
                  onPanStart: (details) {},
                ),
                // dot center right
                _buildDotDrag(
                  index,
                  8,
                  margin: const EdgeInsets.only(right: 2),
                  onPanUpdate: (details) {
                    final ratioDeltaX =
                        pixelToRatio(details.delta.dx, _maxWidth);
                    if (ratioDeltaX < 0) {
                      setState(() {
                        _listPlacement[index].ratioWidth += ratioDeltaX;
                      });
                    } else {
                      if (_listPlacement[index].ratioWidth +
                              _listPlacement[index].ratioOffset[0] <
                          1) {
                        setState(() {
                          _listPlacement[index].ratioWidth += ratioDeltaX;
                        });
                      }
                    }
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
                  12,
                  // ratioToPixel(_listPlacement[index].ratioWidth, _maxWidth) < minSizePlacement  ? 5 : 15,
                  margin: const EdgeInsets.only(top: 11),
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
                      }
                    } else if (ratioDeltaX < 0) {
                      if (_listPlacement[index].ratioOffset[0] >= 0) {
                        _listPlacement[index].ratioOffset = [
                          _listPlacement[index].ratioOffset[0] + ratioDeltaX,
                          _listPlacement[index].ratioOffset[1]
                        ];
                        if (_listPlacement[index].ratioWidth > ratioDeltaX) {
                          _listPlacement[index].ratioWidth -= ratioDeltaX;
                        }
                      }
                    } else {
                      _listPlacement[index].ratioOffset = [
                        _listPlacement[index].ratioOffset[0] + ratioDeltaX,
                        _listPlacement[index].ratioOffset[1]
                      ];
                      if (_listPlacement[index].ratioWidth > ratioDeltaX) {
                        _listPlacement[index].ratioWidth -= ratioDeltaX;
                      }
                      _listPlacement[index].ratioHeight += ratioDeltaY;
                    }

                    setState(() {});
                  },
                  onPanStart: (details) {},
                ),
                // dot bottom center
                _buildDotDrag(
                  index,
                  8,
                  // ratioToPixel(_listPlacement[index].ratioWidth, _maxWidth) < minSizePlacement ? 2  : 12,
                  margin: const EdgeInsets.only(top: 12),
                  onPanUpdate: (details) {
                    final ratioDeltaY =
                        pixelToRatio(details.delta.dy, _maxHeight);
                    if (ratioDeltaY > 0) {
                      if (_listPlacement[index].ratioHeight +
                              _listPlacement[index].ratioOffset[1] <
                          1) {
                        setState(() {
                          _listPlacement[index].ratioHeight += ratioDeltaY;
                        });
                      }
                    } else {
                      setState(() {
                        _listPlacement[index].ratioHeight += ratioDeltaY;
                      });
                    }
                  },
                  onPanStart: (details) {},
                ),
                // dot bottom right
                _buildDotDrag(
                  index,
                  12,
                  // ratioToPixel(_listPlacement[index].ratioWidth, _maxWidth) <  minSizePlacement ? 5 : 15,
                  margin: const EdgeInsets.only(top: 10),
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
                      }
                    } else if (ratioDeltaY > 0) {
                      if (_listPlacement[index].ratioOffset[1] +
                              _listPlacement[index].ratioHeight <
                          1) {
                        _listPlacement[index].ratioHeight += ratioDeltaY;
                      }
                    } else if (ratioDeltaY > 0 && ratioDeltaX > 0) {
                      _listPlacement[index].ratioWidth += ratioDeltaX;
                      _listPlacement[index].ratioHeight += ratioDeltaY;
                    } else {
                      _listPlacement[index].ratioWidth += ratioDeltaX;
                      _listPlacement[index].ratioHeight += ratioDeltaY;
                    }

                    setState(() {});
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
        widget.updatePlacement(_listPlacement);
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
