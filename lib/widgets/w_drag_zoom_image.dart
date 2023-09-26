import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/models/placement.dart';

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

  @override
  void initState() {
    super.initState();

    _matrix4Notifiers.add(ValueNotifier(Matrix4.identity()));
    _listPlacement.add(Placement(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        offset: const Offset(0, 0)));
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
    print("containerSize ${containerSize}");
    return _buildCustomArea();
  }

  Widget _buildCustomArea() {
    return Padding(
      // height: _size.height * 404 / 791 * 0.9,
      // width: _size.width,
      // decoration: BoxDecoration(
      //     color: const Color.fromRGBO(0, 0, 0, 0.03),
      //     borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(children: [
        Expanded(
            child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              child: Container(
                width: _size.width * 0.75,
                height: _size.width * 0.85,
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
              child: Container(
                width: _size.width * 0.8,
                height: _size.width * 0.9,
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 3),
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
                              _size.width * 0.75) {
                            _listPlacement[index].offset = Offset(
                                _size.width * 0.75 -
                                    _listPlacement[index].width,
                                _listPlacement[index].offset.dy);
                          }
                          //bottom
                          if (_listPlacement[index].offset.dy +
                                  _listPlacement[index].height >=
                              _size.width * 0.85) {
                            _listPlacement[index].offset = Offset(
                                _listPlacement[index].offset.dx,
                                _size.width * 0.85 -
                                    _listPlacement[index].height);
                          }
                          widget.updatePlacement(_listPlacement);
                          setState(() {});
                        },
                        onTap: () {
                          widget.onFocusPlacement != null
                              ? widget.onFocusPlacement!(_listPlacement[index],
                                  _matrix4Notifiers[index])
                              : null;
                        },
                        onPanStart: (details) {
                          widget.onFocusPlacement != null
                              ? widget.onFocusPlacement!(_listPlacement[index],
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
                                      child: Text(
                                          _listPlacement[index].id.toString()),
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
              ),
            )
          ],
        )),
        const SizedBox(height: 10),
      ]),
    );
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
                  15,
                  margin: const EdgeInsets.only(bottom: 10),
                  onPanUpdate: (details) {
                    _listPlacement[index].offset =
                        _listPlacement[index].offset + details.delta;
                    widget.updatePlacement(
                        widget.updatePlacement(_listPlacement));
                    setState(() {
                      _listPlacement[index].width -= details.delta.dx;
                      _listPlacement[index].height -= details.delta.dy;
                    });
                  },
                  onPanStart: (details) {
                    setState(() {
                      _listPlacement[index].alignment = Alignment.center;
                    });
                  },
                ),
                // dot top center
                _buildDotDrag(
                  index,
                  12,
                  margin: const EdgeInsets.only(bottom: 11),
                  onPanUpdate: (details) {
                    _listPlacement[index].height -= details.delta.dy;
                    _listPlacement[index].offset = Offset(
                        _listPlacement[index].offset.dx,
                        lastBottom - _listPlacement[index].height);
                    widget.updatePlacement(
                        widget.updatePlacement(_listPlacement));
                    setState(() {});
                  },
                  onPanStart: (details) {
                    lastBottom = _listPlacement[index].height +
                        _listPlacement[index].offset.dy;
                    setState(() {
                      _listPlacement[index].alignment = Alignment.bottomCenter;
                    });
                  },
                ),
                // dot top right
                _buildDotDrag(
                  index,
                  15,
                  margin: const EdgeInsets.only(bottom: 10),
                  onPanUpdate: (details) {
                    _listPlacement[index].offset = _listPlacement[index]
                        .offset
                        .translate(0, details.delta.dy);
                    _listPlacement[index].width += details.delta.dx;
                    _listPlacement[index].height -= details.delta.dy;
                    setState(() {});
                  },
                  onPanStart: (p0) {
                    setState(() {
                      _listPlacement[index].alignment = Alignment.center;
                    });
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
                  12,
                  margin: const EdgeInsets.only(right: 11),
                  onPanUpdate: (details) {
                    _listPlacement[index].offset = _listPlacement[index]
                        .offset
                        .translate(details.delta.dx, 0);
                    setState(() {
                      _listPlacement[index].width -= details.delta.dx;
                    });
                    // widget.updatePlacement(index,_listPlacement[index].copyWith(offset: _listPlacement[index].offset+details.delta));
                  },
                  onPanStart: (details) {
                    setState(() {
                      _listPlacement[index].alignment = Alignment.centerRight;
                    });
                  },
                ),
                // dot center right
                _buildDotDrag(
                  index,
                  12,
                  margin: const EdgeInsets.only(left: 11),
                  onPanUpdate: (details) {
                    setState(() {
                      _listPlacement[index].width += details.delta.dx;
                    });
                  },
                  onPanStart: (details) {
                    setState(() {
                      _listPlacement[index].alignment = Alignment.centerLeft;
                    });
                  },
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
                  15,
                  margin: const EdgeInsets.only(top: 11),
                  onPanUpdate: (details) {
                    _listPlacement[index].offset = _listPlacement[index]
                        .offset
                        .translate(details.delta.dx, 0);
                    setState(() {
                      _listPlacement[index].width -= details.delta.dx;
                      _listPlacement[index].height += details.delta.dy;
                    });
                  },
                  onPanStart: (details) {
                    setState(() {
                      _listPlacement[index].alignment = Alignment.center;
                    });
                  },
                ),
                // dot bottom center
                _buildDotDrag(
                  index,
                  12,
                  margin: const EdgeInsets.only(top: 11),
                  onPanUpdate: (details) {
                    setState(() {
                      _listPlacement[index].height += details.delta.dy;
                    });
                  },
                  onPanStart: (details) {
                    setState(() {
                      _listPlacement[index].alignment = Alignment.topCenter;
                    });
                  },
                ),
                // dot bottom right
                _buildDotDrag(
                  index,
                  15,
                  margin: const EdgeInsets.only(top: 11),
                  onPanUpdate: (details) {
                    setState(() {
                      _listPlacement[index].width += details.delta.dx;
                      _listPlacement[index].height += details.delta.dy;
                    });
                  },
                  onPanStart: (details) {
                    setState(() {
                      _listPlacement[index].alignment = Alignment.center;
                    });
                  },
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
      EdgeInsets? margin}) {
    return GestureDetector(
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
