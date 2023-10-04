import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/w_editor.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import 'package:photo_to_pdf/widgets/w_unit_selections.dart';

class PaperBody extends StatefulWidget {
  final Project project;
  final Function() reRenderFunction;
  final int? indexPageSizeSelectionWidget;
  final dynamic paperConfig;
  // final List<String> values;
  final bool pageSizeIsPortrait;
  final Function(PaperAttribute paperAttribute, bool pageSizeIsPortrait) onApply;
  const PaperBody(
      {super.key,
      required this.project,
      required this.reRenderFunction,
      required this.indexPageSizeSelectionWidget,
      required this.paperConfig,
      // required this.values,
      required this.pageSizeIsPortrait,
      required this.onApply});

  @override
  State<PaperBody> createState() => _PaperBodyState();
}

class _PaperBodyState extends State<PaperBody> {
  late Project _project;
  int? _indexPageSizeSelectionWidget;
  dynamic _paperConfig;
  final TextEditingController _paperSizeWidthController =
      TextEditingController(text: "");
  final TextEditingController _paperSizeHeightController =
      TextEditingController(text: "");
  late bool _pageSizeIsPortrait = true;
  @override
  void initState() {
    _project = widget.project;
    if (_project.paper == null) {
      _project = _project.copyWith(paper: LIST_PAGE_SIZE[5]);
    }
    _indexPageSizeSelectionWidget = widget.indexPageSizeSelectionWidget;
    _paperConfig = widget.paperConfig;
    _paperSizeWidthController.text = (_project.paper?.width).toString();
    _paperSizeHeightController.text = (_project.paper?.height).toString();
    _pageSizeIsPortrait = widget.pageSizeIsPortrait;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.sizeOf(context);
    return Container(
      height: _size.height * 0.55,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: WTextContent(
                  value: "Paper Size",
                  textSize: 16,
                  textLineHeight: 19.09,
                  textFontWeight: FontWeight.w600,
                  textColor: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
              Expanded(
                  child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // page size selections
                  Container(
                    padding: const EdgeInsets.only(left: 10, top: 20),
                    child: Column(
                      children: [
                        // preset
                        buildPageSizePreset(
                          context: context,
                          item: _paperConfig,
                          onTap: () {
                            setState(() {
                              _indexPageSizeSelectionWidget = 0;
                            });
                            widget.reRenderFunction();
                          },
                          isFocus: _indexPageSizeSelectionWidget == 0,
                          onSelected: (value) {
                            setState(() {
                              _paperConfig['content'] = value;
                              _paperSizeWidthController.text =
                                  (_paperConfig['content'].width).toString();
                              _paperSizeHeightController.text =
                                  (_paperConfig['content'].height).toString();
                            });
                            widget.reRenderFunction();
                          },
                        ),
                        WSpacer(
                          height: 10,
                        ),
                        // width
                        buildCupertinoInput(
                            context: context,
                            controller: _paperSizeWidthController,
                            title: "Width",
                            placeholder: "",
                            onTap: () {
                              setState(() {
                                _indexPageSizeSelectionWidget = 1;
                              });
                              widget.reRenderFunction();
                            },
                            onChanged: (value) {
                              _paperSizeWidthController.text = value;
                              if (_paperSizeWidthController.text.trim() !=
                                  _paperConfig['content'].width) {
                                setState(() {
                                  _paperConfig['content'] = LIST_PAGE_SIZE[7];
                                });
                              }
                              setState(() {});
                            },
                            suffixValue: _paperConfig['content'].unit.value,
                            isFocus: _indexPageSizeSelectionWidget == 1),
                        WSpacer(
                          height: 10,
                        ),
                        // height
                        buildCupertinoInput(
                            context: context,
                            controller: _paperSizeHeightController,
                            title: "Height",
                            placeholder: "",
                            onTap: () {
                              setState(() {
                                _indexPageSizeSelectionWidget = 2;
                              });
                              widget.reRenderFunction();
                            },
                            onChanged: (value) {
                              _paperSizeHeightController.text = value;
                              if (_paperSizeHeightController.text.trim() !=
                                  _paperConfig['content'].height) {
                                _paperConfig['content'] = LIST_PAGE_SIZE[7];
                              }
                              setState(() {});
                            },
                            suffixValue: _paperConfig['content'].unit.value,
                            isFocus: _indexPageSizeSelectionWidget == 2),
                        WSpacer(
                          height: 10,
                        ),
                        // orientation
                        // _overWHValue() ||

                        _buildOrientation(() {
                          widget.reRenderFunction();
                        })
                      ],
                    ),
                  ),
                  // page size preview
                  Expanded(
                    child: Container(
                      padding:
                          const EdgeInsets.only(right: 20, left: 20, top: 20),
                      alignment: Alignment.topCenter,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          AnimatedContainer(
                            alignment: Alignment.topCenter,
                            duration: const Duration(milliseconds: 400),
                            constraints: const BoxConstraints(
                                maxHeight: 150, maxWidth: 150),
                            height: _renderPreviewHeight(),
                            width: _renderPreviewWidth(),
                            decoration: BoxDecoration(
                                color: colorWhite,
                                border: _overWHValue()
                                    ? null
                                    : Border.all(
                                        color:
                                            const Color.fromRGBO(0, 0, 0, 0.1),
                                        width: 2)),
                            padding: const EdgeInsets.all(10),
                          ),
                          !_overWHValue()
                              ? Positioned.fill(
                                  child: Container(
                                      alignment: Alignment.center,
                                      child: WTextContent(
                                        value: _renderPreviewContent(),
                                        textSize: 16,
                                        textLineHeight: 19.09,
                                        textFontWeight: FontWeight.w600,
                                        textColor:
                                            const Color.fromRGBO(0, 0, 0, 0.5),
                                        textOverflow: TextOverflow.ellipsis,
                                      )),
                                )
                              : Container(
                                  alignment: Alignment.topCenter,
                                  child: WTextContent(
                                    value: _renderPreviewContent(),
                                    textSize: 16,
                                    textLineHeight: 19.09,
                                    textFontWeight: FontWeight.w600,
                                    textColor:
                                        const Color.fromRGBO(0, 0, 0, 0.5),
                                    textOverflow: TextOverflow.ellipsis,
                                  ))
                        ],
                      ),
                    ),
                  )
                ],
              )),
              buildBottomButton(
                  context: context,
                  onApply: () {
                    final widthValue = _paperSizeWidthController.text.trim();
                    final heightValue = _paperSizeHeightController.text.trim();
                    if (widthValue.isEmpty ||
                        double.parse(widthValue) == 0.0 ||
                        heightValue.isEmpty ||
                        double.parse(heightValue) == 0.0) {
                      widget.onApply(
                          widget.paperConfig['content'], _pageSizeIsPortrait);
                    } else {
                      widget.onApply(
                          PaperAttribute(
                              title: _paperConfig['content'].title,
                              width: double.parse(widthValue),
                              height: double.parse(heightValue),
                              unit: _paperConfig['content'].unit),
                          _pageSizeIsPortrait);
                    }
                  },onCancel: () {
                    popNavigator(context);
                  },)
            ],
          ),
          MediaQuery.of(context).viewInsets.bottom > 0.0
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    WUnitSelections(
                      unitValue: _paperConfig['content'].unit,
                      onSelected: (value) {
                        setState(() {
                          _paperConfig['content'] =
                              LIST_PAGE_SIZE[7].copyWith(unit: value);
                        });
                        widget.reRenderFunction();
                      },
                      onDone: (value) {
                        FocusManager.instance.primaryFocus!.unfocus();
                        final widthValue =
                            _paperSizeWidthController.text.trim();
                        final heightValue =
                            _paperSizeHeightController.text.trim();
                        if (widthValue.isEmpty ||
                            double.parse(widthValue) == 0.0) {
                          _paperSizeWidthController.text = "1.0";
                        }
                        if (heightValue.isEmpty ||
                            double.parse(heightValue) == 0.0) {
                          _paperSizeHeightController.text = "1.0";
                        }

                        setState(() {});
                        widget.reRenderFunction();
                      },
                    )
                  ],
                )
              : const SizedBox()
        ],
      ),
    );
  }

  bool _overWHValue() {
    if (_paperSizeWidthController.text.trim().isEmpty ||
        _paperSizeHeightController.text.trim().isEmpty) {
      return true;
    }
    return ((double.parse(_paperSizeHeightController.text.trim()) > 50.0) ||
        (double.parse(_paperSizeWidthController.text.trim()) > 50.0));
  }

  String _renderPreviewContent() {
    if (_paperSizeWidthController.text.trim().isEmpty ||
        _paperSizeHeightController.text.trim().isEmpty) {
      return "--";
    }
    return "${_paperSizeWidthController.text.trim()}x${_paperSizeHeightController.text.trim()} ${_paperConfig['content'].unit.value}";
  }

  double _renderPreviewHeight() {
    if (_overWHValue()) {
      return 0;
    }
    return (_pageSizeIsPortrait ? 220 : 170) *
        double.parse(_paperSizeHeightController.text.trim()) /
        double.parse(_paperSizeWidthController.text.trim());
  }

  double _renderPreviewWidth() {
    if (_overWHValue()) {
      return 0;
    }
    return (_pageSizeIsPortrait ? 170 : 220) *
        double.parse(_paperSizeWidthController.text.trim()) /
        double.parse(_paperSizeHeightController.text.trim());
  }

  _tranferValuePageSize() {
    PaperAttribute config = _paperConfig["content"];
    _paperConfig["content"] = _paperConfig['content'].copyWith(
        title: config.title,
        height: config.height,
        width: config.width,
        unit: config.unit);

    final width = _paperSizeWidthController.text;
    final height = _paperSizeHeightController.text;
    _paperSizeHeightController.text = width;
    _paperSizeWidthController.text = height;
  }

  Widget _buildOrientation(
    Function() rerenderFunc,
  ) {
    return _paperConfig['content'].title != "Custom" && !_overWHValue()
        ? Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 70,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context).cardColor,
              ),
              child: Row(children: [
                Container(
                  constraints: const BoxConstraints(minWidth: 50, maxWidth: 70),
                  padding: const EdgeInsets.only(left: 5),
                  child: WTextContent(
                    value: "Orientation",
                    textSize: 14,
                    textLineHeight: 16.71,
                    textColor: Theme.of(context).textTheme.bodyMedium!.color,
                    textFontWeight: FontWeight.w600,
                  ),
                ),
                WSpacer(
                  width: 10,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildPageSizeOrientationItem(
                          mediaSrc: "${pathPrefixIcon}icon_portrait.png",
                          isSelected: _pageSizeIsPortrait,
                          onTap: () {
                            setState(() {
                              if (_pageSizeIsPortrait == false) {
                                _tranferValuePageSize();
                              }
                              _pageSizeIsPortrait = true;
                            });
                            rerenderFunc();
                          }),
                      buildPageSizeOrientationItem(
                          mediaSrc: "${pathPrefixIcon}icon_landscape.png",
                          isSelected: !_pageSizeIsPortrait,
                          onTap: () {
                            setState(() {
                              if (_pageSizeIsPortrait == true) {
                                _tranferValuePageSize();
                              }
                              _pageSizeIsPortrait = false;
                            });
                            rerenderFunc();
                          }),
                    ],
                  ),
                )
              ]),
            ),
          )
        : SizedBox();
  }
}