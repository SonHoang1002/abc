import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/check_distance.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class BackgroundBody extends StatelessWidget {
  final Color currentColor;
  final Function(Color color) onColorChanged;
  final Function() reRenderFunction;
  const BackgroundBody(
      {super.key,
      required this.currentColor,
      required this.onColorChanged,
      required this.reRenderFunction});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      constraints: BoxConstraints(
          maxHeight: size.height * 0.85, minHeight: size.height * 0.5),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: WTextContent(
              value: "Color",
              textSize: 16,
              textLineHeight: 19.09,
              textColor: Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),
          WSpacer(
            height: 10,
          ),
          const BackgroundColorPicker()

          // Container(
          //   decoration: BoxDecoration(
          //       color: Theme.of(context).canvasColor,
          //       borderRadius: BorderRadius.circular(20)),
          //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          //   child: ColorPicker(
          //     pickerColor: currentColor,
          //     onColorChanged: (color) {
          //       onColorChanged(color);
          //     },
          //     // 2 property below to disable opacity of color
          //     displayThumbColor: false,
          //     enableAlpha: false,
          //     paletteType: PaletteType.hsvWithHue,
          //     labelTypes: ColorLabelType.values,
          //     portraitOnly: false,
          //     colorPickerWidth: size.width * 0.8,
          //     pickerAreaHeightPercent: 1.0,
          //     pickerAreaBorderRadius: const BorderRadius.all(Radius.zero),
          //     colorHistory: ALL_COLORS,
          //     onHistoryChanged: (colors) {},
          //   ),
          // ),
        ],
      ),
    );
  }
}

class BackgroundColorPicker extends StatefulWidget {
  const BackgroundColorPicker({super.key});

  @override
  State<BackgroundColorPicker> createState() => _BackgroundColorPickerState();
}

class _BackgroundColorPickerState extends State<BackgroundColorPicker> {
  final double sizeOfPreviewColor = 50;
  late Color _colorPicked;
  late Size _size;
  double _selectedColorSliderValue = 0;
  Offset _offsetTrackerCursor = const Offset(0, 0);
  Offset _offsetDotHSV = const Offset(-10, -10);

  final GlobalKey _keySlider = GlobalKey(debugLabel: "keySlider");
  final GlobalKey _keyBody = GlobalKey(debugLabel: "_keyBody");
  final GlobalKey _keyHSVBoard = GlobalKey(debugLabel: "_keyBody");

  late RenderBox _renderBoxHSVBoard;
  late RenderBox _renderBoxSlider;
  bool? _isInsideHSVBoard;
  bool? _isInsideSlider;
  @override
  void initState() {
    super.initState();
    _colorPicked = colorBlack;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _renderBoxHSVBoard =
          _keyHSVBoard.currentContext?.findRenderObject() as RenderBox;
      _renderBoxSlider =
          _keySlider.currentContext?.findRenderObject() as RenderBox;
    });
  }

  void _updatePosition(Offset cursorGlobalPosition) {
    if (_isInsideHSVBoard == true) {
      _offsetDotHSV = _renderBoxHSVBoard.globalToLocal(cursorGlobalPosition);
      setState(() {});
    }
    if (_isInsideSlider == true) {
      _offsetTrackerCursor =
          _renderBoxSlider.globalToLocal(cursorGlobalPosition);
      setState(() {});
    }
  }
  

  void _checkInside(Offset cursorGlobalPosition) {
    // check inside hsv board
    final startOffsetHSVBoard =
        _renderBoxHSVBoard.localToGlobal(const Offset(0, 0));
    final endOffsetHSVBoard = startOffsetHSVBoard.translate(
        _renderBoxHSVBoard.size.width, _renderBoxHSVBoard.size.height);
    if (containOffset(
        cursorGlobalPosition, startOffsetHSVBoard, endOffsetHSVBoard)) {
      _isInsideHSVBoard = true;
      setState(() {});
    }

    final startOffsetSlider =
        _renderBoxSlider.localToGlobal(const Offset(0, 0));
    final endOffsetSlider = startOffsetSlider.translate(
        _renderBoxSlider.size.width, _renderBoxSlider.size.height);
    if (containOffset(
        cursorGlobalPosition, startOffsetSlider, endOffsetSlider)) {
      _isInsideSlider = true;
      setState(() {});
    }
    // check override
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTapDown: (details) {
        _checkInside(details.globalPosition);
        _updatePosition(details.globalPosition);
      },
      onPanUpdate: (details) {
        _updatePosition(details.globalPosition);
      },
      onPanEnd: (details) {
        setState(() {
          _isInsideHSVBoard = null;
          _isInsideSlider = null;
        });
      },
      onPanStart: (details) {
        _checkInside(details.globalPosition);
      },
      child: Container(
        key: _keyBody,
        width: _size.width * 0.9,
        height: _size.height * 0.7,
        decoration:
            BoxDecoration(border: Border.all(color: colorBlack, width: 0.2)),
        child: Column(children: [
          // bang mau vuong
          // preview color
          // ba thanh dieu chinh mau hsv
          SizedBox(
            key: _keyHSVBoard,
            height: _size.width * 0.9,
            width: _size.width * 0.9,
            child: Stack(
              children: [
                _buildSaturationBox(),
                _buildValueBox(),
                Positioned(
                    left: _offsetDotHSV.dx,
                    top: _offsetDotHSV.dy,
                    child: _buildDot(colorBlue)),
              ],
            ),
          ),
          WSpacer(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: sizeOfPreviewColor,
                width: sizeOfPreviewColor,
                decoration: BoxDecoration(
                    color: _colorPicked,
                    borderRadius:
                        BorderRadius.circular(sizeOfPreviewColor / 2)),
              ),
              Column(
                children: [
                  Stack(
                    key: _keySlider,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: _size.width * 0.6,
                        height: 20,
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          width: _size.width * 0.6,
                          height: 10,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                  colors: COLOR_SLIDERS,
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight)),
                        ),
                      ),
                      Positioned(
                        left: _offsetTrackerCursor.dx,
                        child: _buildDot(colorWhite),
                      )
                    ],
                  ),
                  WTextContent(value: "$_selectedColorSliderValue")
                ],
              )
            ],
          )
        ]),
      ),
    );
  }

  Widget _buildSaturationBox() {
    return Container(
      foregroundDecoration: const BoxDecoration(
        gradient: LinearGradient(colors: [
          colorWhite,
          colorRed,
        ], begin: Alignment.centerLeft, end: Alignment.centerRight),
      ),
    );
  }

  Widget _buildValueBox() {
    return Container(
      foregroundDecoration: const BoxDecoration(
        gradient: LinearGradient(colors: [
          transparent,
          colorBlack,
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
    );
  }

  Widget _buildDot(Color backgroundColor) {
    return Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorBlack, width: 0.5),
          color: backgroundColor),
    );
  }
}
