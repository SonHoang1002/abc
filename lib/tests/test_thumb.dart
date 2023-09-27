import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/widgets/w_thumb_slider.dart';

class TestThumb extends StatefulWidget {
  const TestThumb({super.key});

  @override
  State<TestThumb> createState() => _TestThumbState();
}

class _TestThumbState extends State<TestThumb> {
  double sliderCompressionLevelValue = 1.0;
  @override
  Widget build(BuildContext context) {
    return 
    SliderTheme(
      data: const SliderThemeData(
        trackHeight: 2,
        activeTrackColor: colorBlue,
        thumbShape: CustomSliderThumbCircle(
          thumbRadius: 14.0,
          borderColor: colorBlue,
          borderWidth: 4.0,
          backgroundColor: colorWhite,
          thumbHeight: 24
        ),
      ),
      child:
       Slider(
        value: sliderCompressionLevelValue,
        onChanged: (value) {
          setState(() {
            sliderCompressionLevelValue = value;
          });
        },
        min: 0,
        max: 1,
        thumbColor: colorWhite,
        activeColor: colorBlue,
        inactiveColor: const Color.fromRGBO(0, 0, 0, 0.1),
      ),
    );
  }
}
