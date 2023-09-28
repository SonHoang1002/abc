import 'package:color_parser/color_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/widgets/w_thumb_slider.dart';

class TestThumb extends StatefulWidget {
  const TestThumb({super.key});

  @override
  State<TestThumb> createState() => _TestThumbState();
}

class _TestThumbState extends State<TestThumb> {
  double sliderCompressionLevelValue = 1.0;
  // create some values
  Color pickerColor = const Color(0xff443a49);
  Color currentColor = const Color(0xff443a49);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            color: currentColor,
            height: 80,
            width: 80,
          ),
          MaterialButton(
            onPressed: () {
              showColorPalette();
            },
            child: const Text("choose color"),
          ),
        ],
      ),
    );
  }

// ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void showColorPalette() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {},
              pickerHsvColor: HSVColor.fromColor(Colors.blue),
              onHsvColorChanged: (hsvColor) {
                // Xử lý sự kiện khi màu HSV được chọn thay đổi
              },
              paletteType: PaletteType.hsvWithHue,
              enableAlpha: true,
              labelTypes: const [
                ColorLabelType.rgb,
                ColorLabelType.hsv,
                ColorLabelType.hsl
              ],
              displayThumbColor: true,
              portraitOnly: false,
              colorPickerWidth: 300.0,
              pickerAreaHeightPercent: 1.0,
              pickerAreaBorderRadius: const BorderRadius.all(Radius.zero),
              hexInputBar: false,
              hexInputController: TextEditingController(),
              colorHistory: const [
                Colors.red,
                Colors.green,
                Colors.blue,
                colorBlack
              ],
              onHistoryChanged: (colors) {
                // Xử lý sự kiện khi lịch sử màu được thay đổi
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                setState(() => currentColor = pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
