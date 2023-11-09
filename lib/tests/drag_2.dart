import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/check_distance.dart';
import 'package:photo_to_pdf/helpers/convert.dart';
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
  // List<ValueNotifier<Matrix4>> _matrix4Notifiers = [];
  List<Rectangle1> _listRectangle1 = [];
  final GlobalKey _drawAreaKey = GlobalKey();
  // late List<double> _ratioTarget;
  late double _maxHeight;
  late double _maxWidth;
  Rectangle1? _selectedRectangle1;
  late Offset _startOffset;
  // luu khoang cach giua diem cham (doi voi selectedRectangle1) so voi ben trai vaf ben tren cuar Rectangle1 dang duoc focus
  late List<double> _listPositionOfPointer;
  late List _kiem_tra_xem_dang_o_canh_nao = [];
  late List<double> _listVerticalPosition = [];
  late List<double> _listHorizontalPosition = [];
  // [0]: override width // [1]: override height
  final List<List<double>> _listOverride = [[], []];

  late List<GlobalKey> _listGlobalKey;
  int? _indexOfFocusRect;
  @override
  void initState() {
    super.initState();
    _selectedRectangle1 = widget.selectedRectangle1;
    _listRectangle1 = [1, 2, 3, 4, 5]
        .map((e) => Rectangle1(
            height: 200,
            width: 200,
            id: e,
            x: Random().nextDouble() * 256,
            y: Random().nextDouble() * 256))
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
  List<Offset> _getLocalDotPosition(
    int index,
  ) {
    final renderBox =
        _listGlobalKey[index].currentContext?.findRenderObject() as RenderBox;

    final dotTopLeft = renderBox.localToGlobal(Offset.zero);
    // dotTopLeft =
    //   Offset(dotTopLeft.dx * RmaxWidthToWidth, dotTopLeft.dy * RmaxHeightToHeight);
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

  void _onFocusRectangle1(Offset startOffset) {
    int? index = _checkInsideRectangle(startOffset);
    if (index != null) {
      _selectedRectangle1 = _listRectangle1[index];
      _indexOfFocusRect = index;
      setState(() {});
      widget.rerenderFunction();
    } else {
      _selectedRectangle1 = null;
      setState(() {});
      widget.rerenderFunction();
    }
  }

  int? _checkInsideRectangle(Offset startOffset) {
    int? index;
    final newStartOffset = startOffset;
    for (int i = 0; i < _listRectangle1.length; i++) {
      List<Offset> offsetDots = _getLocalDotPosition(i);
      List<Offset> offsetEdges = _getLocalEdgePosition(i);
      if (containOffset(newStartOffset, offsetDots[0], offsetDots[7])) {
        index = i;
        _kiem_tra_xem_dang_o_canh_nao = [];
        if ((offsetEdges[0].dy - newStartOffset.dy).abs() < 20) {
          _kiem_tra_xem_dang_o_canh_nao.add("top");
        }
        if ((offsetEdges[1].dy - newStartOffset.dy).abs() < 20) {
          _kiem_tra_xem_dang_o_canh_nao.add("bottom");
        }
        if ((offsetEdges[2].dx - newStartOffset.dx) < 20) {
          _kiem_tra_xem_dang_o_canh_nao.add("left");
        }
        if ((offsetEdges[3].dx - newStartOffset.dx).abs() < 20) {
          _kiem_tra_xem_dang_o_canh_nao.add("right");
        }
      }
    }
    return index;
  }

  bool _checkInsideCurrentRectangle(Offset startOffset, {bool? checkEdge}) {
    bool isInside = false;
    if (_indexOfFocusRect != null) {
      List<Offset> offsetDots = _getLocalDotPosition(_indexOfFocusRect!);
      if (containOffset(startOffset, offsetDots[0], offsetDots[7])) {
        isInside = true;
        if (checkEdge == true) {
          _kiem_tra_xem_dang_o_canh_nao = [];
          List<Offset> offsetEdges = _getLocalEdgePosition(_indexOfFocusRect!);
          List _kiem_tra_xem_dang_o_canh_nao_1 = [];
          if ((offsetEdges[0].dy - startOffset.dy).abs() < 20) {
            _kiem_tra_xem_dang_o_canh_nao_1.add("top");
          }
          if ((offsetEdges[1].dy - startOffset.dy).abs() < 20) {
            _kiem_tra_xem_dang_o_canh_nao_1.add("bottom");
          }
          if ((offsetEdges[2].dx - startOffset.dx) < 20) {
            _kiem_tra_xem_dang_o_canh_nao_1.add("left");
          }
          if ((offsetEdges[3].dx - startOffset.dx).abs() < 20) {
            _kiem_tra_xem_dang_o_canh_nao_1.add("right");
          }
        }
      }
    }
    return isInside;
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

  Widget _buildCustomArea() {
    return GestureDetector(
      onTapUp: (details) {
        _onFocusRectangle1(details.globalPosition);
      },
      onPanUpdate: (details) {
        bool _isInside = _checkInsideCurrentRectangle(details.globalPosition);
        if (_isInside && _indexOfFocusRect != null) {
          if (_selectedRectangle1 != null) {
            Rectangle1 newRectangle1;
            // translation
            double x = _selectedRectangle1!.x;
            double y = _selectedRectangle1!.y;
            double x1, y1;
            Offset deltaGlobalPosition = details.globalPosition - _startOffset;
            newRectangle1 = Rectangle1(
                id: _selectedRectangle1!.id,
                x: x + deltaGlobalPosition.dx,
                y: y + deltaGlobalPosition.dy,
                width: _selectedRectangle1!.width,
                height: _selectedRectangle1!.height);
            // check limit
            //left
            newRectangle1.x = max(0, newRectangle1.x);
            //top
            newRectangle1.y = max(0, newRectangle1.y);
            //right
            if (newRectangle1.x + newRectangle1.width > _maxWidth) {
              newRectangle1.x = _maxWidth - newRectangle1.width;
            }
            //bottom
            if (newRectangle1.y + newRectangle1.height > _maxHeight) {
              newRectangle1.y = _maxHeight - newRectangle1.height;
            }
            print(
                "_kiem_tra_xem_dang_o_canh_nao ${_kiem_tra_xem_dang_o_canh_nao}");
            _listRectangle1[_indexOfFocusRect!] = newRectangle1;
            setState(() {});
            widget.rerenderFunction();
          }
        }
      },
      onPanStart: (details) {
        if (_indexOfFocusRect != null) {
          _selectedRectangle1 = _listRectangle1[_indexOfFocusRect!];
        }
        // check drag from edge ??

        _startOffset = details.globalPosition;
        setState(() {});
        widget.rerenderFunction();
      },
      child: Stack(
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
                Stack(
                  children: _listRectangle1
                      .where((element) => element.id != _selectedRectangle1?.id)
                      .toList()
                      .map<Widget>(
                    (e) {
                      return _buildRectangle1(e);
                    },
                  ).toList(),
                ),
                if (_selectedRectangle1 != null)
                  _buildRectangle1(_selectedRectangle1!),
                if (widget.selectedRectangle1 != null)
                  ..._listOverride[0]
                      .map<Widget>((e) => Positioned(
                          left: e * _maxWidth,
                          top: 7,
                          child: Container(
                            height: _maxHeight,
                            margin: const EdgeInsets.only(left: 7),
                            width: 1,
                            color: colorRed,
                          )))
                      .toList(),
                if (widget.selectedRectangle1 != null)
                  ..._listOverride[1]
                      .map<Widget>((e) => Positioned(
                          top: e * _maxHeight,
                          left: 8,
                          child: Container(
                            height: 1,
                            margin: const EdgeInsets.only(top: 7),
                            width: _maxWidth,
                            color: colorRed,
                          )))
                      .toList(),
              ],
            ),
          )
        ],
      ),
    );
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
                  value: "X",
                  // "${(widget.listRectangle1Preventive!.indexWhere((element) => element.id == _listRectangle1[index].id)) + 1}",
                  textColor: colorWhite,
                  textSize: 10,
                )),
              ),
            )),
            _selectedRectangle1?.id == _listRectangle1[_index].id
                ? Positioned.fill(child: _buildPanGestureWidget(_index))
                : const SizedBox()
          ]),
        ),
      ],
    );
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
                  margin: const EdgeInsets.only(bottom: 7, top: 1, left: 1),
                ),
                // dot top center
                _buildDotDrag(
                  index,
                  9,
                  margin: const EdgeInsets.only(bottom: 6),
                ),
                // dot top right
                _buildDotDrag(
                  index,
                  13,
                  margin: const EdgeInsets.only(bottom: 6),
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
                ),
                // dot center right
                _buildDotDrag(
                  index,
                  9,
                  margin: const EdgeInsets.only(right: 2),
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
                ),
                // dot bottom center
                _buildDotDrag(
                  index,
                  9,
                  margin: const EdgeInsets.only(top: 12, bottom: 0.5),
                ),
                // dot bottom right
                _buildDotDrag(
                  index,
                  13,
                  margin: const EdgeInsets.only(top: 11),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDotDrag(int index, double size, {EdgeInsets? margin}) {
    return Container(
      height: size,
      width: size,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: Colors.blue, width: 2),
      ),
    );
  }
}
