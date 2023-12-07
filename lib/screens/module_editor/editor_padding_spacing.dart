import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  String _oldValue = '';

  @override
  void initState() {
    super.initState();
    for (var element in widget.inputValues) {
      if (double.parse(element) < 0) {
        controllers.add(TextEditingController(text: "0.000"));
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
      _oldValue = controllers[2].text.trim();
    } else {
      _labelInputs = LABELS_PADDING_SPACING;
      _selectedLabel = _labelInputs[0];
      controllers[0].selection = TextSelection(
          baseOffset: 0, extentOffset: controllers[0].value.text.length);
      _oldValue = controllers[0].text.trim();
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
      _checkMinAndMaxValue();
      _placement = _placement?.copyWith(
          ratioHeight: convertStringToDouble(controllers[1].text.trim()) /
              widget.paperAttribute!.height,
          ratioWidth: convertStringToDouble(controllers[0].text.trim()) /
              widget.paperAttribute!.width,
          placementAttribute: PlacementAttribute(
              top: convertStringToDouble(controllers[2].text.trim()),
              left: convertStringToDouble(controllers[3].text.trim()),
              right: convertStringToDouble(controllers[4].text.trim()),
              bottom: convertStringToDouble(controllers[5].text.trim()),
              unit: newUnit));
      widget.onDone(_placement);
    } else if (_paddingAttribute != null) {
      final horValue = convertStringToDouble(
        controllers[0].text.trim(),
      );
      final verValue = convertStringToDouble(
        controllers[1].text.trim(),
      );
      _paddingAttribute = _paddingAttribute?.copyWith(
        horizontalPadding: horValue > 0 ? horValue : 0,
        verticalPadding: verValue > 0 ? verValue : 0,
        unit: newUnit,
      );
      widget.onDone(_paddingAttribute);
    } else if (_spacingAttribute != null) {
      final horValue = convertStringToDouble(
        controllers[0].text.trim(),
      );
      final verValue = convertStringToDouble(
        controllers[1].text.trim(),
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

  void _checkMinAndMaxValue() {
    if (_placement != null) {
      final minSize = convertUnit(POINT, _unit, MIN_PLACEMENT_SIZE);
      final maxHeight = convertUnit(
          widget.paperAttribute!.unit!, _unit, widget.paperAttribute!.height);
      final maxWidth = convertUnit(
          widget.paperAttribute!.unit!, _unit, widget.paperAttribute!.width);

      String vWidth = controllers[0].text.trim();
      String vHeight = controllers[1].text.trim();
      String vTop = controllers[2].text.trim();
      String vLeft = controllers[3].text.trim();
      String vRight = controllers[4].text.trim();
      String vBottom = controllers[5].text.trim();

      double width = convertStringToDouble(vWidth);
      double height = convertStringToDouble(vHeight);
      double top = convertStringToDouble(vTop);
      double left = convertStringToDouble(vLeft);
      double right = convertStringToDouble(vRight);
      double bottom = convertStringToDouble(vBottom);

      String vNewWidth = vWidth;
      String vNewHeight = vHeight;
      String vNewTop = vTop;
      String vNewLeft = vLeft;
      String vNewRight = vRight;
      String vNewBottom = vBottom;

      switch (_selectedLabel) {
        case "Width":
          if (vWidth.isEmpty || vWidth == '' || width < minSize) {
            vNewRight = (maxWidth - left - minSize).toStringAsFixed(3);
            vNewWidth = minSize.toStringAsFixed(3);
          } else if (width + left > maxWidth) {
            vNewWidth = _oldValue;
          } else {
            vNewRight = (maxWidth - left - width).toStringAsFixed(3);
          }
          break;
        case "Height":
          if (vHeight.isEmpty || vHeight == '' || height < minSize) {
            vNewBottom = (maxHeight - top - minSize).toStringAsFixed(3);
            vNewHeight = minSize.toStringAsFixed(3);
          } else if (height + top > maxHeight) {
            vNewHeight = _oldValue;
          } else {
            vNewBottom = (maxHeight - top - height).toStringAsFixed(3);
          }
          break;
        case "Top":
        // truong hop rong -> set 0.0, thay doi height
          if (vTop.isEmpty || vTop == '') {
            vNewTop = '0.0';
            vNewHeight = (maxHeight - bottom).toStringAsFixed(3);
          } else if (top > maxHeight - bottom - minSize) {
            // truong hop top qua lon ( lon hon bottom (present)+ min size (placement))
            vNewTop = _oldValue;
          } else {
            vNewTop = vTop;
            // truong hop top + height < max -> set lai bottom, height giu nguyen
            if (top + height <= maxHeight) {
              vNewBottom = (maxHeight - height - top).toStringAsFixed(3);
            } else {
              // truong hop top top + height > max -> set gia tri ban dau, height giu nguyen
              vNewTop = _oldValue;
            }
          }
          break;
        case "Left":
          if (vLeft.isEmpty || vLeft == '') {
            vNewLeft = '0.0';
            vNewWidth = (maxWidth - right).toStringAsFixed(3);
          } else if (left > maxWidth - right - minSize) {
            vNewLeft = _oldValue;
          } else {
            vNewLeft = vLeft;
            if (left + width <= maxWidth) {
              vNewRight = (maxWidth - left - width).toStringAsFixed(3);
            } else {
              vNewLeft = _oldValue;
            }
          }

          break;
        case "Right":
          if (vRight.isEmpty || vRight == '') {
            vNewRight = '0.0';
            vNewWidth = (maxWidth - left).toStringAsFixed(3);
          } else if (right > maxWidth - left - minSize) {
            vNewRight = _oldValue;
          } else {
            vNewRight = vRight;
            if (width + right <= maxWidth) {
              vNewLeft = (maxWidth - width - right).toStringAsFixed(3);
            } else {
              vNewRight = _oldValue;
            }
          }

          break;
        case "Bottom":
          if (vBottom.isEmpty || vBottom == '') {
            vNewBottom = '0.0';
            vNewHeight = (maxHeight - top).toStringAsFixed(3);
          } else if (bottom > maxHeight - top - minSize) {
            vNewBottom = _oldValue;
          } else {
            vNewBottom = vBottom;
            if (bottom + height <= maxHeight) {
              vNewTop = (maxHeight - bottom - height).toStringAsFixed(3);
            } else {
              vNewBottom = _oldValue;
            }
          }
          break;
        default:
          break;
      }
      controllers[0].text = vNewWidth;
      controllers[1].text = vNewHeight;
      controllers[2].text = vNewTop;
      controllers[3].text = vNewLeft;
      controllers[4].text = vNewRight;
      controllers[5].text = vNewBottom;
    }
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
                                                  ? "0.000"
                                                  : element.text.trim()))
                                      .toStringAsFixed(3));
                            },
                          ).toList();
                          final newOldValue =
                              convertUnit(_unit, value, double.parse(_oldValue))
                                  .toStringAsFixed(3);
                          setState(() {
                            _unit = value;
                            _oldValue = newOldValue;
                            controllers = newControllers;
                          });
                        },
                        onDone: (newUnit) {
                          print("_size.width * 0.8, ${_size.width * 0.8}");
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

  Widget _buildEditPlacementBody() {
    return Center(
      child: Container(
        height: 320,
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
                WInputLayout(
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
                    suffixValue: _unit.value,
                    onTap: () {
                      _checkMinAndMaxValue();
                      setState(() {
                        if (_selectedLabel != _labelInputs[2]) {
                          _oldValue = controllers[2].text.trim();
                        }
                        _selectedLabel = _labelInputs[2];
                      });
                    },
                    isHaveSuffix: true,
                    autoFocus: true),
                // left and right
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      WInputLayout(
                        width: _size.width * 0.27,
                        controller: controllers[3],
                        onChanged: (value) {
                          widget.onChanged(3, value);
                          controllers[3].text = value;
                          setState(() {});
                        },
                        unit: _unit,
                        isFocus: _selectedLabel == _labelInputs[3],
                        suffixValue: _unit.value,
                        onTap: () {
                          _checkMinAndMaxValue();
                          setState(() {
                            if (_selectedLabel != _labelInputs[3]) {
                              _oldValue = controllers[3].text.trim();
                            }
                            _selectedLabel = _labelInputs[3];
                          });
                        },
                        onSubmitted: () {
                          _onDone(_unit);
                        },
                        isHaveSuffix: true,
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
                            suffixValue: _unit.value,
                            onTap: () {
                              _checkMinAndMaxValue();
                              setState(() {
                                if (_selectedLabel != _labelInputs[4]) {
                                  _oldValue = controllers[4].text.trim();
                                }
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
                      suffixValue: _unit.value,
                      onSubmitted: () {
                        _onDone(_unit);
                      },
                      onTap: () {
                        _checkMinAndMaxValue();
                        setState(() {
                          if (_selectedLabel != _labelInputs[5]) {
                            _oldValue = controllers[5].text.trim();
                          }
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
                            setState(() {});
                          },
                          isFocus: _selectedLabel == _labelInputs[0],
                          onSubmitted: () {
                            _onDone(_unit);
                          },
                          suffixValue: _unit.value,
                          onTap: () {
                            if ([TITLE_EDIT_PLACEMENT].contains(widget.title) &&
                                widget.paperAttribute != null) {
                              _checkMinAndMaxValue();
                            }
                            setState(() {
                              if (_selectedLabel != _labelInputs[0]) {
                                _oldValue = controllers[0].text.trim();
                              }
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
                            setState(() {});
                          },
                          isFocus: _selectedLabel == _labelInputs[1],
                          suffixValue: _unit.value,
                          onSubmitted: () {
                            _onDone(_unit);
                          },
                          onTap: () {
                            if ([TITLE_EDIT_PLACEMENT].contains(widget.title) &&
                                widget.paperAttribute != null) {
                              _checkMinAndMaxValue();
                              if (_selectedLabel != _labelInputs[1]) {
                                _oldValue = controllers[1].text.trim();
                              }
                            }
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
