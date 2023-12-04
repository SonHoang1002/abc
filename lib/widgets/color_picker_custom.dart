// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:photo_to_pdf/commons/colors.dart';
// import 'package:photo_to_pdf/commons/constants.dart';
// import 'package:photo_to_pdf/commons/themes.dart';
// import 'package:photo_to_pdf/helpers/check_distance.dart';
// import 'package:photo_to_pdf/widgets/w_divider.dart';
// import 'package:photo_to_pdf/widgets/w_spacer.dart';
// import 'package:photo_to_pdf/widgets/w_text_content.dart';
// import 'package:provider/provider.dart';

// class BackgroundColorPicker extends StatefulWidget {
//   final Color currentColor;
//   final Function(Color) onColorChange;
//   final Color? trackerSliderColor;
//   final String? fontFamily;
//   final double? dotHSVSize;
//   const BackgroundColorPicker(
//       {super.key,
//       required this.currentColor,
//       required this.onColorChange,
//       this.trackerSliderColor,
//       this.fontFamily,
//       this.dotHSVSize});

//   @override
//   State<BackgroundColorPicker> createState() => _BackgroundColorPickerState();
// }

// class _BackgroundColorPickerState extends State<BackgroundColorPicker> {
//   final double sizeOfColorPreviewWidget = 40;
//   late Size _size;
//   double _dotSize = 20;
//   Offset _offsetTrackerCursor = const Offset(0, 0);
//   Offset _offsetDotHSV = const Offset(-10, -10);

//   final GlobalKey _keySlider = GlobalKey(debugLabel: "keySlider");
//   final GlobalKey _keyHSVBoard = GlobalKey(debugLabel: "_keyHSVBoard");

//   RenderBox? _renderBoxHSVBoard;
//   RenderBox? _renderBoxSlider;

//   bool? _isInsideHSVBoard;
//   bool? _isInsideSlider;

//   // hsv properties
//   double _hsvAlpha = 1.0;
//   double _hsvHue = 0.0;
//   double _hsvSaturation = 0.0;
//   double _hsvValue = 1.0;
//   // used to change the color response of the border HSV color picker
//   List<double> _limitHueForBorderColors = [210, 275];
//   @override
//   void initState() {
//     super.initState();
//     final hsvColor = HSVColor.fromColor(widget.currentColor);
//     _hsvHue = hsvColor.hue;
//     _hsvSaturation = hsvColor.saturation;
//     _hsvValue = hsvColor.value;
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       _renderBoxHSVBoard =
//           _keyHSVBoard.currentContext?.findRenderObject() as RenderBox;
//       _renderBoxSlider =
//           _keySlider.currentContext?.findRenderObject() as RenderBox;
//       _changePositionWithHSVColor(hsvColor);
//     });
//   }

//   void _onColorChanged() {
//     widget.onColorChange(
//         HSVColor.fromAHSV(_hsvAlpha, _hsvHue, _hsvSaturation, _hsvValue)
//             .toColor());
//   }

//   void _changePositionWithHSVColor(HSVColor hsvColor) {
//     if (_renderBoxHSVBoard != null) {
//       _offsetDotHSV = Offset(
//         hsvColor.saturation * _renderBoxHSVBoard!.size.width,
//         (1 - hsvColor.value) * _renderBoxHSVBoard!.size.height,
//       ).translate(-_dotSize / 2, -_dotSize / 2);
//     }
//     if (_renderBoxSlider != null) {
//       _offsetTrackerCursor = Offset(
//         hsvColor.hue / 360 * _renderBoxSlider!.size.width,
//         _renderBoxSlider!.size.height,
//       );
//     }
//     _hsvHue = hsvColor.hue;
//     _hsvSaturation = hsvColor.saturation;
//     _hsvValue = hsvColor.value;
//     _onColorChanged();
//     setState(() {});
//   }

//   void _updatePositionAndHSVProperty(Offset cursorGlobalPosition) {
//     if (_renderBoxHSVBoard != null && _isInsideHSVBoard == true) {
//       Size size = Size(
//         _renderBoxHSVBoard!.size.width - _dotSize / 2,
//         _renderBoxHSVBoard!.size.height - _dotSize / 2,
//       );
//       final newOffset = _renderBoxHSVBoard!.globalToLocal(cursorGlobalPosition);
//       _offsetDotHSV = Offset(
//         max(0 - _dotSize / 2, min(newOffset.dx, size.width)),
//         max(0 - _dotSize / 2, min(newOffset.dy, size.height)),
//       );
//       _hsvValue =
//           1 - (_offsetDotHSV.dy + _dotSize / 2) / (size.height + _dotSize / 2);
//       _hsvSaturation =
//           (_offsetDotHSV.dx + _dotSize / 2) / (size.width + _dotSize / 2);
//     }
//     if (_renderBoxSlider != null && _isInsideSlider == true) {
//       // khong cho thay doi khi s va v dang o limit
//       if (_hsvSaturation != 0 || _hsvValue != 1) {
//         Size size = Size(
//           _renderBoxSlider!.size.width,
//           _renderBoxSlider!.size.height,
//         );
//         final cursorLocalPosition =
//             _renderBoxSlider!.globalToLocal(cursorGlobalPosition);
//         Offset newOffset = Offset(
//           max(0, min(cursorLocalPosition.dx, size.width)),
//           max(0, min(cursorLocalPosition.dy, size.height)),
//         );
//         final newHue = (newOffset.dx) / (size.width - _dotSize / 2) * 360;
//         if (newHue > 359) {
//           _hsvHue = 0;
//           newOffset = const Offset(0, 0);
//         } else {
//           _hsvHue = newHue;
//         }
//         _offsetTrackerCursor = newOffset;
//       }
//     }
//     _onColorChanged();
//     setState(() {});
//   }

//   void _checkInside(Offset cursorGlobalPosition) {
//     if (_renderBoxHSVBoard != null) {
//       final startOffsetHSVBoard =
//           _renderBoxHSVBoard!.localToGlobal(const Offset(0, 0));
//       final endOffsetHSVBoard = startOffsetHSVBoard.translate(
//           _renderBoxHSVBoard!.size.width, _renderBoxHSVBoard!.size.height);
//       if (containOffset(
//           cursorGlobalPosition, startOffsetHSVBoard, endOffsetHSVBoard)) {
//         _isInsideHSVBoard = true;
//         setState(() {});
//       }
//     }
//     if (_renderBoxSlider != null) {
//       final startOffsetSlider =
//           _renderBoxSlider!.localToGlobal(const Offset(0, 0));
//       final endOffsetSlider = startOffsetSlider.translate(
//           _renderBoxSlider!.size.width, _renderBoxSlider!.size.height);
//       if (containOffset(
//           cursorGlobalPosition, startOffsetSlider, endOffsetSlider)) {
//         _isInsideSlider = true;
//         setState(() {});
//       }
//     }
//   }

//   void _disableInside() {
//     setState(() {
//       _isInsideHSVBoard = null;
//       _isInsideSlider = null;
//     });
//   }

//   Color? _renderBorderColor() {
//     if (_renderBoxHSVBoard != null) {
//       if (_offsetDotHSV.dx < _renderBoxHSVBoard!.size.width / 3 &&
//           _offsetDotHSV.dy < _renderBoxHSVBoard!.size.height / 3) {
//         return colorBlack;
//       }
//       if (_offsetDotHSV.dy >= _renderBoxHSVBoard!.size.height / 2) {
//         return colorWhite;
//       }
//       if (_limitHueForBorderColors[0] < _hsvHue &&
//           _hsvHue < _limitHueForBorderColors[1]) {
//         return colorWhite;
//       } else {
//         return colorBlack;
//       }
//     } else {
//       return colorGrey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     _size = MediaQuery.sizeOf(context);
//     return GestureDetector(
//       onTapDown: (details) {
//         _checkInside(details.globalPosition);
//         _updatePositionAndHSVProperty(details.globalPosition);
//       },
//       onPanUpdate: (details) {
//         _updatePositionAndHSVProperty(details.globalPosition);
//       },
//       onPanEnd: (details) {
//         _disableInside();
//       },
//       onTapUp: (details) {
//         _disableInside();
//       },
//       onPanStart: (details) {
//         _checkInside(details.globalPosition);
//       },
//       child: Container(
//         width: _size.width * 0.9,
//         height: _size.height * 0.8,
//         margin: const EdgeInsets.only(bottom: 30),
//         decoration:
//             BoxDecoration(border: Border.all(color: colorBlack, width: 0.2)),
//         child: Column(children: [
//           SizedBox(
//             key: _keyHSVBoard,
//             height: _size.width * 0.9,
//             width: _size.width * 0.9,
//             child: Stack(
//               children: [
//                 // S from left to right
//                 _buildSaturationBox(),
//                 // value from bottom to top
//                 _buildValueBox(),
//                 Positioned(
//                     left: _offsetDotHSV.dx,
//                     top: _offsetDotHSV.dy,
//                     child: _buildDot(transparent,
//                         borderWidth: 1, borderColor: _renderBorderColor())),
//               ],
//             ),
//           ),
//           WSpacer(
//             height: 10,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Container(
//                 height: sizeOfColorPreviewWidget,
//                 width: sizeOfColorPreviewWidget,
//                 decoration: BoxDecoration(
//                     color: HSVColor.fromAHSV(
//                             _hsvAlpha, _hsvHue, _hsvSaturation, _hsvValue)
//                         .toColor(),
//                     border: Border.all(
//                         color: Provider.of<ThemeManager>(context).isDarkMode
//                             ? colorWhite
//                             : colorBlack,
//                         width: 0.2),
//                     borderRadius:
//                         BorderRadius.circular(sizeOfColorPreviewWidget / 2)),
//               ),
//               Column(
//                 children: [
//                   Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       Container(
//                         width: _size.width * 0.6,
//                         height: 20,
//                         padding: const EdgeInsets.all(5),
//                         child: Container(
//                           key: _keySlider,
//                           width: _size.width * 0.4,
//                           height: 10,
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(20),
//                               gradient: LinearGradient(
//                                   colors: COLOR_SLIDERS,
//                                   begin: Alignment.centerLeft,
//                                   end: Alignment.centerRight)),
//                         ),
//                       ),
//                       Positioned(
//                         left: _offsetTrackerCursor.dx,
//                         child:
//                             _buildDot(widget.trackerSliderColor ?? colorWhite),
//                       )
//                     ],
//                   ),
//                 ],
//               )
//             ],
//           ),
//           Center(
//             child: WDivider(
//               color: colorGrey,
//               height: 0.5,
//               width: _size.width * 0.4,
//               margin: const EdgeInsets.symmetric(vertical: 10),
//             ),
//           ),
//           WSpacer(
//             height: 10,
//           ),
//           _buildSuggestColor(),
//           WSpacer(
//             height: 10,
//           ),
//           _buildPreviewResult(),
//         ]),
//       ),
//     );
//   }

//   Widget _buildSuggestColor() {
//     return SizedBox(
//       width: _size.width * 0.8,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//             children: ALL_COLORS
//                 .map(
//                   (e) => GestureDetector(
//                     onTap: () {
//                       _changePositionWithHSVColor(HSVColor.fromColor(e));
//                     },
//                     child: Container(
//                       height: _dotSize,
//                       width: _dotSize,
//                       margin: const EdgeInsets.symmetric(horizontal: 5),
//                       decoration: BoxDecoration(
//                           color: e,
//                           borderRadius: BorderRadius.circular(_dotSize / 2)),
//                     ),
//                   ),
//                 )
//                 .toList()),
//       ),
//     );
//   }

//   Widget _buildPreviewResult() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         WTextContent(value: "HSV Propeties: "),
//         SizedBox(
//           height: 40,
//           width: 150,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               WSpacer(
//                 width: 5,
//               ),
//               _buildPreviewResultItem("H", "${(_hsvHue).toStringAsFixed(0)}°"),
//               _buildPreviewResultItem(
//                   "S", "${(_hsvSaturation * 100).toStringAsFixed(0)}%"),
//               _buildPreviewResultItem(
//                   "V", "${(_hsvValue * 100).toStringAsFixed(0)}%"),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSaturationBox() {
//     return Container(
//       foregroundDecoration: BoxDecoration(
//         gradient: LinearGradient(colors: [
//           colorWhite,
//           HSVColor.fromAHSV(1, _hsvHue, 1, 1).toColor(),
//         ], begin: Alignment.centerLeft, end: Alignment.centerRight),
//       ),
//     );
//   }

//   Widget _buildValueBox() {
//     return Container(
//       foregroundDecoration: const BoxDecoration(
//         gradient: LinearGradient(colors: [
//           transparent,
//           colorBlack,
//         ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
//       ),
//     );
//   }

// // general
//   Widget _buildDot(Color backgroundColor,
//       {Color? borderColor = colorBlack, double? borderWidth = 0.3}) {
//     return Container(
//       height: _dotSize,
//       width: _dotSize,
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(_dotSize / 2),
//           border: Border.all(
//             color: borderColor!,
//             width: borderWidth!,
//           ),
//           color: backgroundColor),
//     );
//   }

//   Widget _buildPreviewResultItem(String title, String value) {
//     return SizedBox(
//       width: 40,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           WTextContent(value: title),
//           const SizedBox(
//             height: 7,
//           ),
//           WTextContent(
//             value: value,
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }
