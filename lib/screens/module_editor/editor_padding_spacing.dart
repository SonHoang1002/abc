import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class EditorPaddingSpacing extends StatefulWidget {
  final String title;
  final List<TextEditingController> controllers;
  final Function(int index, String value) onChanged;
  const EditorPaddingSpacing(
      {super.key,
      required this.title,
      required this.controllers,
      required this.onChanged});

  @override
  State<EditorPaddingSpacing> createState() => _EditorPaddingSpacingState();
}

class _EditorPaddingSpacingState extends State<EditorPaddingSpacing> {
  String? _selectedLabel;
  late Size _size;
  late List<String> _labelInputs;

  List<String> LABELS_PADDING_SPACING = ["Horizontal", "Vertical"];
  List<String> LABELS_EDIT_PLACEMENT = [
    "Width",
    "Height",
    "Top",
    "Left",
    "Right",
    "Bottom"
  ];

  @override
  void initState() {
    super.initState();

    if ([TITLE_EDIT_PLACEMENT].contains(widget.title)) {
      _labelInputs = LABELS_EDIT_PLACEMENT;
      // _selectedLabel = _labelInputs[2];
    } else {
      _labelInputs = LABELS_PADDING_SPACING;
      _selectedLabel = _labelInputs[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: transparent,
      resizeToAvoidBottomInset:
          // false,
          [TITLE_PADDING, TITLE_SPACING].contains(widget.title) ? false : true,
      body: Container(
          // margin: const EdgeInsets.only(bottom: 40),
          color: transparent,
          child: Stack(
            children: [
              Positioned.fill(child: GestureDetector(
                onTap: () {
                  for (int i = 0; i < widget.controllers.length; i++) {
                    if (widget.controllers[i].text.trim().isEmpty) {
                      widget.onChanged(i, "0.0");
                    }
                  }
                  popNavigator(context);
                },
              )),
              [TITLE_EDIT_PLACEMENT].contains(widget.title)
                  ? _buildEditPlacementBody()
                  : _buildPaddingSpacingBody(title: widget.title, height: 140),
            ],
          )),
    );
  }

  Widget _buildEditPlacementBody() {
    return Center(
      child: Container(
        height: _size.width * 0.9,
        padding: const EdgeInsets.all(10),
        // margin:
        //     EdgeInsets.only(top: _size.height * 0.07, left: _size.height * 0.025),
        alignment: Alignment.center,
        width: _size.width * 0.9,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).canvasColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            WTextContent(
              value: widget.title,
              textColor: Theme.of(context).textTheme.bodyLarge!.color,
              textLineHeight: 16.71,
              textSize: 14,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: _size.width * 0.27,
                  child: _buildInput(
                      widget.controllers[2],
                      (value) {
                        widget.onChanged(2, value);
                      },
                      _selectedLabel == _labelInputs[2],
                      onTap: () {
                        setState(() {
                          _selectedLabel = _labelInputs[2];
                        });
                      },
                      autoFocus: false),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: _size.width * 0.27,
                        child: _buildInput(
                            widget.controllers[3],
                            (value) {
                              widget.onChanged(3, value);
                            },
                            _selectedLabel == _labelInputs[3],
                            onTap: () {
                              setState(() {
                                _selectedLabel = _labelInputs[3];
                              });
                            },
                            autoFocus: false),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 15),
                        child: Image.asset(
                          "${pathPrefixIcon}icon_placement_center.png",
                          height: 80,
                          width: 80,
                          scale: 3,
                        ),
                      ),
                      SizedBox(
                        width: _size.width * 0.27,
                        child: _buildInput(
                            widget.controllers[4],
                            (value) {
                              widget.onChanged(4, value);
                            },
                            _selectedLabel == _labelInputs[4],
                            onTap: () {
                              setState(() {
                                _selectedLabel = _labelInputs[4];
                              });
                            },
                            autoFocus: false),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: _size.width * 0.27,
                  child: _buildInput(
                      widget.controllers[5],
                      (value) {
                        widget.onChanged(5, value);
                      },
                      _selectedLabel == _labelInputs[5],
                      onTap: () {
                        setState(() {
                          _selectedLabel = _labelInputs[5];
                        });
                      },
                      autoFocus: false),
                ),
              ],
            ),
            _buildPaddingSpacingBody(
              padding: EdgeInsets.zero,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPaddingSpacingBody(
      {double? height,
      EdgeInsets? padding = const EdgeInsets.all(10),
      String? title}) {
    return Center(
      child: Container(
        height: height,
        padding: padding,
        alignment: Alignment.center,
        width: _size.width * 0.9,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).canvasColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            title != null
                ? WTextContent(
                    value: widget.title,
                    textColor: Theme.of(context).textTheme.bodyLarge!.color,
                    textLineHeight: 16.71,
                    textSize: 14,
                  )
                : const SizedBox(),
            Flex(direction: Axis.horizontal, children: [
              Flexible(
                child: Column(
                  children: [
                    SizedBox(
                      width: _size.width * 0.45,
                      child: _buildInput(
                          widget.controllers[0],
                          (value) {
                            widget.onChanged(0, value);
                          },
                          _selectedLabel == _labelInputs[0],
                          onTap: () {
                            setState(() {
                              _selectedLabel = _labelInputs[0];
                            });
                          },
                          autoFocus:
                              [TITLE_EDIT_PLACEMENT].contains(widget.title)
                                  ? false
                                  : true),
                    ),
                    WSpacer(
                      height: 7,
                    ),
                    WTextContent(
                      value: "Horizontal",
                      textSize: 12,
                      textFontWeight: FontWeight.w600,
                      textLineHeight: 14.32,
                      textColor: Theme.of(context).textTheme.bodyLarge!.color,
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
                    SizedBox(
                      width: _size.width * 0.45,
                      child: _buildInput(
                          widget.controllers[1],
                          (value) {
                            widget.onChanged(1, value);
                          },
                          _selectedLabel == _labelInputs[1],
                          onTap: () {
                            setState(() {
                              _selectedLabel = _labelInputs[1];
                            });
                          },
                          autoFocus: false),
                    ),
                    WSpacer(
                      height: 7,
                    ),
                    WTextContent(
                      value: "Vertical",
                      textSize: 12,
                      textFontWeight: FontWeight.w600,
                      textLineHeight: 14.32,
                      textColor: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox()
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller,
      void Function(String)? onChanged, bool isFocus,
      {void Function()? onTap, bool? autoFocus, bool? isHaveSuffix}) {
    return Container(
        height: 35,
        // width: width,
        alignment: Alignment.center,
        child: CupertinoTextField(
          onTap: onTap,
          onChanged: onChanged,
          autofocus: autoFocus ?? false,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).cardColor,
              border: Border.all(
                  color: isFocus
                      ? const Color.fromRGBO(98, 161, 255, 1)
                      : transparent,
                  width: 2)),
          suffix: isHaveSuffix == true
              ? Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(right: 10),
                  child: const Text("cm",
                      style: TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                          fontFamily: myCustomFont,
                          fontWeight: FontWeight.w700,
                          height: 16.71 / 14,
                          fontSize: 14)),
                )
              : const SizedBox(),
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
