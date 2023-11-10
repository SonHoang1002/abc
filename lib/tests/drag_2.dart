import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/change_list.dart';
import 'package:photo_to_pdf/helpers/check_distance.dart';
import 'package:photo_to_pdf/helpers/extract_list.dart';
import 'package:photo_to_pdf/models/placement.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class WDragZoomImageTest2 extends StatefulWidget {
  final Color backgroundColor;
  final List<Rectangle1> listRectangle1;
  final List<GlobalKey> listGlobalKey;
  final List<ValueNotifier<Matrix4>> matrix4Notifiers;
  final Rectangle1? selectedRectangle1;
  final PaperAttribute? paperAttribute;
  final Function(
    List<Rectangle1> Rectangle1s,
    Rectangle1? focusRectangle1,
  ) onUpdateRectangle1;
  final Function(
    Rectangle1 Rectangle1,
  )? onFocusRectangle1;
  final void Function()? onCancelFocusRectangle1;
  // dung de luu giu trang thai danh sach Rectangle1 ban dau ( dung cho viec hien thi title index cho Rectangle1)
  final List<Rectangle1>? listRectangle1Preventive;
  final Function rerenderFunction;
  const WDragZoomImageTest2(
      {super.key,
      required this.backgroundColor,
      required this.listRectangle1,
      required this.listGlobalKey,
      required this.matrix4Notifiers,
      required this.onUpdateRectangle1,
      this.selectedRectangle1,
      this.onFocusRectangle1,
      this.paperAttribute,
      this.onCancelFocusRectangle1,
      this.listRectangle1Preventive,
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
  late double _maxHeight;
  late double _maxWidth;
  Rectangle1? _selectedRectangle1;
  late Offset _startOffset;
  // luu khoang cach giua diem cham (doi voi selectedRectangle1) so voi ben trai vaf ben tren cuar Rectangle1 dang duoc focus
  late List _kiem_tra_xem_dang_o_canh_nao = [];
  late List<double> _listVerticalPosition = [];
  late List<double> _listHorizontalPosition = [];
  // [0]: override ver // [1]: override hori
  List<List<double>> _listOverride = [[], []];

  late List<GlobalKey> _listGlobalKey;
  int? _indexOfFocusRect;
  late bool _isInside = false;
  final GlobalKey _testKey = GlobalKey();

  Offset? _dotTopLeft;
  @override
  void initState() {
    super.initState();
    _selectedRectangle1 = widget.selectedRectangle1;
    _listRectangle1 = [1, 2]
        .map((e) => Rectangle1(height: 150, width: 150, id: e, x: 50, y: 50))
        .toList();
    _listGlobalKey = _listRectangle1.map((e) => GlobalKey()).toList();
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
    final renderBox =
        _listGlobalKey[index].currentContext?.findRenderObject() as RenderBox;
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

  ///
  /// [edgeTop,edgeBottom,edgeLeft,edgeRight]
  ///
  List<Offset> _getGlobalEdgePosition(int index) {
    final renderBox =
        _listGlobalKey[index].currentContext?.findRenderObject() as RenderBox;
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

  ///
  /// [edgeTop,edgeBottom,edgeLeft,edgeRight]
  ///
  List<Offset> _getLocalEdgePosition(int index) {
    final renderBox =
        _listGlobalKey[index].currentContext?.findRenderObject() as RenderBox;
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

  _showDotAndBlueLine(int index) {
    // tim vi tri cua rect so voi view trang tri
    // tra ra 2 diem
    final drawRenderBox =
        _drawAreaKey.currentContext?.findRenderObject() as RenderBox;
    Size drawSize = drawRenderBox.size;
    Offset gChildOffset =
        (_childContainerKey.currentContext?.findRenderObject() as RenderBox)
            .localToGlobal(Offset.zero);
    Offset gParentOffset = drawRenderBox.localToGlobal(Offset.zero);
    _doDichChuyen = gChildOffset - gParentOffset;
    print("selected: ${_selectedRectangle1.toString()}");
    print("gChildOffset: ${gChildOffset}");
    print("gParentOffset: ${gParentOffset}");
    Offset dotTopLeft = Offset(
      _selectedRectangle1!.x,
      _selectedRectangle1!.y,
    );
    _dotTopLeft = dotTopLeft.translate(_doDichChuyen.dx, _doDichChuyen.dy);
  }

  void _onFocusRectangle1(Offset startOffset) {
    int? index = _checkInsideRectangle(startOffset);
    if (index != null) {
      _indexOfFocusRect = index;
      _selectedRectangle1 = _listRectangle1[index];
      _showDotAndBlueLine(index);
      setState(() {});
      widget.rerenderFunction();
    } else {
      _selectedRectangle1 = null;
      _indexOfFocusRect = null;
      _dotTopLeft = null;
      setState(() {});
      widget.rerenderFunction();
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
    if (_indexOfFocusRect != null) {
      List<Offset> offsetDots = _getGlobalDotPosition(_indexOfFocusRect!);
      if (containOffset(startOffset, offsetDots[0] + const Offset(-50, -50),
          offsetDots[7] + const Offset(50, 50))) {
        isInside = true;
        if (checkEdge == true) {
          _kiem_tra_xem_dang_o_canh_nao = [];
          List<Offset> offsetEdges = _getGlobalEdgePosition(_indexOfFocusRect!);
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

  Widget _buildCustomArea() {
    return GestureDetector(
      onTapUp: (details) {
        _onFocusRectangle1(details.globalPosition);
      },
      key: _testKey,
      child: Stack(
        key: _drawAreaKey,
        alignment: Alignment.center,
        children: [
          // view trang (shadow + thut vao trong) bao gom cac rect
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 5),
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
              child: Stack(children: [
                ..._listRectangle1
                    .where((element) => element.id != _selectedRectangle1?.id)
                    .toList()
                    .map<Widget>(
                  (e) {
                    return _buildRectangle1(e);
                  },
                ).toList(),
                if (_selectedRectangle1 != null)
                  _buildRectangle1(_selectedRectangle1!),
              ]),
            ),
          ),
          // view trang tri( duong do, duong xanh, hinh tron)
          Container(
            color: transparent,
            child: Stack(children: [
              ..._listOverride[0]
                  .map<Widget>((e) => Positioned(
                      left: e,
                      child: Container(
                        height: _maxHeight,
                        margin: const EdgeInsets.only(left: 7),
                        width: 1,
                        color: colorRed,
                      )))
                  .toList(),
              ..._listOverride[1]
                  .map<Widget>((e) => Positioned(
                      top: e,
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.only(top: 7),
                        width: _maxWidth,
                        color: colorRed,
                      )))
                  .toList(),
              _buildDots()
            ]),
          ),
        ],
      ),
    );
  }

  _buildDots() {
    if (_selectedRectangle1 != null && _dotTopLeft != null) {
      // top (left-center-right), center (left, right), bottom (left-center-right)
      List<Offset> listDots = [
        _dotTopLeft!,
        _dotTopLeft! + Offset(_selectedRectangle1!.width / 2, 0),
        _dotTopLeft! + Offset(_selectedRectangle1!.width, 0),
        // center
        _dotTopLeft! + Offset(0, _selectedRectangle1!.height / 2),
        _dotTopLeft! +
            Offset(
              _selectedRectangle1!.width,
              _selectedRectangle1!.height / 2,
            ),
        _dotTopLeft! + Offset(0, _selectedRectangle1!.height),
        _dotTopLeft! +
            Offset(_selectedRectangle1!.width / 2, _selectedRectangle1!.height),
        _dotTopLeft! +
            Offset(_selectedRectangle1!.width, _selectedRectangle1!.height),
      ];
      Widget result = Stack(
        children: listDots.map((e) => _buildDotDrag(13, e)).toList(),
      );
      return result;
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

  Widget _buildRectangle1(Rectangle1? rectangle1) {
    int _index = 0;
    if (rectangle1 != null) {
      _index = _listRectangle1
          .map(
            (e) => e.id,
          )
          .toList()
          .indexOf(rectangle1.id);
    }
    return Stack(
      children: [
        Positioned(
          key: _listGlobalKey[_index],
          top: _listRectangle1[_index].y,
          left: _listRectangle1[_index].x,
          child: Stack(children: [
            Container(
              padding: const EdgeInsets.all(7),
              child: Image.asset(
                "${pathPrefixImage}image_demo.png",
                fit: BoxFit.cover,
                height: _getHeightOfImage(_index),
                width: _getWidthOfImage(_index),
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
                  value: "${_index}",
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

  Offset _doDichChuyen = Offset.zero;
  Offset dichChuyen(Offset from) {
    return from.translate(_doDichChuyen.dx, _doDichChuyen.dy);
  }
}
