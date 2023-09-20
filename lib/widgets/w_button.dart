import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class WButtonElevated extends StatelessWidget {
  final String message;
  final double? width;
  final double? height;
  final Function()? onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  /// [mediaValue] can be IconData, assets String ( include icon or image )
  final dynamic mediaValue;
  final Color? mediaColor;
  final double? mediaSize;
  final bool? haveShadow;

  const WButtonElevated(
      {super.key,
      this.mediaValue,
      required this.message,
      this.onPressed,
      this.width,
      this.height,
      this.backgroundColor,
      this.mediaColor,
      this.mediaSize,
      this.haveShadow,
      this.textColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.only(bottom: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            // shadowColor: colorLightBlue,
            // elevation: 2,
            backgroundColor: backgroundColor),
        onPressed: onPressed,
        child: SizedBox(
          width: width, // 255
          height: height, //60
          // decoration: BoxDecoration(borderRadius: BorderRadius.circular(60)),
          child: Center(
            child: mediaValue != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: mediaValue is IconData
                            ? Icon(
                                mediaValue,
                                color: mediaColor,
                                size: mediaSize,
                              )
                            : Image.asset(
                                mediaValue,
                                color: mediaColor,
                                height: mediaSize,
                                width: mediaSize,
                              ),
                      ),
                      WSpacer(
                        width: 10,
                      ),
                      WTextContent(
                        value: message,
                        textSize: 15,
                        textLineHeight: 34,
                        textColor: textColor,
                      )
                    ],
                  )
                : WTextContent(
                    value: message,
                    textSize: 15,
                    textLineHeight: 34,
                    textColor: textColor,
                  ),
          ),
        ));
  }
}

class WButtonFilled extends StatelessWidget {
  final String message;
  final double? width;
  final double? height;
  final Function()? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;

  /// [mediaValue] can be IconData, assets String ( include icon or image )
  final dynamic mediaValue;
  final Color? mediaColor;
  final double? mediaSize;
  final bool? haveShadow;

  const WButtonFilled(
      {super.key,
      this.mediaValue,
      required this.message,
      this.onPressed,
      this.width,
      this.height,
      this.backgroundColor,
      this.mediaColor,
      this.mediaSize,
      this.haveShadow,
      this.textColor,
      this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
        style: FilledButton.styleFrom(
            padding: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 20)),
            backgroundColor: backgroundColor),
        onPressed: onPressed,
        child: SizedBox(
          width: width, // 255
          height: height, //60
          // decoration: BoxDecoration(borderRadius: BorderRadius.circular(60)),
          child: Center(
            child: mediaValue != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: mediaValue is IconData
                            ? Icon(
                                mediaValue,
                                color: mediaColor,
                                size: mediaSize,
                              )
                            : Image.asset(
                                mediaValue,
                                color: mediaColor,
                                height: mediaSize,
                                width: mediaSize,
                              ),
                      ),
                      WSpacer(
                        width: 10,
                      ),
                      WTextContent(
                        value: message,
                        textSize: 15,
                        textLineHeight: 34,
                        textColor: textColor,
                      )
                    ],
                  )
                : WTextContent(
                    value: message,
                    textSize: 15,
                    textLineHeight: 34,
                    textColor: textColor,
                  ),
          ),
        ));
  }
}
