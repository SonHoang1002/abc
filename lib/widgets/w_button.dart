import 'package:flutter/material.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class WButtonElevated extends StatelessWidget {
  final String message;
  final double? width;
  final double? height;
  final Function()? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? elevation;
  final Color? shadowColor;

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
      this.textColor,
      this.elevation,
      this.shadowColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.only(bottom: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            shadowColor: shadowColor,
            elevation: elevation,
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
  final double? textSize;
  final double? textLineHeight;
  final double? borderRadius;
  final bool? isVerticalAlignment;

  /// [mediaValue] can be IconData, assets String ( include icon or image )
  final dynamic mediaValue;
  final Color? mediaColor;
  final double? mediaSize;
  final EdgeInsets padding;
  final double? elevation;
  final Color? shadowColor;
  final List<BoxShadow>? boxShadow;

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
      this.textColor,
      this.borderRadius,
      this.textSize = 15,
      this.textLineHeight = 34,
      this.padding = const EdgeInsets.only(bottom: 10),
      this.elevation,
      this.shadowColor,
      this.boxShadow,
      this.isVerticalAlignment = true});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FilledButton(
            style: FilledButton.styleFrom(
                padding: padding,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius ?? 25)),
                backgroundColor: backgroundColor,
                elevation: elevation,
                shadowColor: shadowColor),
            onPressed: onPressed,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: boxShadow,
              ),
              width: width, // 255
              height: height, //60
              child: Center(
                child: mediaValue != null
                    ? isVerticalAlignment!
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                // padding: const EdgeInsets.only(top: 10),
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
                              WSpacer(height: 5,),
                              Text(
                                message,
                                style: TextStyle(
                                  fontSize: textSize,
                                  // height: textLineHeight,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              )
                              // WTextContent(
                              //   value: message,
                              //   textSize: textSize,
                              //   textLineHeight: textLineHeight,
                              //   textColor: textColor,
                              // )
                            ],
                          )
                        : Row(
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
                                textSize: textSize,
                                textLineHeight: textLineHeight,
                                textColor: textColor,
                              )
                            ],
                          )
                    : WTextContent(
                        value: message,
                        textSize: textSize,
                        textLineHeight: textLineHeight,
                        textColor: textColor,
                        textAlign: TextAlign.center,
                      ),
              ),
            )),
      ],
    );
  }
}
