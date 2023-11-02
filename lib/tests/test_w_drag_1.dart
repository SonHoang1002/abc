import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/check_distance.dart';
import 'package:photo_to_pdf/helpers/convert.dart';
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

  int? _getCurrentPlacement(Offset startOffset) {
    final RmaxWidthToWidth = _maxWidth / _size.width;
    final RmaxHeightToHeight = _maxHeight / _size.height;
    print('${RmaxWidthToWidth},${RmaxHeightToHeight}');
    List<Placement> listConvertPlacement = _listPlacement.map((e) {
      return e.copyWith(
        ratioOffset: _changeValueOfList(
            e.ratioOffset, [RmaxWidthToWidth, RmaxHeightToHeight], 4),
        ratioHeight: e.ratioHeight,
        ratioWidth: e.ratioWidth,
      );
    }).toList();
    print("startOffset ${startOffset}");
    for (int i = 0; i < listConvertPlacement.length; i++) {
      Offset dotTopLeft = Offset(
          listConvertPlacement[i].ratioOffset[0] * _size.width,
          listConvertPlacement[i].ratioOffset[1] * _size.height);
      Offset dotBottomRight = Offset(
          (listConvertPlacement[i].ratioOffset[0] +
                  listConvertPlacement[i].ratioWidth) *
              _size.width,
          (listConvertPlacement[i].ratioOffset[1] +
                  listConvertPlacement[i].ratioHeight) *
              _size.height);
      print("dotTopLeft ${dotTopLeft}, dotBottomRight ${dotBottomRight}");
      if ((dotTopLeft.dx < startOffset.dx &&
              startOffset.dx < dotBottomRight.dx) &&
          (dotTopLeft.dy < startOffset.dy &&
              startOffset.dy < dotBottomRight.dy)) {
        return i;
      }
    }
  }

  /// [operation]: 0 -> +
  ///
  /// [operation]: 1 -> -
  ///
  /// [operation]: 2 -> x
  ///
  /// [operation]: 3 -> /
  List<double> _changeValueOfList(
      List<double> listRoot, List<double> listValue, int operation) {
    switch (operation) {
      case 0:
        return [
          listRoot[0] + listValue[0],
          listRoot[1] + listValue[1],
        ];
      case 1:
        return [
          listRoot[0] - listValue[0],
          listRoot[1] - listValue[1],
        ];
      case 2:
        return [
          listRoot[0] * listValue[0],
          listRoot[1] * listValue[1],
        ];
      case 3:
        return [
          listRoot[0] / listValue[0],
          listRoot[1] / listValue[1],
        ];
      default:
        return [listRoot[0], listRoot[1]];
    }
  }

  Widget _buildCustomArea() {
    final areaBox =
        _drawAreaKey.currentContext?.findRenderObject() as RenderBox?;
    return GestureDetector(
      onPanStart: (details) {
        print(_getCurrentPlacement(details.globalPosition));
      },
      onTap: () {},
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
      onPanUpdate: (details) {
        onPanUpdate!(details);
        widget.onUpdatePlacement(
            _listPlacement, _listPlacement[index], _matrix4Notifiers[index]);
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
