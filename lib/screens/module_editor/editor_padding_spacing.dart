import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/convert.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/models/placement.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/w_input.dart';
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
  final PaperAttribute? paperAttribute;
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
      this.placement,
      this.paperAttribute});

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
    for (var element in widget.inputValues) {
      if (double.parse(element) < 0) {
        controllers.add(TextEditingController(text: "0.0"));
      } else {
        // check case -0.00
        controllers.add(TextEditingController(
            text: double.parse(element).abs().toString()));
      }
    }
    if ([TITLE_EDIT_PLACEMENT].contains(widget.title)) {
      _labelInputs = LABELS_EDIT_PLACEMENT;
      _selectedLabel = _labelInputs[2];
      controllers[2].selection = TextSelection(
          baseOffset: 0, extentOffset: controllers[2].value.text.length);
    } else {
      _labelInputs = LABELS_PADDING_SPACING;
      _selectedLabel = _labelInputs[0];
      controllers[0].selection = TextSelection(
          baseOffset: 0, extentOffset: controllers[0].value.text.length);
    }
    _placement = widget.placement;
    _spacingAttribute = widget.spacingAttribute;
    _paddingAttribute = widget.paddingAttribute;
    _unit = (_paddingAttribute?.unit) ??
        (_spacingAttribute?.unit) ??
        (_placement?.placementAttribute?.unit) ??
        widget.unit;
  }

  @override
  void dispose() {
    super.dispose();
    _selectedLabel = "";
    _labelInputs = [];
    _placement = null;
    _spacingAttribute = null;
    _paddingAttribute = null;
    controllers = [];
  }

  void _onDone(Unit newUnit) {
    if (_placement != null) {
      double newHeight, newWidth, newRight, newBottom, newTop, newLeft;
      final minSize = convertUnit(POINT, newUnit, MIN_PLACEMENT_SIZE);
      if (controllers[0].text.trim().isEmpty ||
          double.parse(controllers[0].text.trim()) == 0.0) {
        newWidth = minSize;
      } else {
        newWidth = double.parse(controllers[0].text.trim());
      }
      if (controllers[1].text.trim().isEmpty ||
          double.parse(controllers[1].text.trim()) == 0.0) {
        newHeight = minSize;
      } else {
        newHeight = double.parse(controllers[1].text.trim());
      }

      if (controllers[2].text.trim().isEmpty ||
          double.parse(controllers[2].text.trim()) == 0.0) {
        newTop = minSize;
      } else {
        newTop = parseStringToDouble(controllers[2].text.trim());
      }
      if (controllers[3].text.trim().isEmpty ||
          double.parse(controllers[3].text.trim()) == 0.0) {
        newLeft = minSize;
      } else {
        newLeft = parseStringToDouble(controllers[3].text.trim());
      }
      if (controllers[4].text.trim().isEmpty ||
          double.parse(controllers[4].text.trim()) == 0.0) {
        newRight = minSize;
      } else {
        newRight = parseStringToDouble(controllers[4].text.trim());
      }
      if (controllers[5].text.trim().isEmpty ||
          double.parse(controllers[5].text.trim()) == 0.0) {
        newBottom = minSize;
      } else {
        newBottom = parseStringToDouble(controllers[5].text.trim());
      }

      // truong hop height hoac width = 0
      if (controllers[1].text.trim().isEmpty ||
          parseStringToDouble(controllers[1].text.trim()) <= 0) {
        newHeight = minSize;
        newBottom = widget.paperAttribute!.height -
            newHeight -
            (double.parse(controllers[2].text.trim()));
      }
      if (controllers[0].text.trim().isEmpty ||
          parseStringToDouble(controllers[0].text.trim()) <= 0) {
        newWidth = minSize;
        newRight = widget.paperAttribute!.width -
            newWidth -
            (double.parse(controllers[3].text.trim()));
      }

      newTop = max(0,
          min(newTop, widget.paperAttribute!.height - (newBottom + minSize)));
      newLeft = max(
          0, min(newLeft, widget.paperAttribute!.width - (newRight + minSize)));
      newBottom = max(0,
          min(newBottom, widget.paperAttribute!.height - (newTop + minSize)));
      newRight = max(
          0, min(newRight, widget.paperAttribute!.width - (newLeft + minSize)));

      _placement = _placement?.copyWith(
          ratioHeight: newHeight / widget.paperAttribute!.height,
          ratioWidth: newWidth / widget.paperAttribute!.width,
          placementAttribute: PlacementAttribute(
              top: parseStringToDouble(newTop.toStringAsFixed(2)),
              left: parseStringToDouble(newLeft.toStringAsFixed(2)),
              right: parseStringToDouble(newRight.toStringAsFixed(2)),
              bottom: parseStringToDouble(newBottom.toStringAsFixed(2)),
              unit: newUnit));
      widget.onDone(_placement);
    } else if (_paddingAttribute != null) {
      final horValue = parseStringToDouble(
        controllers[0].text.trim(),
      );
      final verValue = parseStringToDouble(
        controllers[0].text.trim(),
      );
      _paddingAttribute = _paddingAttribute?.copyWith(
        horizontalPadding: horValue > 0 ? horValue : 0,
        verticalPadding: verValue > 0 ? verValue : 0,
        unit: newUnit,
      );
      widget.onDone(_paddingAttribute);
    } else if (_spacingAttribute != null) {
      final horValue = parseStringToDouble(
        controllers[0].text.trim(),
      );
      final verValue = parseStringToDouble(
        controllers[0].text.trim(),
      );
      _spacingAttribute = _spacingAttribute?.copyWith(
        horizontalSpacing: horValue > 0 ? horValue : 0,
        verticalSpacing: verValue > 0 ? verValue : 0,
        unit: newUnit,
      );
      widget.onDone(_spacingAttribute);
    }
    popNavigator(context);
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.sizeOf(context);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.1),
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
                : _buildPaddingSpacingBody(LABELS_PADDING_SPACING,
                    title: widget.title, height: 140),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                MediaQuery.of(context).viewInsets.bottom > 0
                    ? WUnitSelections(
                        unitValue: _unit,
                        onSelected: (value) {
                          List<TextEditingController> newControllers = [];
                          newControllers = controllers.map(
                            (element) {
                              return TextEditingController(
                                  text: convertUnit(
                                          _unit,
                                          value,
                                          double.parse(
                                              element.text.trim().isEmpty
                                                  ? "0.0"
                                                  : element.text.trim()))
                                      .toStringAsFixed(2));
                            },
                          ).toList();
                          setState(() {
                            _unit = value;
                            controllers = newControllers;
                          });
                        },
                        onDone: (newUnit) {
                          _onDone(newUnit);
                        },
                      )
                    : const SizedBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double parseStringToDouble(String value) {
    if (value == "" || value.isEmpty) {
      return 0.0;
    }
    return double.parse(value);
  }

  Widget _buildEditPlacementBody() {
    print("controllers[0] ${controllers[0].text}");
    return Center(
      child: Container(
        height: _size.width * 0.8,
        padding: const EdgeInsets.all(10),
        alignment: Alignment.center,
        width: _size.width * 0.9,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).dialogTheme.backgroundColor),
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
                // top
                SizedBox(
                  child: WInputLayout(
                      width: _size.width * 0.27,
                      controller: controllers[2],
                      unit: _unit,
                      onChanged: (value) {
                        widget.onChanged(2, value);
                        controllers[2].text = value;
                        setState(() {});
                      },
                      isFocus: _selectedLabel == _labelInputs[2],
                      onSubmitted: () {
                        _onDone(_unit);
                      },
                      suffixValue: _unit.title,
                      onTap: () {
                        setState(() {
                          _selectedLabel = _labelInputs[2];
                        });
                      },
                      isHaveSuffix: true,
                      autoFocus: true),
                ),
                // left and right
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        child: WInputLayout(
                          width: _size.width * 0.27,
                          controller: controllers[3],
                          onChanged: (value) {
                            widget.onChanged(3, value);
                            controllers[3].text = value;
                            setState(() {});
                          },
                          unit: _unit,
                          isFocus: _selectedLabel == _labelInputs[3],
                          suffixValue: _unit.title,
                          onTap: () {
                            setState(() {
                              _selectedLabel = _labelInputs[3];
                            });
                          },
                          onSubmitted: () {
                            _onDone(_unit);
                          },
                          isHaveSuffix: true,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 15),
                        child: Image.asset(
                          "${PATH_PREFIX_ICON}icon_placement_center.png",
                          height: 80,
                          width: 80,
                          scale: 3,
                        ),
                      ),
                      SizedBox(
                        child: WInputLayout(
                            width: _size.width * 0.27,
                            controller: controllers[4],
                            onChanged: (value) {
                              widget.onChanged(4, value);
                              controllers[4].text = value;
                              setState(() {});
                            },
                            unit: _unit,
                            isFocus: _selectedLabel == _labelInputs[4],
                            onSubmitted: () {
                              _onDone(_unit);
                            },
                            suffixValue: _unit.title,
                            onTap: () {
                              setState(() {
                                _selectedLabel = _labelInputs[4];
                              });
                            },
                            isHaveSuffix: true,
                            autoFocus: false),
                      ),
                    ],
                  ),
                ),
                // bottom
                SizedBox(
                  child: WInputLayout(
                      width: _size.width * 0.27,
                      controller: controllers[5],
                      unit: _unit,
                      onChanged: (value) {
                        widget.onChanged(5, value);
                        controllers[5].text = value;
                        setState(() {});
                      },
                      isFocus: _selectedLabel == _labelInputs[5],
                      suffixValue: _unit.title,
                      onSubmitted: () {
                        _onDone(_unit);
                      },
                      onTap: () {
                        setState(() {
                          _selectedLabel = _labelInputs[5];
                        });
                      },
                      isHaveSuffix: true,
                      autoFocus: false),
                ),
              ],
            ),
            _buildPaddingSpacingBody(LABELS_EDIT_PLACEMENT.sublist(0, 2),
                padding: EdgeInsets.zero, haveBackgroundColor: false)
          ],
        ),
      ),
    );
  }

  Widget _buildPaddingSpacingBody(List<String> subTitles,
      {double? height,
      EdgeInsets? padding = const EdgeInsets.all(10),
      String? title,
      bool? haveBackgroundColor = true}) {
    return Center(
      child: Container(
        height: height,
        padding: padding,
        alignment: Alignment.center,
        width: _size.width * 0.9,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: haveBackgroundColor!
                ? Theme.of(context).dialogTheme.backgroundColor
                : null),
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
                      child: WInputLayout(
                          width: _size.width * 0.45,
                          controller: controllers[0],
                          unit: _unit,
                          onChanged: (value) {
                            widget.onChanged(0, value);
                            controllers[0].text = value;
                            if ([TITLE_EDIT_PLACEMENT].contains(widget.title) &&
                                widget.paperAttribute != null) {
                              double newValue =
                                  value.isNotEmpty ? double.parse(value) : 0.0;
                              double bindingValue = widget
                                      .paperAttribute!.width -
                                  newValue -
                                  (double.parse(controllers[3].text.trim()));
                              if (bindingValue >= 0) {
                                widget.onChanged(4, bindingValue.toString());
                                controllers[4].text = bindingValue.toString();
                              } else {
                                widget.onChanged(4, "0.0");
                                controllers[4].text = '0.0';
                              }
                            }

                            setState(() {});
                          },
                          isFocus: _selectedLabel == _labelInputs[0],
                          onSubmitted: () {
                            _onDone(_unit);
                          },
                          suffixValue: _unit.title,
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
                      value: subTitles[0],
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
                      child: WInputLayout(
                          width: _size.width * 0.45,
                          controller: controllers[1],
                          unit: _unit,
                          onChanged: (value) {
                            widget.onChanged(1, value);
                            controllers[1].text = value;
                            if ([TITLE_EDIT_PLACEMENT].contains(widget.title) &&
                                widget.paperAttribute != null) {
                              double newValue =
                                  value.isNotEmpty ? double.parse(value) : 0.0;
                              double bindingValue = widget
                                      .paperAttribute!.height -
                                  newValue -
                                  (double.parse(controllers[2].text.trim()));
                              if (bindingValue >= 0) {
                                widget.onChanged(5, bindingValue.toString());
                                controllers[5].text = bindingValue.toString();
                              } else {
                                widget.onChanged(5, "0.0");
                                controllers[5].text = '0.0';
                              }
                            }
                            setState(() {});
                          },
                          isFocus: _selectedLabel == _labelInputs[1],
                          suffixValue: _unit.title,
                          onSubmitted: () {
                            _onDone(_unit);
                          },
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
                      value: subTitles[1],
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
}
