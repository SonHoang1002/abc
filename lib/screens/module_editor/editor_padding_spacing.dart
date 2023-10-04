import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/models/placement.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import 'package:photo_to_pdf/widgets/w_unit_selections.dart';

List<String> LABELS_PADDING_SPACING = ["Horizontal", "Vertical"];
List<String> LABELS_EDIT_PLACEMENT = [
  "Width",
  "Height",
  "Top",
  "Left",
  "Right",
  "Bottom"
];

class EditorPaddingSpacing extends StatefulWidget {
  final Placement? placement;
  final SpacingAttribute? spacingAttribute;
  final PaddingAttribute? paddingAttribute;
  final Unit unit;
  final String title;
  final List<String> inputValues;
  final void Function(int index, String value) onChanged;
  final void Function(dynamic newData) onDone;
  final void Function()? reRenderFunction;
  const EditorPaddingSpacing(
      {super.key,
      required this.unit,
      required this.title,
      required this.inputValues,
      required this.onChanged,
      required this.onDone,
      this.reRenderFunction,
      this.spacingAttribute,
      this.paddingAttribute,
      this.placement});

  @override
  State<EditorPaddingSpacing> createState() => _EditorPaddingSpacingState();
}

class _EditorPaddingSpacingState extends State<EditorPaddingSpacing> {
  String? _selectedLabel;
  late Size _size;
  late List<String> _labelInputs;
  late Unit _unit;
  Placement? _placement;
  SpacingAttribute? _spacingAttribute;
  PaddingAttribute? _paddingAttribute;
   List<TextEditingController> controllers = [];
  @override
  void initState() {
    super.initState();
    if ([TITLE_EDIT_PLACEMENT].contains(widget.title)) {
      _labelInputs = LABELS_EDIT_PLACEMENT;
      _selectedLabel = _labelInputs[2];
    } else {
      _labelInputs = LABELS_PADDING_SPACING;
      _selectedLabel = _labelInputs[0];
    }
    _placement = widget.placement;
    _spacingAttribute = widget.spacingAttribute;
    _paddingAttribute = widget.paddingAttribute;
    _unit = (_paddingAttribute?.unit) ??
        (_spacingAttribute?.unit) ??
        (_placement?.placementAttribute?.unit) ??
        widget.unit;
    widget.inputValues.forEach((element) {
      controllers.add(TextEditingController(text: element));
    });
    controllers[0].selection = TextSelection(
        baseOffset: 0, extentOffset: controllers[0].value.text.length);
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: transparent,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(child: GestureDetector(
            onTap: () {
              for (int i = 0; i < controllers.length; i++) {
                if (controllers[i].text.trim().isEmpty) {
                  widget.onChanged(i, "0.0");
                }
              }
              popNavigator(context);
            },
          )),
          [TITLE_EDIT_PLACEMENT].contains(widget.title)
              ? _buildEditPlacementBody()
              : _buildPaddingSpacingBody(title: widget.title, height: 140),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              MediaQuery.of(context).viewInsets.bottom > 0
                  ? WUnitSelections(
                      unitValue: _unit,
                      onSelected: (value) {
                        setState(() {
                          _unit = value;
                        });
                      },
                      onDone: (newUnit) {
                        if (_placement != null) {
                          _placement = _placement?.copyWith(
                              placementAttribute: PlacementAttribute(
                                  horizontal: parseStringToDouble(
                                      controllers[0].text.trim()),
                                  vertical: parseStringToDouble(
                                    controllers[1].text.trim(),
                                  ),
                                  top: parseStringToDouble(
                                    controllers[2].text.trim(),
                                  ),
                                  left: parseStringToDouble(
                                    controllers[3].text.trim(),
                                  ),
                                  right: parseStringToDouble(
                                    controllers[4].text.trim(),
                                  ),
                                  bottom: parseStringToDouble(
                                    controllers[5].text.trim(),
                                  ),
                                  unit: newUnit));
                          widget.onDone(_placement);
                        } else if (_paddingAttribute != null) {
                          _paddingAttribute = _paddingAttribute?.copyWith(
                            horizontalPadding: parseStringToDouble(
                              controllers[0].text.trim(),
                            ),
                            verticalPadding: parseStringToDouble(
                              controllers[1].text.trim(),
                            ),
                            unit: newUnit,
                          );
                          widget.onDone(_paddingAttribute);
                        } else if (_spacingAttribute != null) {
                          _spacingAttribute = _spacingAttribute?.copyWith(
                            horizontalSpacing: parseStringToDouble(
                              controllers[0].text.trim(),
                            ),
                            verticalSpacing: parseStringToDouble(
                              controllers[1].text.trim(),
                            ),
                            unit: newUnit,
                          );
                          widget.onDone(_spacingAttribute);
                        }
                        popNavigator(context);
                      },
                    )
                  : const SizedBox(),
            ],
          ),
        ],
      ),
    );
  }

  double parseStringToDouble(String value) {
    return double.parse(value);
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
                      controllers[2],
                      (value) {
                        widget.onChanged(2, value);
                      },
                      _selectedLabel == _labelInputs[2],
                      _unit.title,
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
                            controllers[3],
                            (value) {
                              widget.onChanged(3, value);
                            },
                            _selectedLabel == _labelInputs[3],
                            _unit.title,
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
                            controllers[4],
                            (value) {
                              widget.onChanged(4, value);
                            },
                            _selectedLabel == _labelInputs[4],
                            _unit.title,
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
                      controllers[5],
                      (value) {
                        widget.onChanged(5, value);
                      },
                      _selectedLabel == _labelInputs[5],
                      _unit.title,
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
                          controllers[0],
                          (value) {
                            widget.onChanged(0, value);
                          },
                          _selectedLabel == _labelInputs[0],
                          _unit.title,
                          onTap: () {
                            setState(() {
                              _selectedLabel = _labelInputs[0];
                            });
                          },
                          isHaveSuffix: true,
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
                          controllers[1],
                          (value) {
                            widget.onChanged(1, value);
                          },
                          _selectedLabel == _labelInputs[1],
                          _unit.title,
                          onTap: () {
                            setState(() {
                              _selectedLabel = _labelInputs[1];
                            });
                          },
                          isHaveSuffix: true,
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
      void Function(String)? onChanged, bool isFocus, String suffixValue,
      {void Function()? onTap, bool? autoFocus, bool? isHaveSuffix}) {
    return Container(
        height: 35,
        alignment: Alignment.center,
        child: CupertinoTextField(
          onTap: () {
            onTap != null ? onTap() : null;
            controller.selection = TextSelection(
                baseOffset: 0, extentOffset: controller.value.text.length);
          },
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
                  child: Text(suffixValue,
                      style: const TextStyle(
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