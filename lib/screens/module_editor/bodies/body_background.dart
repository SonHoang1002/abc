import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class BackgroundBody extends StatelessWidget {
  final Color currentColor;
  final Function(Color color) onColorChanged;
  const BackgroundBody(
      {super.key, required this.currentColor, required this.onColorChanged});

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
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) {
                onColorChanged(color);
              },
              // 2 property below to disable opacity of color
              displayThumbColor: false,
              enableAlpha: false,
              paletteType: PaletteType.hsvWithHue,
              labelTypes: const [
                ColorLabelType.rgb,
                ColorLabelType.hsv,
                ColorLabelType.hsl,
                ColorLabelType.hsl,
              ],
              portraitOnly: false,
              colorPickerWidth: size.width * 0.8,
              pickerAreaHeightPercent: 1.0,
              pickerAreaBorderRadius: const BorderRadius.all(Radius.zero),
              colorHistory: ALL_COLORS,
              onHistoryChanged: (colors) {},
            ),
          ),
        ],
      ),
    );
  }
}
