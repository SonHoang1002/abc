// import 'package:color_picker_android/screens/color_picker_1.dart' as cp;
// import 'package:flutter/material.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart'; 
// import 'package:photo_to_pdf/commons/constants.dart';
// import 'package:photo_to_pdf/helpers/navigator_route.dart';
// import 'package:photo_to_pdf/widgets/w_spacer.dart';
// import 'package:photo_to_pdf/widgets/w_text_content.dart';

// class BackgroundBody extends StatelessWidget {
//   final Color currentColor;
//   final Function(Color color) onColorChanged;
//   final Function() reRenderFunction;
//   const BackgroundBody(
//       {super.key,
//       required this.currentColor,
//       required this.onColorChanged,
//       required this.reRenderFunction});

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.sizeOf(context);
//     bool lay_custom_background = true;
//     return Container(
//       constraints: BoxConstraints(
//           maxHeight: size.height * 0.9, minHeight: size.height * 0.5),
//       decoration: BoxDecoration(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(20.0),
//           topRight: Radius.circular(20.0),
//         ),
//       ),
//       child: Column(
//         children: [
//           Container(
//             margin: const EdgeInsets.only(top: 20),
//             child: WTextContent(
//               value: "Color",
//               textSize: 16,
//               textLineHeight: 19.09,
//               textColor: Theme.of(context).textTheme.bodyMedium!.color,
//             ),
//           ),
//           WSpacer(
//             height: 10,
//           ),
//           lay_custom_background
//               ? cp.ColorPicker(
//                   topicColor: const Color.fromRGBO(0, 0, 0, 0.05),
//                   currentColor: currentColor,
//                   onDone: (color) {
//                     onColorChanged(color);
//                     popNavigator(context);
//                   },
//                   listColorSaved: ALL_COLORS,
//                   onColorSave: (Color color) {},
//                 )
//               : Container(
//                   decoration: BoxDecoration(
//                       color: Theme.of(context).canvasColor,
//                       borderRadius: BorderRadius.circular(20)),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                   child: ColorPicker(
//                     pickerColor: currentColor,
//                     onColorChanged: (color) {
//                       onColorChanged(color);
//                     },
//                     // 2 property below to disable opacity of color
//                     displayThumbColor: false,
//                     enableAlpha: false,
//                     paletteType: PaletteType.hsvWithHue,
//                     labelTypes: ColorLabelType.values,
//                     portraitOnly: false,
//                     colorPickerWidth: size.width * 0.8,
//                     pickerAreaHeightPercent: 1.0,
//                     pickerAreaBorderRadius: const BorderRadius.all(Radius.zero),
//                     colorHistory: ALL_COLORS,
//                     onHistoryChanged: (colors) {},
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }
// }
