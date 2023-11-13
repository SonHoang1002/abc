import 'dart:developer' as d;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/check_distance.dart';
import 'package:photo_to_pdf/helpers/extract_list.dart';
import 'package:photo_to_pdf/helpers/parse_placement_to_rect.dart';
import 'package:photo_to_pdf/models/placement.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class WDragZoomImageTest2 extends StatefulWidget {
  final Color backgroundColor;
  final List<Placement> listPlacement;
  final List<GlobalKey> listGlobalKey;
  final List<ValueNotifier<Matrix4>> matrix4Notifiers;
  final Placement? selectedPlacement;
  final PaperAttribute? paperAttribute;
  final Function(List<Rectangle1> rectangle1s, Rectangle1? focusRectangle1,
      List<double> ratios) onUpdatePlacement;
  final Function(
    Rectangle1 rectangle1,
  )? onFocusRectangle;
  final void Function()? onCancelFocusRectangle1;
  final Function rerenderFunction;
  const WDragZoomImageTest2(
      {super.key,
      required this.backgroundColor,
      required this.listPlacement,
      required this.listGlobalKey,
      required this.matrix4Notifiers,
      required this.onUpdatePlacement,
      this.selectedPlacement,
      this.onFocusRectangle,
      this.paperAttribute,
      this.onCancelFocusRectangle1,
      required this.rerenderFunction});

  @override
  State<WDragZoomImageTest2> createState() => _WDragZoomImageTest2State();
}

class _WDragZoomImageTest2State extends State<WDragZoomImageTest2> {
  late Size _size;
  List<Rectangle1> _listRectangle1 = [];
  final GlobalKey _drawAreaKey = GlobalKey(debugLabel: "_drawAreaKey");

  final GlobalKey _childContainerKey =
      GlobalKey(debugLabel: "_childContainerKey");
  final GlobalKey _stackKey = GlobalKey();
  late double _maxHeight;
  late double _maxWidth;
  Rectangle1? _selectedRectangle1;
  late Offset _startOffset;
  // luu khoang cach giua diem cham (doi voi selectedRectangle1) so voi ben trai vaf ben tren cuar Rectangle1 dang duoc focus
  late List _kiem_tra_xem_dang_o_canh_nao = [];
  // global position
  late List<double> _listVerticalPosition = [];
  // global position
  late List<double> _listHorizontalPosition = [];
  // [0]: override ver // [1]: override hori
  List<List<double>> _listOverride = [[], []];

  // late List<GlobalKey> _listGlobalKey;

  // int? _indexOfFocusRect;
  late bool _isInside = false;
  final GlobalKey _gestureKey = GlobalKey(debugLabel: "_gestureKey");

  Offset? _dotTopLeft;
  late Offset _deltaPositionBoard;
  late Offset _gestureBoardOffset;

  @override
  void initState() {
    super.initState();
    // _listRectangle1 = [1, 2, 3]
    //     .map((e) => Rectangle1(height: 150, width: 150, id: e, x: 50, y: 50))
    //     .toList();
    // _listGlobalKey = _listRectangle1.map((e) => GlobalKey()).toList();

    _deltaPositionBoard = Offset.zero;
    _gestureBoardOffset = Offset.zero;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Offset offsetRectangleBoard =
          (_childContainerKey.currentContext?.findRenderObject() as RenderBox)
              .localToGlobal(Offset.zero);
      Offset offsetBodyLayout =
          (_drawAreaKey.currentContext?.findRenderObject() as RenderBox)
              .localToGlobal(Offset.zero);
      _deltaPositionBoard = offsetRectangleBoard - offsetBodyLayout;
      final renderBoxBoard =
          _gestureKey.currentContext?.findRenderObject() as RenderBox;
      _gestureBoardOffset = renderBoxBoard.localToGlobal( Offset.zero);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _listRectangle1.clear();
  }

  @override
  Widget build(BuildContext context) {
    _maxHeight = _getWidthAndHeight()[1];
    
    _maxWidth = _getWidthAndHeight()[0];
    _listRectangle1 = widget.listPlacement.map((pl) {
      return placementToRectangle(pl, [_maxWidth, _maxHeight])!;
    }).toList();
    _selectedRectangle1 =
        placementToRectangle(widget.selectedPlacement, [_maxWidth, _maxHeight]);
    if (_selectedRectangle1 != null &&
        !widget.listPlacement
            .map((e) => e.id)
            .toList()
            .contains(_selectedRectangle1!.id)) {
      _selectedRectangle1 = null;
    }
    _showDots();
    return _buildCustomArea();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _size = MediaQuery.sizeOf(context);
  }

  /// [[dotTopLeft],[dotTopCenter],[dotTopRight],[dotCenterLeft],[dotCenterRight],[dotBottomLeft],[dotBottomCenter],[dotBottomRight]]
  List<Offset> _getGlobalDotPosition(
    int index,
  ) {
    final renderBox = widget.listGlobalKey[index].currentContext
        ?.findRenderObject() as RenderBox;
    final dotTopLeft = renderBox.localToGlobal(Offset.zero);
    final dotTopCenter =
        Offset(dotTopLeft.dx + _listRectangle1[index].width / 2, dotTopLeft.dy);
    final dotTopRight =
        Offset(dotTopLeft.dx + _listRectangle1[index].width, dotTopLeft.dy);
    final dotCenterLeft = Offset(
        dotTopLeft.dx, dotTopLeft.dy + _listRectangle1[index].height / 2);
    final dotCenterRight = Offset(dotTopLeft.dx + _listRectangle1[index].width,
        dotTopLeft.dy + _listRectangle1[index].height / 2);
    final dotBottomLeft =
        Offset(dotTopLeft.dx, dotTopLeft.dy + _listRectangle1[index].height); //
    final dotBottomCenter = Offset(
        dotTopLeft.dx + _listRectangle1[index].width / 2,
        dotTopLeft.dy + _listRectangle1[index].height);
    final dotBottomRight = Offset(dotTopLeft.dx + _listRectangle1[index].width,
        dotTopLeft.dy + _listRectangle1[index].height);
    return [
      dotTopLeft,
      dotTopCenter,
      dotTopRight,
      dotCenterLeft,
      dotCenterRight,
      dotBottomLeft,
      dotBottomCenter,
      dotBottomRight,
    ];
  }

  /// [edgeTop, edgeBottom, edgeLeft, edgeRight]
  ///
  List<Offset> _getGlobalEdgePosition(int index) {
    final renderBox = widget.listGlobalKey[index].currentContext
        ?.findRenderObject() as RenderBox;
    Offset dotTopLeft = renderBox.localToGlobal(Offset.zero);
    final edgeTop = dotTopLeft;
    final edgeLeft = dotTopLeft;
    final edgeRight =
        Offset(dotTopLeft.dx + _listRectangle1[index].width, dotTopLeft.dy);
    final edgeBottom = Offset(dotTopLeft.dx + _listRectangle1[index].width,
        dotTopLeft.dy + _listRectangle1[index].height);
    return [
      edgeTop,
      edgeBottom,
      edgeLeft,
      edgeRight,
    ];
  }

  void _showDots() {
    if (_selectedRectangle1 != null) {
      final index = _getIndexSelectedRectangle(_selectedRectangle1!);
      _dotTopLeft = _listRectangle1[index].getOffset.translate(
          _deltaPositionBoard.dx - DOT_SIZE / 2,
          _deltaPositionBoard.dy - DOT_SIZE / 2);
    }
  }

  void _onFocusRectangle1(Offset startOffset) {
    int? index = _checkInsideRectangle(startOffset);
    if (index != null) {
      _selectedRectangle1 = _listRectangle1[index];
      _showDots();
      setState(() {});
      widget.rerenderFunction();
      _updatePlacement();
    } else {
      _selectedRectangle1 = null;
      _dotTopLeft = null;
      widget.onCancelFocusRectangle1!=null ?  widget.onCancelFocusRectangle1!():null;
    }
  }

  int? _checkInsideRectangle(Offset startOffset) {
    int? index;
    final newStartOffset = startOffset;
    for (int i = 0; i < _listRectangle1.length; i++) {
      List<Offset> offsetDots = _getGlobalDotPosition(i);
      List<Offset> offsetEdges = _getGlobalEdgePosition(i);
      if (containOffset(newStartOffset, offsetDots[0], offsetDots[7])) {
        index = i;
        _kiem_tra_xem_dang_o_canh_nao = [];
        if ((offsetEdges[0].dy - newStartOffset.dy).abs() < 30) {
          _kiem_tra_xem_dang_o_canh_nao.add("top");
        }
        if ((offsetEdges[1].dy - newStartOffset.dy).abs() < 30) {
          _kiem_tra_xem_dang_o_canh_nao.add("bottom");
        }
        if ((offsetEdges[2].dx - newStartOffset.dx).abs() < 30) {
          _kiem_tra_xem_dang_o_canh_nao.add("left");
        }
        if ((offsetEdges[3].dx - newStartOffset.dx).abs() < 30) {
          _kiem_tra_xem_dang_o_canh_nao.add("right");
        }
      }
    }
    return index;
  }

  bool _checkInsideCurrentRectangle(Offset startOffset, {bool? checkEdge}) {
    bool isInside = false;
    if (_selectedRectangle1 != null) {
      int index = _getIndexSelectedRectangle(_selectedRectangle1!);
      List<Offset> offsetDots = _getGlobalDotPosition(index);
      if (containOffset(startOffset, offsetDots[0] + const Offset(-50, -50),
          offsetDots[7] + const Offset(50, 50))) {
        isInside = true;
        if (checkEdge == true) {
          _kiem_tra_xem_dang_o_canh_nao = [];
          List<Offset> offsetEdges = _getGlobalEdgePosition(index);
          List _kiem_tra_xem_dang_o_canh_nao_1 = [];
          if ((offsetEdges[0].dy - startOffset.dy).abs() < 50) {
            _kiem_tra_xem_dang_o_canh_nao_1.add("top");
          }
          if ((offsetEdges[1].dy - startOffset.dy).abs() < 50) {
            _kiem_tra_xem_dang_o_canh_nao_1.add("bottom");
          }
          if ((offsetEdges[2].dx - startOffset.dx).abs() < 50) {
            _kiem_tra_xem_dang_o_canh_nao_1.add("left");
          }
          if ((offsetEdges[3].dx - startOffset.dx).abs() < 50) {
            _kiem_tra_xem_dang_o_canh_nao_1.add("right");
          }
          _kiem_tra_xem_dang_o_canh_nao = _kiem_tra_xem_dang_o_canh_nao_1;
        }
      }
    }
    return isInside;
  }

  void _updatePlacement() {
    widget.onUpdatePlacement(
        _listRectangle1, _selectedRectangle1, [_maxWidth, _maxHeight]);
  }

  int _getIndexSelectedRectangle(Rectangle1 rect1) {
    return _listRectangle1.map((e) => e.id).toList().indexOf(rect1.id);
  }

  Widget _buildCustomArea() {
    return GestureDetector(
      key: _gestureKey,
      onTapUp: (details) {
        _onFocusRectangle1(details.globalPosition);
      },
      onTapDown: (details) {
        int? index = _checkInsideRectangle(details.globalPosition);
      },
      onPanUpdate: (details) {
        if (_isInside && _selectedRectangle1 != null) {
          int index = _getIndexSelectedRectangle(_selectedRectangle1!);
          Rectangle1 newRectangle1;
          double x1 = _selectedRectangle1!.x + _selectedRectangle1!.width;
          double y1 = _selectedRectangle1!.y + _selectedRectangle1!.height;
          double y = _selectedRectangle1!.y;
          double x = _selectedRectangle1!.x;
          // translation
          Offset deltaGlobalPosition = details.globalPosition - _startOffset;
          List<List<double>> newListOverride = [[], []];

          // this stack is parent of rectangles
          final renderBoxStack =
              _stackKey.currentContext?.findRenderObject() as RenderBox;

          if (_kiem_tra_xem_dang_o_canh_nao.isNotEmpty) {
            if (_kiem_tra_xem_dang_o_canh_nao.contains("top")) {
              y += deltaGlobalPosition.dy;
              // parse local to global to use compare to global vertical positions
              double globalY = renderBoxStack.localToGlobal(Offset(0, y)).dy;
              int? index = _snap(globalY, _listVerticalPosition);
              if (index != null) {
                final newRedPosition = _listVerticalPosition[index] -
                    _gestureBoardOffset.dy -
                    DOT_SIZE / 2;
                print("_gestureBoardOffset ${_gestureBoardOffset}");
                newListOverride[1].add(newRedPosition);
                y = renderBoxStack
                    .globalToLocal(Offset(0, _listVerticalPosition[index]))
                    .dy;
              }
            }
            if (_kiem_tra_xem_dang_o_canh_nao.contains("left")) {
              x += deltaGlobalPosition.dx;
              double globalX = renderBoxStack.localToGlobal(Offset(x, 0)).dx;
              int? index = _snap(globalX, _listHorizontalPosition);
              if (index != null) {
                newListOverride[0].add(_listHorizontalPosition[index] -
                    _gestureBoardOffset.dx -
                    DOT_SIZE / 2);
                x = renderBoxStack
                    .globalToLocal(Offset(_listHorizontalPosition[index], 0))
                    .dx;
              }
            }
            if (_kiem_tra_xem_dang_o_canh_nao.contains("right")) {
              x1 += deltaGlobalPosition.dx;
              double globalX = renderBoxStack.localToGlobal(Offset(x1, 0)).dx;
              int? index = _snap(
                globalX,
                _listHorizontalPosition,
              );
              if (index != null) {
                newListOverride[0].add(_listHorizontalPosition[index] -
                    _gestureBoardOffset.dx -
                    DOT_SIZE / 2);
                x1 = renderBoxStack
                    .globalToLocal(Offset(_listHorizontalPosition[index], 0))
                    .dx;
              }
            }
            if (_kiem_tra_xem_dang_o_canh_nao.contains("bottom")) {
              y1 += deltaGlobalPosition.dy;
              double globalY = renderBoxStack.localToGlobal(Offset(0, y1)).dy;
              int? index = _snap(
                globalY,
                _listVerticalPosition,
              );
              if (index != null) {
                newListOverride[1].add(_listVerticalPosition[index] -
                    _gestureBoardOffset.dy -
                    DOT_SIZE / 2);
                y1 = renderBoxStack
                    .globalToLocal(Offset(0, _listVerticalPosition[index]))
                    .dy;
              }
            }
            x = min(_maxWidth, max(0, x));
            x1 = min(_maxWidth, max(0, x1));
            y = min(_maxHeight, max(0, y));
            y1 = min(_maxHeight, max(0, y1));
          } else {
            var dx = deltaGlobalPosition.dx;
            dx = max(-x, min(dx, _maxWidth - x1));
            var dy = deltaGlobalPosition.dy;
            dy = max(-y, min(dy, _maxHeight - y1));
            x += dx;
            y += dy;
            x1 += dx;
            y1 += dy;

            // snap
            double globalX = renderBoxStack.localToGlobal(Offset(x, 0)).dx;
            double globalY = renderBoxStack.localToGlobal(Offset(0, y)).dy;
            double globalX1 = renderBoxStack.localToGlobal(Offset(x1, 0)).dx;
            double globalY1 = renderBoxStack.localToGlobal(Offset(0, y1)).dy;
            //snap hor
            int? indexX = _snap(globalX, _listHorizontalPosition);
            if (indexX != null) {
              newListOverride[0].add(_listHorizontalPosition[indexX] -
                  _gestureBoardOffset.dx -
                  DOT_SIZE / 2);
              x = renderBoxStack
                  .globalToLocal(Offset(_listHorizontalPosition[indexX], 0))
                  .dx;
              x1 += _listHorizontalPosition[indexX] - globalX;
            }
            int? indexX1 = _snap(globalX1, _listHorizontalPosition);
            if (indexX1 != null) {
              newListOverride[0].add(_listHorizontalPosition[indexX1] -
                  _gestureBoardOffset.dx -
                  DOT_SIZE / 2);
              x1 = renderBoxStack
                  .globalToLocal(Offset(_listHorizontalPosition[indexX1], 0))
                  .dx;
              x += _listHorizontalPosition[indexX1] - globalX1;
            }
            //snap ver
            int? indexY = _snap(globalY, _listVerticalPosition);
            if (indexY != null) {
              newListOverride[1].add(_listVerticalPosition[indexY] -
                  _gestureBoardOffset.dy -
                  DOT_SIZE / 2);
              y = renderBoxStack
                  .globalToLocal(Offset(0, _listVerticalPosition[indexY]))
                  .dy;
              y1 += _listVerticalPosition[indexY] - globalY;
            }
            int? indexY1 = _snap(globalY1, _listVerticalPosition);
            if (indexY1 != null) {
              newListOverride[1].add(_listVerticalPosition[indexY1] -
                  _gestureBoardOffset.dy -
                  DOT_SIZE / 2);
              y1 = renderBoxStack
                  .globalToLocal(Offset(0, _listVerticalPosition[indexY1]))
                  .dy;
              y += _listVerticalPosition[indexY1] - globalY1;
            }
          }
          _listOverride = newListOverride;
          newRectangle1 = Rectangle1(
              id: _selectedRectangle1!.id,
              x: x,
              y: y,
              width: x1 - x,
              height: y1 - y);
          //gan
          _listRectangle1[index] = newRectangle1;
          _showDots();
          setState(() {});
          widget.rerenderFunction();
          _updatePlacement();
        }
      },
      onPanStart: (details) {
        if (_selectedRectangle1 != null) {
          int index = _getIndexSelectedRectangle(_selectedRectangle1!);
          _selectedRectangle1 = _listRectangle1[index];
          _isInside = _checkInsideCurrentRectangle(details.globalPosition,
              checkEdge: true);
          _listVerticalPosition.clear();
          _listHorizontalPosition.clear();
          if (_listRectangle1.isNotEmpty) {
            List<GlobalKey> listGlobalKeyWithoutCurrent =
                List<GlobalKey>.from(widget.listGlobalKey);

            List<Offset> listDeleteEdges = _getGlobalDotPosition(index);
            _listVerticalPosition =
                convertNestedListToList(listGlobalKeyWithoutCurrent.map((e) {
              int index = listGlobalKeyWithoutCurrent.indexOf(e);
              List<Offset> listEdges = _getGlobalDotPosition(index);
              return [listEdges[1].dy, listEdges[6].dy];
            }).toList());
            _listVerticalPosition.remove(listDeleteEdges[1].dy);
            _listVerticalPosition.remove(listDeleteEdges[6].dy);

            _listHorizontalPosition =
                convertNestedListToList(listGlobalKeyWithoutCurrent.map((e) {
              int index = listGlobalKeyWithoutCurrent.indexOf(e);
              List<Offset> listEdges = _getGlobalDotPosition(index);
              return [listEdges[0].dx, listEdges[2].dx];
            }).toList());
            _listHorizontalPosition.remove(listDeleteEdges[0].dx);
            _listHorizontalPosition.remove(listDeleteEdges[2].dx);
          }
        }
        _startOffset = details.globalPosition;
        setState(() {});
        widget.rerenderFunction();
        _updatePlacement();
      },
      child: Stack(
        key: _drawAreaKey,
        alignment: Alignment.center,
        children: [
          // view mau (shadow + thut vao trong) bao gom cac rect
          Align(
            alignment: Alignment.center,
            child: Container(
              key: _childContainerKey,
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
              child: Stack(
                key: _stackKey,
                children: [
                  ..._listRectangle1
                      .where((element) => element.id != _selectedRectangle1?.id)
                      .toList()
                      .map<Widget>(
                    (e) {
                      return _buildRectangle(e);
                    },
                  ).toList(),
                  if (_selectedRectangle1 != null)
                    _buildRectangle(_selectedRectangle1!),
                ],
              ),
            ),
          ),
          // view trang tri( duong do, duong xanh, hinh tron)
          Container(
            color: transparent,
            child: Stack(alignment: Alignment.center, children: [
              ..._listOverride[0]
                  .map<Widget>((e) => Positioned(
                      left: e,
                      child: Container(
                        height: _maxHeight,
                        margin: const EdgeInsets.only(left: DOT_SIZE / 2),
                        width: 1,
                        color: colorRed,
                      )))
                  .toList(),
              ..._listOverride[1]
                  .map<Widget>((e) => Positioned(
                      top: e,
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.only(top: DOT_SIZE / 2),
                        width: _maxWidth,
                        color: colorRed,
                      )))
                  .toList(),
              _buildBlueLine(),
              _buildDots()
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildBlueLine() {
    if (_dotTopLeft != null && _selectedRectangle1 != null) {
      int index = _getIndexSelectedRectangle(_selectedRectangle1!);
      final currentRect = _listRectangle1[index];
      final currentWidth = max(0, currentRect.width);
      final currentHeight = max(0, currentRect.height);
      return Stack(
        children: [
          //top edge
          currentHeight != 0
              ? _buildBlueLineItem(
                  currentRect,
                  _dotTopLeft!.dy,
                  _dotTopLeft!.dx,
                )
              : const SizedBox(),
          //left edge
          currentWidth != 0
              ? _buildBlueLineItem(
                  currentRect,
                  _dotTopLeft!.dy,
                  _dotTopLeft!.dx,
                  isVertical: false,
                )
              : const SizedBox(),
          // right edge
          currentWidth != 0
              ? _buildBlueLineItem(
                  currentRect,
                  _dotTopLeft!.dy,
                  _dotTopLeft!.dx + currentWidth,
                  isVertical: false,
                )
              : const SizedBox(),
          // bottom edge
          currentHeight != 0
              ? _buildBlueLineItem(
                  currentRect,
                  _dotTopLeft!.dy + currentHeight,
                  _dotTopLeft!.dx,
                )
              : const SizedBox()
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildBlueLineItem(Rectangle1 currentRect, double top, double left,
      {bool isVertical = true}) {
    return Positioned(
        top: top,
        left: left,
        child: Container(
          margin: EdgeInsets.only(
              top: isVertical ? DOT_SIZE / 2 : 0,
              left: isVertical ? 0 : DOT_SIZE / 2),
          height: isVertical ? 1 : currentRect.height,
          width: isVertical ? currentRect.width : 1,
          color: colorBlue,
        ));
  }

  Widget _buildDots() {
    if (_dotTopLeft != null && _selectedRectangle1 != null) {
      // top (left-center-right), center (left, right), bottom (left-center-right)
      int index = _getIndexSelectedRectangle(_selectedRectangle1!);
      final currentRect = _listRectangle1[index];
      double cRectWidth = max(0, currentRect.width);
      double cRectHeight = max(0, currentRect.height);
      List<Offset> listDots = [
        _dotTopLeft!,
        _dotTopLeft! + Offset(cRectWidth / 2, 0),
        _dotTopLeft! + Offset(cRectWidth, 0),
        // center
        _dotTopLeft! + Offset(0, cRectHeight / 2),
        _dotTopLeft! + Offset(cRectWidth, cRectHeight / 2),
        // bottom
        _dotTopLeft! + Offset(0, cRectHeight),
        _dotTopLeft! + Offset(cRectWidth / 2, cRectHeight),
        _dotTopLeft! + Offset(cRectWidth, cRectHeight),
      ];
      return Stack(
        children: listDots.map((e) => _buildDotDrag(DOT_SIZE, e)).toList(),
      );
    }
    return const SizedBox();
  }

  double _getHeightOfImage(int index) {
    final result = _listRectangle1[index].height;
    return result;
  }

  double _getWidthOfImage(int index) {
    final result = _listRectangle1[index].width;
    return result;
  }

  List<double> _getWidthAndHeight() {
    final MAXHEIGHT = _size.height * 404 / 791 * 0.9;
    final MAXWIDTH = _size.width * 0.9;

    double width = MAXWIDTH;
    double height = MAXHEIGHT;

    if (widget.paperAttribute != null) {
      final heightToWidth =
          widget.paperAttribute!.height / widget.paperAttribute!.width;
      if (widget.paperAttribute!.height > widget.paperAttribute!.width) {
        height = _size.width * heightToWidth;
        if (height > MAXHEIGHT) {
          height = MAXHEIGHT;
          width = height * (1 / heightToWidth);
        }
      } else if (widget.paperAttribute!.height < widget.paperAttribute!.width) {
        width = height * (1 / heightToWidth);
        if (width > MAXWIDTH) {
          width = MAXWIDTH;
          height = width * heightToWidth;
        }
      }
    } else {
      // width = _size.width * _ratioTarget[1];
      // height = _size.width * _ratioTarget[0];
      width = _size.width * 0.769;
      height = _size.height * 0.469;
    }
    return [width, height];
  }

  int? _snap(double x, List<double> list) {
    // List<double> results = [];
    for (int i = 0; i < list.length; i++) {
      if ((x - list[i]).abs() < 5) {
        return i;
      }
    }
    return null;
  }

  Widget _buildRectangle(Rectangle1? rectangle1) {
    int _index = 0;
    if (rectangle1 != null) {
      _index = _listRectangle1
          .map(
            (e) => e.id,
          )
          .toList()
          .indexOf(rectangle1.id);
    }
    if (_index == -1) {
      return const SizedBox();
    }
    return Stack(
      children: [
        Positioned(
          key: widget.listGlobalKey[_index],
          top: _listRectangle1[_index].y,
          left: _listRectangle1[_index].x,
          child: Stack(children: [
            Image.asset(
              "${pathPrefixImage}image_demo.png",
              fit: BoxFit.cover,
              height: _getHeightOfImage(_index),
              width: _getWidthOfImage(_index),
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
                  value: "${_index + 1}",
                  textColor: colorWhite,
                  textSize: 10,
                )),
              ),
            )),
          ]),
        ),
      ],
    );
  }

  Widget _buildDotDrag(double size, Offset offset, {EdgeInsets? margin}) {
    return Positioned(
      top: offset.dy,
      left: offset.dx,
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
