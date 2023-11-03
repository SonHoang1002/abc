import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/change_list.dart';
import 'package:photo_to_pdf/helpers/check_distance.dart';
import 'package:photo_to_pdf/helpers/convert.dart';
import 'package:photo_to_pdf/helpers/extract_list.dart';
import 'package:photo_to_pdf/models/placement.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/tests/extensions.dart';
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
  static const double minSizePlacement = 30;
  late List<double> _ratioTarget;
  late double _maxHeight;
  late double _maxWidth;
  Placement? _selectedPlacement;

  // test element

  final GlobalKey _testKey = GlobalKey();
  late Offset _startOffset;
  // luu khoang cach giua diem cham (doi voi selectedPlacement) so voi ben trai vaf ben tren cuar placement dang duoc focus
  late List<double> _listPositionOfPointer;

  @override
  void dispose() {
    super.dispose();
    _matrix4Notifiers.clear();
    _listPlacement.clear();
  }

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

  List<Offset> _getGlobalPositionPlacement(int index) {
    final renderBox = widget.listGlobalKey[index].currentContext
        ?.findRenderObject() as RenderBox;

    final dotTopLeft = renderBox.localToGlobal(Offset.zero);
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
        dotTopLeft.dy + _maxHeight * _listPlacement[index].ratioHeight + 10);
    final dotBottomCenter = Offset(
        dotTopLeft.dx + _maxWidth * _listPlacement[index].ratioWidth / 2,
        dotTopLeft.dy + _maxHeight * _listPlacement[index].ratioHeight + 10);
    final dotBottomRight = Offset(
        dotTopLeft.dx + _maxWidth * _listPlacement[index].ratioWidth,
        dotTopLeft.dy + _maxHeight * _listPlacement[index].ratioHeight + 10);
    return [
      dotTopLeft,
      dotTopCenter,
      dotTopRight,
      dotCenterLeft,
      dotCenterRight,
      dotBottomLeft,
      dotBottomCenter,
      dotBottomRight
    ];
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

  // tra ra list bao gom cac offset doi dien nhau
  List<double> _getAxisPositionOfPlacement(Offset offset, Placement placement,
      {required bool getTopAndBottom}) {
    // getTopAndBottom - > lay do cao tu goc toa do xuong canh top va canh bottom
    List<double> results = [];

    if (getTopAndBottom) {
      results.add(offset.dy);
      results.add(offset.dy + ratioToPixel(placement.ratioHeight, _maxHeight));
    } else {
      results.add(offset.dx);
      results.add(offset.dx + ratioToPixel(placement.ratioWidth, _maxWidth));
    }
    return results;
  }

  void _snapPositionWidthPoint(
      Placement currentPlacement, int index, DragUpdateDetails details) {}

  @override
  Widget build(BuildContext context) {
    _matrix4Notifiers = widget.matrix4Notifiers;
    _listPlacement = widget.listPlacement;
    _maxHeight = _getWidthAndHeight()[1];
    _maxWidth = _getWidthAndHeight()[0];
    return _buildCustomArea();
  }

  List? _onFocusPlacement(Offset startOffset) {
    final RmaxWidthToWidth = _maxWidth / _size.width;
    final RmaxHeightToHeight = _maxHeight / _size.height;
    int? index;
    final newOffset = Offset(
        startOffset.dx * RmaxWidthToWidth, startOffset.dy * RmaxHeightToHeight);

    for (int i = 0; i < widget.listGlobalKey.length; i++) {
      List<Offset> offsetPlacement = _getGlobalPositionPlacement(i);
      if (_containOffset(startOffset, offsetPlacement[0], offsetPlacement[7])) {
        _listPositionOfPointer = [
          (startOffset.dx - offsetPlacement[0].dx) * RmaxWidthToWidth,
          (startOffset.dy - offsetPlacement[0].dy) * RmaxHeightToHeight,
        ];
        index = i;
      }
    }
    String message = '';
    if (index != null) {
      _selectedPlacement = _listPlacement[index].copyWith();
      final allOffset = _getGlobalPositionPlacement(index);
      print("startOffset ${startOffset}");
      print("allOffset[0] ${allOffset[0]}");
      if (allOffset[0].dy - 7 < startOffset.dy * RmaxHeightToHeight &&
          startOffset.dy * RmaxHeightToHeight < allOffset[0].dy) {
        print("top edge");
      }
      widget.onFocusPlacement!(_listPlacement[index], _matrix4Notifiers[index]);
      setState(() {});
    } else {
      widget.onCancelFocusPlacement!();
      setState(() {});
    }
  }

  bool _containOffset(
      Offset checkOffset, Offset startOffset, Offset endOffset) {
    return (startOffset.dx <= checkOffset.dx &&
            checkOffset.dx <= endOffset.dx) &&
        (startOffset.dy <= checkOffset.dy && checkOffset.dy <= endOffset.dy);
  }

  _translatePlacement(Placement selectedPlacement, DragUpdateDetails details) {
    int indexOfFocusPlacement =
        _listPlacement.map((e) => e.id).toList().indexOf(selectedPlacement.id);
    if (indexOfFocusPlacement != -1) {
      final deltaGlobalPosition = details.globalPosition - _startOffset;

      final RmaxWidthToWidth = _maxWidth / _size.width;
      final RmaxHeightToHeight = _maxHeight / _size.height;

      List<Placement> listPlacementWithoutCurrent = List.from(_listPlacement);
      listPlacementWithoutCurrent.removeAt(indexOfFocusPlacement);
      List<GlobalKey> listGlobalKeyWithoutCurrent =
          List.from(widget.listGlobalKey);
      listGlobalKeyWithoutCurrent.removeAt(indexOfFocusPlacement);

      List<double> listVerticalPosition =
          convertNestedListToList(listGlobalKeyWithoutCurrent.map((e) {
        int index = listGlobalKeyWithoutCurrent.indexOf(e);
        List<Offset> listOffset = _getGlobalPositionPlacement(index);
        return changeValueOfList([listOffset[0].dy, listOffset[7].dy],
            [RmaxHeightToHeight, RmaxHeightToHeight], 2);
      }).toList());
      List<double> listHorizontalPosition =
          convertNestedListToList(listGlobalKeyWithoutCurrent.map((e) {
        int index = listGlobalKeyWithoutCurrent.indexOf(e);
        List<Offset> listOffset = _getGlobalPositionPlacement(index);
        return [listOffset[0].dx, listOffset[1].dx];
      }).toList());

      final newDetailsGlobalPosition = Offset(
          details.globalPosition.dx * RmaxWidthToWidth,
          details.globalPosition.dy * RmaxHeightToHeight);
      final newPlacement = selectedPlacement.copyWith(ratioOffset: [
        _selectedPlacement!.ratioOffset[0] + deltaGlobalPosition.dx / _maxWidth,
        _selectedPlacement!.ratioOffset[1] +
            deltaGlobalPosition.dy / _maxHeight,
      ]);
      // for (int i = 0; i < listVerticalPosition.length; i++) {
      //   if (checkInsideDistance(
      //       newDetailsGlobalPosition.dy, listVerticalPosition[i], 3)) {}
      // }

      _listPlacement[indexOfFocusPlacement] = newPlacement;
    }
  }

  Widget _buildCustomArea() {
    final areaBox =
        _drawAreaKey.currentContext?.findRenderObject() as RenderBox?;
    return Stack(
      children: [
        GestureDetector(
          onPanStart: (details) {
            _startOffset = details.globalPosition;
            _onFocusPlacement(details.globalPosition);
          },
          onPanUpdate: (details) {
            // tinh do chenh lech cua global position
            if (_selectedPlacement != null) {
              final index = _listPlacement
                  .map((e) => e.id)
                  .toList()
                  .indexOf(_selectedPlacement!.id);
              _translatePlacement(_listPlacement[index], details);
              //left
              if (_listPlacement[index].ratioOffset[0] <= 0) {
                _listPlacement[index].ratioOffset = [
                  0,
                  _listPlacement[index].ratioOffset[1]
                ];
                _listPlacement[index].previewRatioOffset = [
                  0,
                  _listPlacement[index].previewRatioOffset[1]
                ];
              }
              //top
              if (_listPlacement[index].ratioOffset[1] <= 0) {
                _listPlacement[index].ratioOffset = [
                  _listPlacement[index].ratioOffset[0],
                  0
                ];
                _listPlacement[index].previewRatioOffset = [
                  _listPlacement[index].previewRatioOffset[0],
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
                _listPlacement[index].previewRatioOffset = [
                  1 - _listPlacement[index].ratioWidth,
                  _listPlacement[index].previewRatioOffset[1]
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
                _listPlacement[index].previewRatioOffset = [
                  _listPlacement[index].previewRatioOffset[0],
                  1 - _listPlacement[index].ratioHeight
                ];
              }
              widget.onFocusPlacement!(
                  _listPlacement[index], _matrix4Notifiers[index]);
              setState(() {});
            }
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
                                          borderRadius:
                                              BorderRadius.circular(12.5),
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
        ),
        // Positioned.fill(
        //   top: _startOffset.dy,
        //   left: _startOffset.dx,
        //   child: Container(
        //       height: 10,
        //       width: 10,
        //       decoration: BoxDecoration(border: Border.all(color: colorRed))),
        // )
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

  Widget _buildDotDrag(int index, double size,
      {void Function(DragUpdateDetails details)? onPanUpdate,
      void Function(DragStartDetails)? onPanStart,
      void Function(DragEndDetails)? onPanEnd,
      void Function()? onTap,
      EdgeInsets? margin,
      Key? key}) {
    return GestureDetector(
      key: key,
      // onPanUpdate: (details) {
      //   onPanUpdate!(details);
      //   widget.onUpdatePlacement(
      //       _listPlacement, _listPlacement[index], _matrix4Notifiers[index]);
      // },
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
