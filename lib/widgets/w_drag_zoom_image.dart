
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/change_list.dart';
import 'package:photo_to_pdf/helpers/check_distance.dart';
import 'package:photo_to_pdf/helpers/convert.dart';
import 'package:photo_to_pdf/helpers/extract_list.dart'; 
import 'package:photo_to_pdf/helpers/snap.dart';
import 'package:photo_to_pdf/models/placement.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/w_blue_line.dart';
import 'package:photo_to_pdf/widgets/w_dot_item.dart';
import 'package:photo_to_pdf/widgets/w_rectangle_item.dart';

class WDragZoomImage extends StatefulWidget {
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
  const WDragZoomImage(
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
  State<WDragZoomImage> createState() => _WDragZoomImageState();
}

class _WDragZoomImageState extends State<WDragZoomImage> {
  late Size _size;
  List<Rectangle1> _listRectangle1 = [];
  final GlobalKey _drawAreaKey = GlobalKey(debugLabel: "_drawAreaKey");
  final GlobalKey _gestureKey = GlobalKey(debugLabel: "_gestureKey");
  final GlobalKey _testKey = GlobalKey(debugLabel: "_gestureKey");

  final GlobalKey _childContainerKey =
      GlobalKey(debugLabel: "_childContainerKey");
  final GlobalKey _stackKey = GlobalKey();
  late double _maxHeight;
  late double _maxWidth;
  Rectangle1? _selectedRectangle1;
  late Offset _startOffset;
  late List _kiem_tra_xem_dang_o_canh_nao = [];
  // global position
  late List<double> _listVerticalPosition = [], _listHorizontalPosition = [];
  // [0]: override ver // [1]: override hori
  List<List<double>> _listOverride = [[], []];
  late bool _isInside = false;
  Offset? _dotTopLeft;
  late Offset _deltaPositionBoard;
  late Offset _gestureBoardOffset;

  @override
  void initState() {
    super.initState();
    _deltaPositionBoard = Offset.zero;
    _gestureBoardOffset = Offset.zero;
    // _listRectangle1 = [
    //   1,
    //   2,
    // ].map((e) {
    //   return Rectangle1(height: 150, width: 150, id: e, x: 50, y: 50);
    // }).toList();
    // _listGlobalKey = _listRectangle1.map((e) => GlobalKey()).toList();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Offset offsetRectangleBoard =
          (_childContainerKey.currentContext?.findRenderObject() as RenderBox)
              .localToGlobal(Offset.zero);
      Offset offsetBodyLayout =
          (_drawAreaKey.currentContext?.findRenderObject() as RenderBox)
              .localToGlobal(Offset.zero);
      _deltaPositionBoard = offsetRectangleBoard - offsetBodyLayout;
      _gestureBoardOffset =
          (_gestureKey.currentContext?.findRenderObject() as RenderBox)
              .localToGlobal(Offset.zero);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _listRectangle1.clear();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.sizeOf(context);
    _maxHeight = _getWidthAndHeight()[1];
    _maxWidth = _getWidthAndHeight()[0];
    _listRectangle1 = widget.listPlacement.map((pl) {
      return placementToRectangle(pl, [_maxWidth, _maxHeight])!;
    }).toList();
    _selectedRectangle1 =
        placementToRectangle(widget.selectedPlacement, [_maxWidth, _maxHeight]);
    if (_selectedRectangle1 != null) {
      final index = _getIndexSelectedRectangle(_selectedRectangle1!);
      _dotTopLeft = _listRectangle1[index].getOffset.translate(
          _deltaPositionBoard.dx - DOT_SIZE / 2,
          _deltaPositionBoard.dy - DOT_SIZE / 2);
    }
    return _buildCustomArea();
  }

  /// [[dotTopLeft],[dotTopCenter],[dotTopRight],[dotCenterLeft],[dotCenterRight],[dotBottomLeft],[dotBottomCenter],[dotBottomRight]]
  List<Offset> _getGlobalDotPosition(int index,
      {List<Rectangle1>? additionalListRect,
      List<GlobalKey>? additionalListGlobalkey}) {
    List<Rectangle1> listCheckRectangle = additionalListRect ?? _listRectangle1;
    List<GlobalKey> listCheckGlobalkey =
        additionalListGlobalkey ?? widget.listGlobalKey;

    final renderBox = listCheckGlobalkey[index]
        .currentContext
        ?.findRenderObject() as RenderBox;
    final dotTopLeft = renderBox.localToGlobal(Offset.zero);
    final dotTopCenter = Offset(
        dotTopLeft.dx + listCheckRectangle[index].width / 2, dotTopLeft.dy);
    final dotTopRight =
        Offset(dotTopLeft.dx + listCheckRectangle[index].width, dotTopLeft.dy);
    final dotCenterLeft = Offset(
        dotTopLeft.dx, dotTopLeft.dy + listCheckRectangle[index].height / 2);
    final dotCenterRight = Offset(
        dotTopLeft.dx + listCheckRectangle[index].width,
        dotTopLeft.dy + listCheckRectangle[index].height / 2);
    final dotBottomLeft =
        Offset(dotTopLeft.dx, dotTopLeft.dy + listCheckRectangle[index].height);
    final dotBottomCenter = Offset(
        dotTopLeft.dx + listCheckRectangle[index].width / 2,
        dotTopLeft.dy + listCheckRectangle[index].height);
    final dotBottomRight = Offset(
        dotTopLeft.dx + listCheckRectangle[index].width,
        dotTopLeft.dy + listCheckRectangle[index].height);
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
  List<Offset> _getGlobalEdgePosition(int index,
      {List<Rectangle1>? additionalList,
      List<GlobalKey>? additionalListGlobalkey}) {
    List<Rectangle1> listCheckRectangle = additionalList ?? _listRectangle1;
    List<GlobalKey> listCheckGlobalkey =
        additionalListGlobalkey ?? widget.listGlobalKey;

    final renderBox = listCheckGlobalkey[index]
        .currentContext
        ?.findRenderObject() as RenderBox;
    Offset dotTopLeft = renderBox.localToGlobal(Offset.zero);
    final edgeTop = dotTopLeft;
    final edgeLeft = dotTopLeft;
    final edgeRight =
        Offset(dotTopLeft.dx + listCheckRectangle[index].width, dotTopLeft.dy);
    final edgeBottom = Offset(dotTopLeft.dx + listCheckRectangle[index].width,
        dotTopLeft.dy + listCheckRectangle[index].height);
    return [
      edgeTop,
      edgeBottom,
      edgeLeft,
      edgeRight,
    ];
  }

  void _onFocusRectangle(Offset startOffset) {
    int? index = _checkInsideRectangle(startOffset);
    if (index != null) {
      _selectedRectangle1 = _listRectangle1[index];
      setState(() {});
      widget.rerenderFunction();
      _updatePlacement();
    } else {
      _selectedRectangle1 = null;
      _dotTopLeft = null;
      widget.onCancelFocusRectangle1 != null
          ? widget.onCancelFocusRectangle1!()
          : null;
    }
  }

  int? _checkInsideRectangle(Offset startOffset) {
    List<Rectangle1> listCheckRectangle =
        List<Rectangle1>.from(_listRectangle1);
    List<GlobalKey> listCheckGlobalkey =
        List<GlobalKey>.from(widget.listGlobalKey);
    if (_selectedRectangle1 != null) { 
      int indexOfSelectedRect =
          _getIndexSelectedRectangle(_selectedRectangle1!);
      if (indexOfSelectedRect != -1) {
        final currentGlobalkey = widget.listGlobalKey[indexOfSelectedRect];
        listCheckRectangle.removeAt(indexOfSelectedRect);
        listCheckRectangle.add(_selectedRectangle1!);

        listCheckGlobalkey.removeAt(indexOfSelectedRect);
        listCheckGlobalkey.add(currentGlobalkey);
      }
    }
     
    int? index;
    Rectangle1? currentRect;
    final newStartOffset = startOffset;
    for (int i = 0; i < listCheckRectangle.length; i++) {
      List<Offset> offsetDots = _getGlobalDotPosition(i,
          additionalListRect: listCheckRectangle,
          additionalListGlobalkey: listCheckGlobalkey);
      List<Offset> offsetEdges = _getGlobalEdgePosition(i,
          additionalList: listCheckRectangle,
          additionalListGlobalkey: listCheckGlobalkey);
      if (containOffset(newStartOffset, offsetDots[0], offsetDots[7])) {
        // index = i;
        currentRect = listCheckRectangle[i];
        _kiem_tra_xem_dang_o_canh_nao = [];
        if ((offsetEdges[0].dy - newStartOffset.dy).abs() < 20) {
          _kiem_tra_xem_dang_o_canh_nao.add("top");
        }
        if ((offsetEdges[1].dy - newStartOffset.dy).abs() < 20) {
          _kiem_tra_xem_dang_o_canh_nao.add("bottom");
        }
        if ((offsetEdges[2].dx - newStartOffset.dx).abs() < 20) {
          _kiem_tra_xem_dang_o_canh_nao.add("left");
        }
        if ((offsetEdges[3].dx - newStartOffset.dx).abs() < 20) {
          _kiem_tra_xem_dang_o_canh_nao.add("right");
        }
      }
    }
    index =
        currentRect != null ? _getIndexSelectedRectangle(currentRect) : null;
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
          if (_kiem_tra_xem_dang_o_canh_nao_1.length <= 2) {
            _kiem_tra_xem_dang_o_canh_nao = _kiem_tra_xem_dang_o_canh_nao_1;
          }
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

  void _onPanUpdate(DragUpdateDetails details) {
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
      final gestureBox =
          (_gestureKey.currentContext?.findRenderObject() as RenderBox);
      if (_kiem_tra_xem_dang_o_canh_nao.isNotEmpty) {
        if (_kiem_tra_xem_dang_o_canh_nao.contains("top")) {
          y += deltaGlobalPosition.dy;
          y = min(y1 - 50, max(0, y));
          double globalY = renderBoxStack.localToGlobal(Offset(0, y)).dy;
          int? index = snapPosition(globalY, _listVerticalPosition);
          if (index != null) {
            Offset gPosition = gestureBox
                .globalToLocal(Offset(0, _listVerticalPosition[index]));
            newListOverride[1].add(gPosition.dy - DOT_SIZE / 2);
            y = renderBoxStack
                .globalToLocal(Offset(0, _listVerticalPosition[index]))
                .dy;
          }
        }
        if (_kiem_tra_xem_dang_o_canh_nao.contains("left")) {
          x += deltaGlobalPosition.dx;
          x = min(x1 - 50, max(0, x));
          double globalX = renderBoxStack.localToGlobal(Offset(x, 0)).dx;
          int? index = snapPosition(globalX, _listHorizontalPosition);
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
          x1 = min(_maxWidth, max(x + 50, x1));
          double globalX = renderBoxStack.localToGlobal(Offset(x1, 0)).dx;
          int? index = snapPosition(
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
          y1 = min(_maxHeight, max(y + 50, y1));
          double globalY = renderBoxStack.localToGlobal(Offset(0, y1)).dy;
          int? index = snapPosition(
            globalY,
            _listVerticalPosition,
          );
          if (index != null) {
            Offset gPosition = gestureBox
                .globalToLocal(Offset(0, _listVerticalPosition[index]));
            newListOverride[1].add(gPosition.dy - DOT_SIZE / 2);
            y1 = renderBoxStack
                .globalToLocal(Offset(0, _listVerticalPosition[index]))
                .dy;
          }
        }
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
        int? indexX = snapPosition(globalX, _listHorizontalPosition);
        if (indexX != null) {
          newListOverride[0].add(_listHorizontalPosition[indexX] -
              _gestureBoardOffset.dx -
              DOT_SIZE / 2);
          x = renderBoxStack
              .globalToLocal(Offset(_listHorizontalPosition[indexX], 0))
              .dx;
          x1 += _listHorizontalPosition[indexX] - globalX;
        }
        int? indexX1 = snapPosition(globalX1, _listHorizontalPosition);
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
        int? indexY = snapPosition(globalY, _listVerticalPosition);
        if (indexY != null) {
          newListOverride[1].add(_listVerticalPosition[indexY] -
              _gestureBoardOffset.dy -
              DOT_SIZE / 2);
          y = renderBoxStack
              .globalToLocal(Offset(0, _listVerticalPosition[indexY]))
              .dy;
          y1 += _listVerticalPosition[indexY] - globalY;
        }
        int? indexY1 = snapPosition(globalY1, _listVerticalPosition);
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
      setState(() {});
      widget.rerenderFunction();
      _updatePlacement();
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (_selectedRectangle1 != null) {
      int index = _getIndexSelectedRectangle(_selectedRectangle1!);
      _selectedRectangle1 = _listRectangle1[index];
      _isInside =
          _checkInsideCurrentRectangle(details.globalPosition, checkEdge: true);
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
  }

  Widget _buildCustomArea() {
    return GestureDetector(
      key: _gestureKey,
      onTapUp: (details) {
        _onFocusRectangle(details.globalPosition);
      },
      onPanUpdate: _onPanUpdate,
      onPanStart: _onPanStart,
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
                      return buildRectangle(
                          e, _listRectangle1, widget.listGlobalKey);
                    },
                  ).toList(),
                  if (_selectedRectangle1 != null)
                    buildRectangle(_selectedRectangle1!, _listRectangle1,
                        widget.listGlobalKey),
                ],
              ),
            ),
          ),
          // view trang tri( duong do, duong xanh, hinh tron)
          Container(
            width: _size.width,
            height: _size.height,
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
      return Stack(
        children: [
          //top edge
          buildBlueLineItem(
            currentRect.width,
            _dotTopLeft!.dy,
            _dotTopLeft!.dx,
          ),
          //left edge
          buildBlueLineItem(
            currentRect.height,
            _dotTopLeft!.dy,
            _dotTopLeft!.dx,
            isVertical: false,
          ),
          // right edge
          buildBlueLineItem(
            currentRect.height,
            _dotTopLeft!.dy,
            _dotTopLeft!.dx + currentRect.width,
            isVertical: false,
          ),
          // bottom edge
          buildBlueLineItem(
            currentRect.width,
            _dotTopLeft!.dy + currentRect.height,
            _dotTopLeft!.dx,
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildDots() {
    if (_dotTopLeft != null && _selectedRectangle1 != null) {
      int index = _getIndexSelectedRectangle(_selectedRectangle1!);
      final currentRect = _listRectangle1[index];
      List<Offset> listDots = [
        _dotTopLeft!,
        _dotTopLeft! + Offset(currentRect.width / 2, 0),
        _dotTopLeft! + Offset(currentRect.width, 0),
        // center
        _dotTopLeft! + Offset(0, currentRect.height / 2),
        _dotTopLeft! + Offset(currentRect.width, currentRect.height / 2),
        // bottom
        _dotTopLeft! + Offset(0, currentRect.height),
        _dotTopLeft! + Offset(currentRect.width / 2, currentRect.height),
        _dotTopLeft! + Offset(currentRect.width, currentRect.height),
      ];
      return Stack(
        children: listDots.map((e) {
          final index = listDots.indexOf(e);
          if ([1, 6].contains(index)) {
            return buildDotItem(DOT_SIZE * 0.8, e,
                margin: const EdgeInsets.only(top: DOT_SIZE * 0.2));
          }
          if ([3, 4].contains(index)) {
            return buildDotItem(DOT_SIZE * 0.8, e,
                margin: const EdgeInsets.only(left: DOT_SIZE * 0.2));
          }
          return buildDotItem(DOT_SIZE, e);
        }).toList(),
      );
    }
    return const SizedBox();
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
      width = _size.width * 0.769;
      height = _size.height * 0.469;
    }
    return [width, height];
  }
}


