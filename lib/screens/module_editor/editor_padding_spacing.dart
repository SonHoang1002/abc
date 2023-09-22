import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class EditorPaddingSpacing extends StatefulWidget {
  final String title;
  final Offset offset;
  final List<TextEditingController> controllers;
  final Function(int index, String value) onChanged;
  const EditorPaddingSpacing(
      {super.key,
      required this.title,
      required this.offset,
      required this.controllers,
      required this.onChanged});

  @override
  State<EditorPaddingSpacing> createState() => _EditorPaddingSpacingState();
}

class _EditorPaddingSpacingState extends State<EditorPaddingSpacing> {
  late bool _isVertical;
  @override
  void initState() {
    super.initState();
    _isVertical = false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Material(
      color: transparent,
      child: Container(
        color: transparent,
        child: Stack(children: [
          Positioned.fill(child: GestureDetector(
            onTap: () {
              popNavigator(context);
            },
          )),
          Positioned(
              bottom: size.height - widget.offset.dy,
              left: widget.offset.dx,
              child: Container(
                height: 150,
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                width: size.width * 0.9,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey.shade100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    WTextContent(
                      value: widget.title,
                      textColor: const Color.fromRGBO(0, 0, 0, 0.5),
                      textLineHeight: 16.71,
                      textSize: 14,
                    ),
                    Flex(direction: Axis.horizontal, children: [
                      Flexible(
                        child: Column(
                          children: [
                            _buildPaddingInput(
                                widget.controllers[0],
                                (value) {
                                  widget.onChanged(0, value);
                                },
                                !_isVertical,
                                onTap: () {
                                  setState(() {
                                    _isVertical = false;
                                  });
                                },
                                autoFocus: true),
                            WSpacer(
                              height: 7,
                            ),
                            WTextContent(
                              value: "Horizontal",
                              textSize: 12,
                              textFontWeight: FontWeight.w600,
                              textLineHeight: 14.32,
                              textColor: const Color.fromRGBO(0, 0, 0, 0.5),
                            ),
                          ],
                        ),
                      ),
                      WSpacer(
                        width: 20,
                      ),
                      Flexible(
                        child: Column(
                          children: [
                            _buildPaddingInput(
                              widget.controllers[1],
                              (value) {
                                widget.onChanged(1, value);
                              },
                              _isVertical,
                              onTap: () {
                                setState(() {
                                  _isVertical = true;
                                });
                              },
                            ),
                            WSpacer(
                              height: 7,
                            ),
                            WTextContent(
                              value: "Horizontal",
                              textSize: 12,
                              textFontWeight: FontWeight.w600,
                              textLineHeight: 14.32,
                              textColor: const Color.fromRGBO(0, 0, 0, 0.5),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox()
                  ],
                ),
              ))
        ]),
      ),
    );
  }

  Widget _buildPaddingInput(TextEditingController controller,
      void Function(String)? onChanged, bool isFocus,
      {void Function()? onTap, bool? autoFocus}) {
    return Container(
        height: 30,
        width: 170,
        alignment: Alignment.center,
        child: CupertinoTextField(
          onTap: onTap,
          onChanged: onChanged,
          autofocus: autoFocus ?? false,
          textAlign: TextAlign.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color.fromRGBO(255, 255, 255, 1),
              border: Border.all(
                  color: isFocus
                      ? const Color.fromRGBO(98, 161, 255, 1)
                      : transparent,
                  width: 2)),
          style: const TextStyle(
            color: colorBlue,
            height: 16.71 / 14,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: myCustomFont,
          ),
          controller: controller,
        ));
  }
}
