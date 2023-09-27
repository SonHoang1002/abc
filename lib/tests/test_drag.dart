import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/models/placement.dart';

class TestDrag extends StatefulWidget {
  const TestDrag({
    super.key,
  });

  @override
  State<TestDrag> createState() => _TestDragState();
}

class _TestDragState extends State<TestDrag> {
  late Size _size;
  final List<ValueNotifier<Matrix4>> _matrix4Notifiers = [];
  final List<Placement> _listPlacement = [];

  Size containerSize = Size.zero;
  final GlobalKey _placementFrame = GlobalKey();
  @override
  void initState() {
    super.initState();

    _matrix4Notifiers.add(ValueNotifier(Matrix4.identity()));
    _matrix4Notifiers.add(ValueNotifier(Matrix4.identity()));
    _listPlacement.add(Placement(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        offset: const Offset(0, 0)));
    _listPlacement.add(Placement(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        offset: const Offset(0, 0)));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _size = MediaQuery.sizeOf(context);

    containerSize = _placementFrame.currentContext != null
        ? (_placementFrame.currentContext?.findRenderObject() as RenderBox).size
        : Size(_size.width * 0.8, _size.width * 0.8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(top: 10),
            child: _buildCustomArea(() {}),
          ),
        ));
  }

  Widget _buildCustomArea(Function rerenderFunction) {
    return Container(
      height: _size.height * 404 / 791 * 0.9,
      width: _size.width,
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(children: [
        Expanded(
            key: _placementFrame,
            child: Container(
                width: _size.width * 0.8,
                height: _size.width * 0.8,
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 0.5,
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ]),
                child: Stack(
                  children: _matrix4Notifiers.map<Widget>(
                    (e) {
                      final index = _matrix4Notifiers.indexOf(e);
                      return GestureDetector(
                        onPanUpdate: (details) {
                          _listPlacement[index].offset = _listPlacement[index]
                              .offset
                              .translate(details.delta.dx, details.delta.dy);

                          if (_listPlacement[index].offset.dx <= 0) {
                            _listPlacement[index].offset =
                                Offset(0, _listPlacement[index].offset.dy);
                          }
                          if (_listPlacement[index].offset.dy <= 0) {
                            _listPlacement[index].offset =
                                Offset(_listPlacement[index].offset.dx, 0);
                          }
                          if (_listPlacement[index].offset.dx +
                                  _listPlacement[index].width >=
                              containerSize.width - 20) {
                            _listPlacement[index].offset = Offset(
                                containerSize.width -
                                    _listPlacement[index].width,
                                _listPlacement[index].offset.dy);
                          }
                          if (_listPlacement[index].offset.dy +
                                  _listPlacement[index].height >=
                              containerSize.height) {
                            _listPlacement[index].offset = Offset(
                                _listPlacement[index].offset.dx,
                                containerSize.height -
                                    _listPlacement[index].height);
                          }
                          setState(() {});
                        },
                        child: AnimatedBuilder(
                          animation: _matrix4Notifiers[index],
                          builder: (context, child) {
                            return Stack(
                              children: [
                                Positioned(
                                  top: _listPlacement[index].offset.dy,
                                  left: _listPlacement[index].offset.dx,
                                  child: Stack(fit: StackFit.loose, children: [
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
                                        child: _buildPanGestureWidget(index))
                                  ]),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ).toList(),
                ))),
        const SizedBox(height: 10),
      ]),
    );
  }

  var lastBottom = 0.0;

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
