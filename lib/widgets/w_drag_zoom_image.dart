import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/random_number.dart';
import 'package:photo_to_pdf/models/placement.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class WDragZoomImage extends StatefulWidget {
  final Function reRenerFunction;
  final List<Placement> listPlacement;
  final List<ValueNotifier<Matrix4>> matrix4Notifiers;
  final Function(List<Placement> placements) updatePlacement;
  final Placement? seletedPlacement;
  final Function(Placement placement, ValueNotifier<Matrix4> matrix4)?
      onFocusPlacement;
  const WDragZoomImage({
    super.key,
    required this.reRenerFunction,
    required this.listPlacement,
    required this.matrix4Notifiers,
    required this.updatePlacement,
    this.seletedPlacement,
    this.onFocusPlacement,
  });

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
  GlobalKey dot1Key = GlobalKey();
  @override
  void initState() {
    super.initState();

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

  bool checkMinArea(int index) {
    return _listPlacement[index].height > 30 &&
        _listPlacement[index].width > 30;
  }

  @override
  Widget build(BuildContext context) {
    _matrix4Notifiers = widget.matrix4Notifiers;
    _listPlacement = widget.listPlacement;
    return _buildCustomArea();
  }

  Widget _buildCustomArea() {
    return Stack(
      alignment: Alignment.center,
        children: [
      Container(
        alignment: Alignment.center,
        child: Container(
          width: _size.width * LIST_RATIO_PLACEMENT_BOARD[0],
          height: _size.width * LIST_RATIO_PLACEMENT_BOARD[1],
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
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
        width: _size.width * LIST_RATIO_PLACEMENT_BOARD[0]+15,
        height: _size.width * LIST_RATIO_PLACEMENT_BOARD[1]+15,
        child: Stack(
          key: _placementFrame,
          children: _listPlacement.map<Widget>(
            (e) {
              final index = _listPlacement.indexOf(e);
              return GestureDetector(
                onPanUpdate: (details) {
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
                      _size.width * LIST_RATIO_PLACEMENT_BOARD[0]) {
                    _listPlacement[index].offset = Offset(
                        _size.width * LIST_RATIO_PLACEMENT_BOARD[0] -
                            _listPlacement[index].width,
                        _listPlacement[index].offset.dy);
                  }
                  //bottom
                  if (_listPlacement[index].offset.dy +
                          _listPlacement[index].height >=
                      _size.width * LIST_RATIO_PLACEMENT_BOARD[1]) {
                    _listPlacement[index].offset = Offset(
                        _listPlacement[index].offset.dx,
                        _size.width * LIST_RATIO_PLACEMENT_BOARD[1] -
                            _listPlacement[index].height);
                  }
                  widget.updatePlacement(_listPlacement);
                  setState(() {});
                },
                onTap: () {
                  widget.onFocusPlacement != null
                      ? widget.onFocusPlacement!(
                          _listPlacement[index],
                          _matrix4Notifiers[index])
                      : null;
                },
                onPanStart: (details) {
                  widget.onFocusPlacement != null
                      ? widget.onFocusPlacement!(
                          _listPlacement[index],
                          _matrix4Notifiers[index])
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
                                    borderRadius:
                                        BorderRadius.circular(12.5),
                                    color: colorBlue),
                                child: Center(
                                    child: WTextContent(
                                  value: index.toString(),
                                  textColor: colorWhite,
                                )),
                              ),
                            )),
                            widget.seletedPlacement ==
                                    _listPlacement[index]
                                ? Positioned.fill(
                                    child:
                                        _buildPanGestureWidget(index))
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
    return ((_size.width * (1 - LIST_RATIO_PLACEMENT_BOARD[0]) / 2) -
        (_listPlacement[index].width < 30 ? 5 : 15) / 2);
  }

  double limitRight(int index) {
    return ((_size.width * LIST_RATIO_PLACEMENT_BOARD[0] +
            _size.width * (1 - LIST_RATIO_PLACEMENT_BOARD[0]) / 2) +
        (_listPlacement[index].width < 30 ? 5 : 15) / 2);
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
                  _listPlacement[index].width < 30 ? 5 : 15,
                  margin: const EdgeInsets.only(bottom: 10),
                  onPanUpdate: (details) {
                    final box =
                        dot1Key.currentContext?.findRenderObject() as RenderBox;

                    _listPlacement[index].offset =
                        _listPlacement[index].offset + details.delta;

                    // if (box.localToGlobal(const Offset(0, 0)).dx >
                    //     limitLeft(index)) {
                    //   _listPlacement[index].offset = Offset(
                    //       _listPlacement[index].offset.dx,
                    //       (_listPlacement[index].offset + details.delta).dy);
                    // } else {
                    //   _listPlacement[index].offset =
                    //       _listPlacement[index].offset + details.delta;
                    // }
                    if (checkMinArea(index) &&
                        _listPlacement[index].width > details.delta.dx) {
                      // if (box.localToGlobal(const Offset(0, 0)).dx >
                      //     limitLeft(index)) {
                      _listPlacement[index].width -= details.delta.dx;
                      // }
                    }

                    if (checkMinArea(index) &&
                        _listPlacement[index].height > details.delta.dy) {
                      _listPlacement[index].height -= details.delta.dy;
                    }
                    widget.updatePlacement(_listPlacement);
                    setState(() {});
                  },
                  key: dot1Key,
                  onPanStart: (details) {},
                ),
                // dot top center
                _buildDotDrag(
                  index,
                  _listPlacement[index].width < 30 ? 2 : 12,
                  margin: const EdgeInsets.only(bottom: 11),
                  onPanUpdate: (details) {
                    if (checkMinArea(index) &&
                        _listPlacement[index].height > details.delta.dy) {
                      _listPlacement[index].height -= details.delta.dy;
                    }
                    _listPlacement[index].offset = Offset(
                        _listPlacement[index].offset.dx,
                        (lastBottom - _listPlacement[index].height).abs());
                    widget.updatePlacement(_listPlacement);
                    setState(() {});
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
                  _listPlacement[index].width < 30 ? 5 : 15,
                  margin: const EdgeInsets.only(bottom: 10),
                  onPanUpdate: (details) {
                    _listPlacement[index].offset = _listPlacement[index]
                        .offset
                        .translate(0, details.delta.dy);
                    _listPlacement[index].width += details.delta.dx;
                    if (checkMinArea(index) &&
                        _listPlacement[index].height > details.delta.dy) {
                      _listPlacement[index].height -= details.delta.dy;
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
                  _listPlacement[index].width < 30 ? 2 : 12,
                  margin: const EdgeInsets.only(right: 11),
                  onPanUpdate: (details) {
                    _listPlacement[index].offset = _listPlacement[index]
                        .offset
                        .translate(details.delta.dx, 0);
                    if (checkMinArea(index) &&
                        _listPlacement[index].width > details.delta.dx) {
                      _listPlacement[index].width -= details.delta.dx;
                    }
                    setState(() {});
                    // widget.updatePlacement(index,_listPlacement[index].copyWith(offset: _listPlacement[index].offset+details.delta));
                  },
                  onPanStart: (details) {},
                ),
                // dot center right
                _buildDotDrag(
                  index,
                  _listPlacement[index].width < 30 ? 2 : 12,
                  margin: const EdgeInsets.only(left: 11),
                  onPanUpdate: (details) {
                    setState(() {
                      _listPlacement[index].width += details.delta.dx;
                    });
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
                  _listPlacement[index].width < 30 ? 5 : 15,
                  margin: const EdgeInsets.only(top: 11),
                  onPanUpdate: (details) {
                    _listPlacement[index].offset = _listPlacement[index]
                        .offset
                        .translate(details.delta.dx, 0);
                    if (checkMinArea(index) &&
                        _listPlacement[index].width > details.delta.dx) {
                      _listPlacement[index].width -= details.delta.dx;
                    }
                    _listPlacement[index].height += details.delta.dy;
                    setState(() {});
                  },
                  onPanStart: (details) {},
                ),
                // dot bottom center
                _buildDotDrag(
                  index,
                  _listPlacement[index].width < 30 ? 2 : 12,
                  margin: const EdgeInsets.only(top: 11),
                  onPanUpdate: (details) {
                    setState(() {
                      _listPlacement[index].height += details.delta.dy;
                    });
                  },
                  onPanStart: (details) {},
                ),
                // dot bottom right
                _buildDotDrag(
                  index,
                  _listPlacement[index].width < 30 ? 5 : 15,
                  margin: const EdgeInsets.only(top: 11),
                  onPanUpdate: (details) {
                    setState(() {
                      _listPlacement[index].width += details.delta.dx;
                      _listPlacement[index].height += details.delta.dy;
                    });
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
      {Function(DragUpdateDetails details)? onPanUpdate,
      void Function(DragStartDetails)? onPanStart,
      Function()? onTap,
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
