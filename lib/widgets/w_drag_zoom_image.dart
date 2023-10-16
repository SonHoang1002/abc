import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/models/placement.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class WDragZoomImage extends StatefulWidget {
  final Color backgroundColor;
  final Function reRenerFunction;
  final List<Placement> listPlacement;
  final List<ValueNotifier<Matrix4>> matrix4Notifiers;
  final Function(List<Placement> placements) updatePlacement;
  final Placement? seletedPlacement;
  final PaperAttribute? paperAttribute;
  final Function(Placement placement, ValueNotifier<Matrix4> matrix4)?
      onFocusPlacement;
  final List<double>? ratioTarget;
  const WDragZoomImage(
      {super.key,
      required this.backgroundColor,
      required this.reRenerFunction,
      required this.listPlacement,
      required this.matrix4Notifiers,
      required this.updatePlacement,
      this.seletedPlacement,
      this.onFocusPlacement,
      this.ratioTarget = LIST_RATIO_PLACEMENT_BOARD,
      this.paperAttribute});

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

  @override
  void dispose() {
    super.dispose();
    _matrix4Notifiers = [];
    _listPlacement = [];
  }

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    _matrix4Notifiers = widget.matrix4Notifiers;
    _listPlacement = widget.listPlacement;
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
            width: _size.width * _ratioTarget[0],
            height: _size.width * _ratioTarget[1],
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
          width: _size.width * _ratioTarget[0] + 15,
          height: _size.width * _ratioTarget[1] + 15,
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
                      if (areaBox.size.height <
                          _size.width * _ratioTarget[1]) {
                        maxAreaHeight = areaBox.size.height - 2;
                      }
                    }
                    _listPlacement[index].offset = _listPlacement[index]
                        .offset
                        .translate(details.delta.dx, details.delta.dy);
                    //left
                    if (_listPlacement[index].offset.dx <= 0) {
                      _listPlacement[index].offset =
                          Offset(0, _listPlacement[index].offset.dy);
                    }
                    //top
                    if (_listPlacement[index].offset.dy <= 0) {
                      _listPlacement[index].offset =
                          Offset(_listPlacement[index].offset.dx, 0);
                    }
                    //right
                    if (_listPlacement[index].offset.dx +
                            _listPlacement[index].width >=
                        maxAreaWidth) {
                      _listPlacement[index].offset = Offset(
                          maxAreaWidth - _listPlacement[index].width,
                          _listPlacement[index].offset.dy);
                    }
                    //bottom
                    if (_listPlacement[index].offset.dy +
                            _listPlacement[index].height >=
                        maxAreaHeight) {
                      _listPlacement[index].offset = Offset(
                          _listPlacement[index].offset.dx,
                          maxAreaHeight - _listPlacement[index].height);
                    }
                    widget.updatePlacement(_listPlacement);
                    setState(() {});
                  },
                  onTap: () {
                    widget.onFocusPlacement != null
                        ? widget.onFocusPlacement!(
                            _listPlacement[index], _matrix4Notifiers[index])
                        : null;
                  },
                  onPanStart: (details) {
                    widget.onFocusPlacement != null
                        ? widget.onFocusPlacement!(
                            _listPlacement[index], _matrix4Notifiers[index])
                        : null;
                  },
                  child: AnimatedBuilder(
                    animation: _matrix4Notifiers[index],
                    builder: (context, child) {
                      return Stack(
                        children: [
                          Positioned(
                            top: _listPlacement[index].offset.dy,
                            left: _listPlacement[index].offset.dx,
                            child: Stack(children: [
                              Container(
                                margin: const EdgeInsets.all(7),
                                child: Image.asset(
                                  "${pathPrefixImage}image_demo.png",
                                  fit: BoxFit.cover,
                                  height: _listPlacement[index].height,
                                  width: _listPlacement[index].width,
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
                                    value: (index+1).toString(),
                                    textColor: colorWhite,
                                  )),
                                ),
                              )),
                              widget.seletedPlacement == _listPlacement[index]
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
        (_listPlacement[index].width < minSizePlacement ? 5 : 15) / 2);
  }

  double limitRight(int index) {
    return ((_size.width * _ratioTarget[0] +
            _size.width * (1 - _ratioTarget[0]) / 2) +
        (_listPlacement[index].width < minSizePlacement ? 5 : 15) / 2);
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
                  _listPlacement[index].width < minSizePlacement ? 5 : 15,
                  margin: const EdgeInsets.only(bottom: 10),
                  onPanUpdate: (details) {
                    final deltaX = details.delta.dx;
                    final deltaY = details.delta.dy;

                    if (deltaX > 0 || deltaY > 0) {
                      if (_listPlacement[index].height > minSizePlacement &&
                          _listPlacement[index].width > minSizePlacement) {
                        _listPlacement[index].offset =
                            _listPlacement[index].offset + details.delta;
                      }
                      if (_listPlacement[index].width > deltaX) {
                        _listPlacement[index].width -= deltaX;
                      }

                      if (_listPlacement[index].height > deltaY) {
                        _listPlacement[index].height -= deltaY;
                      }
                    } else {
                      _listPlacement[index].offset += Offset(
                          _listPlacement[index].offset.dx > 0 ? deltaX : 0,
                          _listPlacement[index].offset.dy > 0 ? deltaY : 0);
                      if (_listPlacement[index].width > deltaX) {
                        if (_listPlacement[index].offset.dx > 0) {
                          _listPlacement[index].width -= deltaX;
                        }
                      }
                      if (_listPlacement[index].height > deltaY) {
                        if (_listPlacement[index].offset.dy > 0) {
                          _listPlacement[index].height -= deltaY;
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
                  _listPlacement[index].width < minSizePlacement ? 2 : 12,
                  margin: const EdgeInsets.only(bottom: 11),
                  onPanUpdate: (details) {
                    final deltaY = details.delta.dy;
                    if (deltaY > 0) {
                      _listPlacement[index].offset += Offset(0, deltaY);
                      if (_listPlacement[index].height > details.delta.dy) {
                        _listPlacement[index].height -= details.delta.dy;

                        widget.updatePlacement(_listPlacement);
                        setState(() {});
                      }
                    } else {
                      if (_listPlacement[index].offset.dy > 0) {
                        _listPlacement[index].offset += Offset(0, deltaY);
                        if (_listPlacement[index].height > details.delta.dy) {
                          _listPlacement[index].height -= details.delta.dy;
                        }
                        widget.updatePlacement(_listPlacement);
                        setState(() {});
                      }
                    }
                  },
                  onPanStart: (details) {
                    lastBottom = _listPlacement[index].height +
                        _listPlacement[index].offset.dy;
                    setState(() {});
                  },
                ),
                // dot top right
                _buildDotDrag(
                  index,
                  _listPlacement[index].width < minSizePlacement ? 5 : 15,
                  margin: const EdgeInsets.only(bottom: 10),
                  onPanUpdate: (details) {
                    final deltaX = details.delta.dx;
                    final deltaY = details.delta.dy;
                    final maxWidth = _size.width * _ratioTarget[0];
                    //   rut gon
                    //   _listPlacement[index].offset +=
                    //         Offset(0, details.delta.dy);
                    //     if (checkMinArea(index) &&
                    //         _listPlacement[index].height > details.delta.dy) {
                    //       _listPlacement[index].height -= details.delta.dy;
                    //     }
                    //    _listPlacement[index].width += details.delta.dx;

                    // chi mo rong height -> deltaY <0
                    if (deltaY < 0) {
                      if (_listPlacement[index].offset.dy > 0) {
                        _listPlacement[index].offset +=
                            Offset(0, details.delta.dy);
                        if (_listPlacement[index].height > details.delta.dy) {
                          _listPlacement[index].height -= details.delta.dy;
                        }
                      }
                      // chi mo rong width  -> deltaX >0
                    } else if (deltaX > 0) {
                      if (_listPlacement[index].width +
                              _listPlacement[index].offset.dx <
                          maxWidth) {
                        _listPlacement[index].width += details.delta.dx;
                      }
                      // mo rong ca hai     -> deltaX >0 && deltaY < 0 va thu hep
                    } else {
                      _listPlacement[index].offset +=
                          Offset(0, details.delta.dy);
                      _listPlacement[index].width += details.delta.dx;
                      if (_listPlacement[index].height > details.delta.dy) {
                        _listPlacement[index].height -= details.delta.dy;
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
                  _listPlacement[index].width < minSizePlacement ? 2 : 12,
                  margin: const EdgeInsets.only(right: 11),
                  onPanUpdate: (details) {
                    if (details.delta.dx > 0) {
                      _listPlacement[index].offset +=
                          Offset(details.delta.dx, 0);
                      if (_listPlacement[index].width > details.delta.dx) {
                        _listPlacement[index].width -= details.delta.dx;
                      }
                      setState(() {});
                    } else {
                      if (_listPlacement[index].offset.dx >= 0) {
                        _listPlacement[index].offset +=
                            Offset(details.delta.dx, 0);
                        if (_listPlacement[index].width > details.delta.dx) {
                          _listPlacement[index].width -= details.delta.dx;
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
                  _listPlacement[index].width < minSizePlacement ? 2 : 12,
                  margin: const EdgeInsets.only(left: 11),
                  onPanUpdate: (details) {
                    final maxWidth = _size.width * _ratioTarget[0];
                    if (details.delta.dx < 0) {
                      setState(() {
                        _listPlacement[index].width += details.delta.dx;
                      });
                    } else {
                      if (_listPlacement[index].width +
                              _listPlacement[index].offset.dx <
                          maxWidth) {
                        setState(() {
                          _listPlacement[index].width += details.delta.dx;
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
                  _listPlacement[index].width < minSizePlacement ? 5 : 15,
                  margin: const EdgeInsets.only(top: 11),
                  onPanUpdate: (details) {
                    final deltaX = details.delta.dx;
                    final deltaY = details.delta.dy;
                    final maxHeight = _size.width * _ratioTarget[1];

                    if (deltaY > 0) {
                      if (_listPlacement[index].offset.dy +
                              _listPlacement[index].height <
                          maxHeight) {
                        _listPlacement[index].height += details.delta.dy;
                      }
                    } else if (deltaX < 0) {
                      if (_listPlacement[index].offset.dx >= 0) {
                        _listPlacement[index].offset +=
                            Offset(details.delta.dx, 0);
                        if (_listPlacement[index].width > details.delta.dx) {
                          _listPlacement[index].width -= details.delta.dx;
                        }
                      }
                    } else {
                      _listPlacement[index].offset +=
                          Offset(details.delta.dx, 0);
                      if (_listPlacement[index].width > details.delta.dx) {
                        _listPlacement[index].width -= details.delta.dx;
                      }
                      _listPlacement[index].height += details.delta.dy;
                    }

                    setState(() {});
                  },
                  onPanStart: (details) {},
                ),
                // dot bottom center
                _buildDotDrag(
                  index,
                  _listPlacement[index].width < minSizePlacement ? 2 : 12,
                  margin: const EdgeInsets.only(top: 11),
                  onPanUpdate: (details) {
                    if (details.delta.dy > 0) {
                      if (_listPlacement[index].height +
                              _listPlacement[index].offset.dy <
                          (_size.width * _ratioTarget[1])) {
                        setState(() {
                          _listPlacement[index].height += details.delta.dy;
                        });
                      }
                    } else {
                      setState(() {
                        _listPlacement[index].height += details.delta.dy;
                      });
                    }
                  },
                  onPanStart: (details) {},
                ),
                // dot bottom right
                _buildDotDrag(
                  index,
                  _listPlacement[index].width < minSizePlacement ? 5 : 15,
                  margin: const EdgeInsets.only(top: 11),
                  onPanUpdate: (details) {
                    final deltaX = details.delta.dx;
                    final deltaY = details.delta.dy;
                    final maxWidth = _size.width * _ratioTarget[0];
                    final maxHeight = _size.width * _ratioTarget[1];
                    if (deltaX > 0) {
                      if (_listPlacement[index].offset.dx +
                              _listPlacement[index].width <
                          maxWidth) {
                        _listPlacement[index].width += details.delta.dx;
                      }
                    } else if (deltaY > 0) {
                      if (_listPlacement[index].offset.dy +
                              _listPlacement[index].height <
                          maxHeight) {
                        _listPlacement[index].height += details.delta.dy;
                      }
                    } else if (deltaY > 0 && deltaX > 0) {
                      _listPlacement[index].width += details.delta.dx;
                      _listPlacement[index].height += details.delta.dy;
                    } else {
                      _listPlacement[index].width += details.delta.dx;
                      _listPlacement[index].height += details.delta.dy;
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
