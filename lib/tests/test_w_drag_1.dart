import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/check_distance.dart';
import 'package:photo_to_pdf/helpers/convert.dart';
import 'package:photo_to_pdf/helpers/extract_list.dart';
import 'package:photo_to_pdf/models/placement.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class WDragZoomImageTest1 extends StatefulWidget {
  final Color backgroundColor;
  final List<Placement> listPlacement;
  final List<GlobalKey> listGlobalKey;
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
  const WDragZoomImageTest1(
      {super.key,
      required this.backgroundColor,
      required this.listPlacement,
      required this.listGlobalKey,
      required this.matrix4Notifiers,
      required this.onUpdatePlacement,
      this.selectedPlacement,
      this.onFocusPlacement,
      this.ratioTarget = LIST_RATIO_PLACEMENT_BOARD,
      this.paperAttribute,
      this.onCancelFocusPlacement,
      this.listPlacementPreventive});

  @override
  State<WDragZoomImageTest1> createState() => _WDragZoomImageTest1State();
}

class _WDragZoomImageTest1State extends State<WDragZoomImageTest1> {
  late Size _size;
  List<ValueNotifier<Matrix4>> _matrix4Notifiers = [];
  List<Placement> _listPlacement = [];
  final GlobalKey _drawAreaKey = GlobalKey();
  late List<double> _ratioTarget;
  late double _maxHeight;
  late double _maxWidth;
  Placement? _selectedPlacement;

  // test element

  late Offset _startOffset;
  // luu khoang cach giua diem cham (doi voi selectedPlacement) so voi ben trai vaf ben tren cuar placement dang duoc focus
  late List<double> _listPositionOfPointer;
  late List _kiem_tra_xem_dang_o_canh_nao = [];
  late List<double> _listVerticalPosition = [];
  late List<double> _listHorizontalPosition = [];
  // [0]: override width // [1]: override height
  List<List<double>> _listOverride = [[], []];

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
  void dispose() {
    super.dispose();
    _matrix4Notifiers.clear();
    _listPlacement.clear();
  }

  @override
  Widget build(BuildContext context) {
    _matrix4Notifiers = widget.matrix4Notifiers;
    _listPlacement = widget.listPlacement;
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
    final renderBox = widget.listGlobalKey[index].currentContext
        ?.findRenderObject() as RenderBox;
    final RmaxWidthToWidth = _maxWidth / _size.width;
    final RmaxHeightToHeight = _maxHeight / _size.height;

    final dotTopLeft = renderBox.localToGlobal(Offset.zero);
    // dotTopLeft =
    //   Offset(dotTopLeft.dx * RmaxWidthToWidth, dotTopLeft.dy * RmaxHeightToHeight);
    final dotTopCenter = Offset(
        dotTopLeft.dx + _maxWidth * _listPlacement[index].ratioWidth / 2,
        dotTopLeft.dy);
    final dotTopRight = Offset(
        dotTopLeft.dx + _maxWidth * _listPlacement[index].ratioWidth,
        dotTopLeft.dy);
    final dotCenterLeft = Offset(dotTopLeft.dx,
        dotTopLeft.dy + _maxHeight * _listPlacement[index].ratioHeight / 2);
    final dotCenterRight = Offset(
        dotTopLeft.dx + _maxWidth * _listPlacement[index].ratioWidth,
        dotTopLeft.dy + _maxHeight * _listPlacement[index].ratioHeight / 2);
    final dotBottomLeft = Offset(dotTopLeft.dx,
        dotTopLeft.dy + _maxHeight * _listPlacement[index].ratioHeight); //
    final dotBottomCenter = Offset(
        dotTopLeft.dx + _maxWidth * _listPlacement[index].ratioWidth / 2,
        dotTopLeft.dy + _maxHeight * _listPlacement[index].ratioHeight);
    final dotBottomRight = Offset(
        dotTopLeft.dx + _maxWidth * _listPlacement[index].ratioWidth,
        dotTopLeft.dy + _maxHeight * _listPlacement[index].ratioHeight);
    return [
      convertOffset(dotTopLeft, [RmaxWidthToWidth, RmaxHeightToHeight]),
      convertOffset(dotTopCenter, [RmaxWidthToWidth, RmaxHeightToHeight]),
      convertOffset(dotTopRight, [RmaxWidthToWidth, RmaxHeightToHeight]),
      convertOffset(dotCenterLeft, [RmaxWidthToWidth, RmaxHeightToHeight]),
      convertOffset(dotCenterRight, [RmaxWidthToWidth, RmaxHeightToHeight]),
      convertOffset(dotBottomLeft, [RmaxWidthToWidth, RmaxHeightToHeight]),
      convertOffset(dotBottomCenter, [RmaxWidthToWidth, RmaxHeightToHeight]),
      convertOffset(dotBottomRight, [RmaxWidthToWidth, RmaxHeightToHeight]),
    ];
  }

  List<Offset> _getLocalEdgePosition(int index) {
    final RmaxWidthToWidth = _maxWidth / _size.width;
    final RmaxHeightToHeight = _maxHeight / _size.height;
    final renderBox = widget.listGlobalKey[index].currentContext
        ?.findRenderObject() as RenderBox;
    Offset dotTopLeft = renderBox.localToGlobal(Offset.zero);
    // dotTopLeft = Offset(
    //     dotTopLeft.dx * RmaxWidthToWidth, dotTopLeft.dy * RmaxHeightToHeight);
    final edgeTop = dotTopLeft;
    final edgeLeft = dotTopLeft;
    final edgeRight = Offset(
        dotTopLeft.dx + _listPlacement[index].ratioWidth * _maxWidth,
        dotTopLeft.dy);
    final edgeBottom = Offset(
        dotTopLeft.dx + _listPlacement[index].ratioWidth * _maxWidth,
        dotTopLeft.dy + _listPlacement[index].ratioHeight * _maxHeight);
    return [
      convertOffset(edgeTop, [RmaxWidthToWidth, RmaxHeightToHeight]),
      convertOffset(edgeBottom, [RmaxWidthToWidth, RmaxHeightToHeight]),
      convertOffset(edgeLeft, [RmaxWidthToWidth, RmaxHeightToHeight]),
      convertOffset(edgeRight, [RmaxWidthToWidth, RmaxHeightToHeight]),
    ];
  }

  List<dynamic>? _onFocusPlacement(Offset startOffset) {
    final RmaxWidthToWidth = _maxWidth / _size.width;
    final RmaxHeightToHeight = _maxHeight / _size.height;
    int? index;
    final newStartOffset =
        convertOffset(startOffset, [RmaxWidthToWidth, RmaxHeightToHeight]);
    for (int i = 0; i < widget.listGlobalKey.length; i++) {
      List<Offset> offsetDots = _getLocalDotPosition(i);
      List<Offset> offsetEdges = _getLocalEdgePosition(i);
      if (containOffset(
          newStartOffset,
          offsetDots[0] +
              Offset(-10 * RmaxWidthToWidth, -10 * RmaxHeightToHeight),
          offsetDots[7] +
              Offset(10 * RmaxWidthToWidth, 15 * RmaxHeightToHeight))) {
        index = i;
        _listPositionOfPointer = [
          (newStartOffset.dx - offsetEdges[0].dx),
          (newStartOffset.dy - offsetEdges[0].dy),
          (offsetEdges[3].dx - newStartOffset.dx),
          (offsetEdges[1].dy - newStartOffset.dy),
        ];
        _kiem_tra_xem_dang_o_canh_nao = [];
        if (offsetEdges[0].dy - 20 < newStartOffset.dy &&
            newStartOffset.dy < offsetEdges[0].dy + 20) {
          _kiem_tra_xem_dang_o_canh_nao.add("top");
        }
        if (offsetEdges[1].dy - 20 < newStartOffset.dy &&
            newStartOffset.dy < offsetEdges[1].dy + 20) {
          _kiem_tra_xem_dang_o_canh_nao.add("bottom");
        }
        if (offsetEdges[2].dx - 20 < newStartOffset.dx &&
            newStartOffset.dx < offsetEdges[2].dx + 30) {
          _kiem_tra_xem_dang_o_canh_nao.add("left");
        }
        if (offsetEdges[3].dx - 20 < newStartOffset.dx &&
            newStartOffset.dx < offsetEdges[3].dx + 20) {
          _kiem_tra_xem_dang_o_canh_nao.add("right");
        }
      }
    }
    String message = '';
    if (index != null) {
      _selectedPlacement = _listPlacement[index].copyWith();
      widget.onFocusPlacement!(_listPlacement[index], _matrix4Notifiers[index]);
      setState(() {});
    } else {
      widget.onCancelFocusPlacement!();
      setState(() {});
    }
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

  Widget _buildCustomArea() {
    return GestureDetector(
      onPanStart: (details) {
        _startOffset = details.globalPosition;
        _onFocusPlacement(details.globalPosition);
        if (_selectedPlacement != null) {
          int indexOfFocusPlacement = _listPlacement
              .map((e) => e.id)
              .toList()
              .indexOf(_selectedPlacement!.id);
          if (_listPlacement.isNotEmpty) {
            List<Placement> listPlacementWithoutCurrent =
                List.from(_listPlacement);
            listPlacementWithoutCurrent.removeAt(indexOfFocusPlacement);
            List<GlobalKey> listGlobalKeyWithoutCurrent =
                List.from(widget.listGlobalKey);
            listGlobalKeyWithoutCurrent.removeAt(indexOfFocusPlacement);
            _listVerticalPosition =
                convertNestedListToList(listGlobalKeyWithoutCurrent.map((e) {
              int index = listGlobalKeyWithoutCurrent.indexOf(e);
              List<Offset> listOffset = _getLocalDotPosition(index);
              return [listOffset[1].dy, listOffset[6].dy];
            }).toList());
            _listHorizontalPosition =
                convertNestedListToList(listGlobalKeyWithoutCurrent.map((e) {
              int index = listGlobalKeyWithoutCurrent.indexOf(e);
              List<Offset> listOffset = _getLocalDotPosition(index);
              return [listOffset[0].dx, listOffset[2].dx];
            }).toList());
          }
          widget.onFocusPlacement!(_listPlacement[indexOfFocusPlacement],
              _matrix4Notifiers[indexOfFocusPlacement]);
          setState(() {});
        }
      },
      onPanUpdate: (details) {
        if (_selectedPlacement != null) {
          final RmaxWidthToWidth = _maxWidth / _size.width;
          final RmaxHeightToHeight = _maxHeight / _size.height;

          final indexOfFocusPlacement = _listPlacement
              .map((e) => e.id)
              .toList()
              .indexOf(_selectedPlacement!.id);
          Placement selectedPlacement = _listPlacement[indexOfFocusPlacement];

          final newDetailsLocalPosition = Offset(
              details.globalPosition.dx * RmaxWidthToWidth,
              details.globalPosition.dy * RmaxHeightToHeight);

          // translation
          Offset deltaGlobalPosition = details.globalPosition - _startOffset;
          // new placement
          Placement newPlacement = _listPlacement[indexOfFocusPlacement];
          // thay doi kich thuoc va vi tri cua placement
          if (_kiem_tra_xem_dang_o_canh_nao.isNotEmpty) {
            for (var ele in _kiem_tra_xem_dang_o_canh_nao) {
              switch (ele) {
                case "top":
                  final newRatioOffset1 = _selectedPlacement!.ratioOffset[1] +
                      deltaGlobalPosition.dy / _maxHeight;
                  if (newRatioOffset1 > 0) {
                    newPlacement = selectedPlacement.copyWith(
                        ratioHeight: _selectedPlacement!.ratioHeight -
                            deltaGlobalPosition.dy / _maxHeight,
                        ratioWidth: newPlacement.ratioWidth,
                        ratioOffset: [
                          newPlacement.ratioOffset[0],
                          newRatioOffset1
                        ]);
                  }
                case "bottom":
                  final newRatioHeight = _selectedPlacement!.ratioHeight +
                      deltaGlobalPosition.dy / _maxHeight;
                  if (newRatioHeight + newPlacement.ratioOffset[1] < 1) {
                    newPlacement.ratioHeight = newRatioHeight;
                  }
                case "left":
                  final newRatioOffset0 = _selectedPlacement!.ratioOffset[0] +
                      deltaGlobalPosition.dx / _maxWidth;
                  if (newRatioOffset0 > 0) {
                    newPlacement = selectedPlacement.copyWith(
                        ratioWidth: _selectedPlacement!.ratioWidth -
                            deltaGlobalPosition.dx / _maxWidth,
                        ratioHeight: newPlacement.ratioHeight,
                        ratioOffset: [
                          newRatioOffset0,
                          newPlacement.ratioOffset[1]
                        ]);
                  }
                case "right":
                  final newRatioHeight = _selectedPlacement!.ratioWidth +
                      deltaGlobalPosition.dx / _maxWidth;
                  if (newRatioHeight + newPlacement.ratioOffset[0] < 1) {
                    newPlacement.ratioWidth = _selectedPlacement!.ratioWidth +
                        deltaGlobalPosition.dx / _maxWidth;
                  }
                default:
                  break;
              }
            }
          } else {
            newPlacement = selectedPlacement.copyWith(ratioOffset: [
              _selectedPlacement!.ratioOffset[0] +
                  deltaGlobalPosition.dx / _maxWidth,
              _selectedPlacement!.ratioOffset[1] +
                  deltaGlobalPosition.dy / _maxHeight
            ]);
          }
          // check snap //
          // canh ngang
          // height, width , x , y
          double newRatioHeight,
              newRatioWidth,
              newRatioOffset0,
              newRatioOffset1;
          for (int i = 0; i < _listVerticalPosition.length; i++) {
            // top
            if (checkInsideDistance(_listVerticalPosition[i],
                newDetailsLocalPosition.dy - _listPositionOfPointer[1], 5)) {
              print("top inside");
              print(
                  "newPlacement.ratioOffset[1] ${newPlacement.ratioOffset[1] * _maxHeight}");
              print("_listVerticalPosition[i] ${_listVerticalPosition[i]}");
              // newPlacement.ratioOffset[1] =
              //     _listVerticalPosition[i] / _maxHeight * RmaxHeightToHeight;
            }
            if (checkInsideDistance(_listVerticalPosition[i],
                newDetailsLocalPosition.dy + _listPositionOfPointer[3], 5)) {
              print("bottom inside");
            }
          }

          //left
          if (newPlacement.ratioOffset[0] <= 0) {
            newPlacement.ratioOffset = [0, newPlacement.ratioOffset[1]];
          }
          //top
          if (newPlacement.ratioOffset[1] <= 0) {
            newPlacement.ratioOffset = [newPlacement.ratioOffset[0], 0];
          }
          //right
          if (newPlacement.ratioOffset[0] + newPlacement.ratioWidth >= 1) {
            newPlacement.ratioOffset = [
              1 - newPlacement.ratioWidth,
              newPlacement.ratioOffset[1]
            ];
          }
          //bottom
          if (newPlacement.ratioOffset[1] + newPlacement.ratioHeight >= 1) {
            newPlacement.ratioOffset = [
              newPlacement.ratioOffset[0],
              1 - newPlacement.ratioHeight
            ];
          }
          // gan gia tri
          _listPlacement[indexOfFocusPlacement] = newPlacement;
          // re-render ui
          widget.onFocusPlacement!(
              newPlacement, _matrix4Notifiers[indexOfFocusPlacement]);
          setState(() {});
        }
      },
      onPanEnd: (details) {
        setState(() {
          _selectedPlacement = null;
          _kiem_tra_xem_dang_o_canh_nao.clear();
          _listVerticalPosition.clear();
          _listHorizontalPosition.clear();
        });
      },
      onTapDown: (details) {
        _startOffset = details.globalPosition;
        _onFocusPlacement(details.globalPosition);
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
                  children: _listPlacement.map<Widget>(
                    (e) {
                      final index = _listPlacement.indexOf(e);
                      return Stack(
                        children: [
                          Positioned(
                            key: widget.listGlobalKey[index],
                            top: _listPlacement[index].ratioOffset[1] *
                                _maxHeight,
                            left: _listPlacement[index].ratioOffset[0] *
                                _maxWidth,
                            child: Stack(children: [
                              Container(
                                padding: const EdgeInsets.all(7),
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
                  ).toList(),
                ),
              ],
            ),
          )
        ],
      ),
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

  Widget _buildDotDrag(int index, double size,
      {void Function(DragUpdateDetails details)? onPanUpdate,
      void Function(DragStartDetails)? onPanStart,
      void Function(DragEndDetails)? onPanEnd,
      void Function()? onTap,
      EdgeInsets? margin,
      Key? key}) {
    return GestureDetector(
      key: key,
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
