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
  final Function(PaperAttribute paperAttribute, bool pageSizeIsPortrait)
      onApply;
  const PaperBody(
      {super.key,
      required this.project,
      required this.reRenderFunction,
      required this.indexPageSizeSelectionWidget,
      required this.paperConfig,
      required this.onApply});

  @override
  State<PaperBody> createState() => _PaperBodyState();
}
// _paperConfig = {
//       "mediaSrc": {
//         "light": "${PATH_PREFIX_ICON}icon_letter_lm.png",
//         "dark": "${PATH_PREFIX_ICON}icon_letter_dm.png"
//       },
//       "title": "Paper Size",
//       "content": _project.paper ?? LIST_PAGE_SIZE[0]
//     };

class _PaperBodyState extends State<PaperBody> {
  late Project _project;
  int? _indexPageSizeSelectionWidget;
  dynamic _paperConfig;
  final TextEditingController _paperSizeWidthController =
      TextEditingController(text: "");
  final TextEditingController _paperSizeHeightController =
      TextEditingController(text: "");
  late String _paperWidthValue = '';
  late String _paperHeightValue = '';
  late bool _pageSizeIsPortrait = true;

  @override
  void dispose() {
    super.dispose();
    _project = Project(id: 0, listMedia: []);
    _indexPageSizeSelectionWidget = null;
    _paperConfig = null;
    _paperSizeWidthController.dispose();
    _paperSizeHeightController.dispose();
  }

  @override
  void initState() {
    _project = widget.project;
    if (_project.paper == null) {
      _project = _project.copyWith(paper: LIST_PAGE_SIZE[0]);
    }
    _indexPageSizeSelectionWidget = widget.indexPageSizeSelectionWidget;
    _paperConfig = (widget.paperConfig);
    _paperSizeWidthController.text =
        _paperWidthValue = (_project.paper?.width).toString();
    _paperSizeHeightController.text =
        _paperHeightValue = (_project.paper?.height).toString();
    _pageSizeIsPortrait = _project.paper?.isPortrait ?? true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.sizeOf(context);
    const Color colorBorder = Color.fromRGBO(0, 0, 0, 0.1);
    print("_paperConfig['content'] ${_paperConfig['content'].getInfor()}");
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
                              _paperHeightValue =
                                  _paperSizeHeightController.text.trim();
                              _paperWidthValue =
                                  _paperSizeWidthController.text.trim();
                              _pageSizeIsPortrait = true;
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
                              if (_paperConfig['content'].title ==
                                  LIST_PAGE_SIZE[0].title) {
                                return;
                              }
                              if (_paperSizeWidthController.text.trim() !=
                                  _paperConfig['content'].width) {
                                setState(() {
                                  _paperConfig['content'] = LIST_PAGE_SIZE[8];
                                });
                              }
                            },
                            suffixValue: _paperConfig['content'].unit.value,
                            isFocus: _indexPageSizeSelectionWidget == 1),
                        WSpacer(
                          height: 10,
                        ),
                        // height
                        _paperConfig['content'].title == "None"
                            ? const SizedBox()
                            : buildCupertinoInput(
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
                                  if (_paperConfig['content'].title ==
                                      LIST_PAGE_SIZE[0].title) {
                                    return;
                                  }
                                  if (_paperSizeHeightController.text.trim() !=
                                      _paperConfig['content'].height) {
                                    _paperConfig['content'] = LIST_PAGE_SIZE[8];
                                  }
                                  setState(() {});
                                  widget.reRenderFunction();
                                },
                                suffixValue: _paperConfig['content'].unit.value,
                                isFocus: _indexPageSizeSelectionWidget == 2),
                        WSpacer(
                          height: 10,
                        ),
                        // orientation
                        _paperConfig['content'].title == "None"
                            ? const SizedBox()
                            : _buildOrientation(() {
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
                          SizedBox(
                            height: 150,
                            width: 150,
                            child: Center(
                              child: AnimatedContainer(
                                alignment: Alignment.topCenter,
                                duration: const Duration(milliseconds: 400),
                                constraints: const BoxConstraints(
                                    maxHeight: 150, maxWidth: 150),
                                height: _paperConfig['content'].title == "None"
                                    ? null
                                    : _getWidthAndHeight(150)[1],
                                width: _getWidthAndHeight(150)[0],
                                decoration: BoxDecoration(
                                    color: colorWhite,
                                    border:
                                        _paperConfig['content'].title != "None"
                                            ? Border.all(
                                                color: colorBorder, width: 2)
                                            : const Border(
                                                top: BorderSide(
                                                  color: colorBorder,
                                                  width: 2,
                                                ),
                                                left: BorderSide(
                                                  color: colorBorder,
                                                  width: 2,
                                                ),
                                                right: BorderSide(
                                                  color: colorBorder,
                                                  width: 2,
                                                ),
                                              )),
                                padding: const EdgeInsets.all(10),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                                alignment: Alignment.center,
                                child: WTextContent(
                                  value: _renderPreviewContent(),
                                  textSize: 14,
                                  textLineHeight: 16.04,
                                  textFontWeight: FontWeight.w600,
                                  textColor: const Color.fromRGBO(0, 0, 0, 0.5),
                                  textOverflow: TextOverflow.ellipsis,
                                )),
                          )
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
                            isPortrait: _pageSizeIsPortrait,
                            unit: _paperConfig['content'].unit),
                        _pageSizeIsPortrait);
                  }
                },
                onCancel: () {
                  popNavigator(context);
                },
              )
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
                          if (_paperConfig['content'].title ==
                              LIST_PAGE_SIZE[0].title) {
                            _paperConfig['content'] =
                                _paperConfig['content'].copyWith(
                              unit: value,
                            );
                          } else {
                            _paperConfig['content'] =
                                LIST_PAGE_SIZE[8].copyWith(
                              unit: value,
                            );
                          }
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
                        } else {
                          _paperWidthValue =
                              _paperSizeWidthController.text.trim();
                        }
                        if (heightValue.isEmpty ||
                            double.parse(heightValue) == 0.0) {
                          _paperSizeHeightController.text = "1.0";
                        } else {
                          _paperHeightValue =
                              _paperSizeHeightController.text.trim();
                        }
                        // check value is not equal and title not equal to None
                        if ((_paperHeightValue !=
                                    _paperConfig['content'].height ||
                                _paperWidthValue !=
                                    _paperConfig['content'].width) &&
                            _paperConfig['content'].title !=
                                LIST_PAGE_SIZE[0].title) {
                          _paperConfig['content'] = LIST_PAGE_SIZE[8].copyWith(
                            unit: value,
                          );
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

  String _renderPreviewContent() {
    if (_paperSizeWidthController.text.trim().isEmpty ||
        _paperSizeHeightController.text.trim().isEmpty) {
      return "--";
    }
    if (_paperConfig['content'].title == "None") {
      return "${_paperSizeWidthController.text.trim()} x -- ${_paperConfig['content'].unit.value}";
    }

    return "${_paperSizeWidthController.text.trim()} x ${_paperSizeHeightController.text.trim()} ${_paperConfig['content'].unit.value}";
  }

  List<double> _getWidthAndHeight(double maxSize) {
    double width = 150;
    double height = 150;
    double widthPaper = double.parse(_paperWidthValue);
    double heightPaper = double.parse(_paperHeightValue);
    if (heightPaper < 0) {
      return [width, -1];
    }
    if (heightPaper > widthPaper) {
      height = width * heightPaper / widthPaper;
      if (height > 150) {
        height = 150;
        width = height * widthPaper / heightPaper;
      }
    } else if (heightPaper < widthPaper) {
      width = height * widthPaper / heightPaper;
      if (width > 150) {
        width = 150;
        height = width * heightPaper / widthPaper;
      }
    }
    return [width, height];
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
    _paperHeightValue = width;
    _paperWidthValue = height;
  }

  Widget _buildOrientation(
    Function() rerenderFunc,
  ) {
    return _paperConfig['content'].title != "Custom"
        ? Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              height: 70,
              width: 200 / 390 * MediaQuery.sizeOf(context).width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context).cardColor,
              ),
              child: Flex(direction: Axis.horizontal, children: [
                Flexible(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.only(left: 5),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: WTextContent(
                        value: "Orientation",
                        textSize: 14,
                        textLineHeight: 16.71,
                        textColor:
                            Theme.of(context).textTheme.bodyMedium!.color,
                        textFontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                WSpacer(
                  width: 10,
                ),
                Flexible(
                  flex: 4,
                  child: Row(
                    children: [
                      buildPageSizeOrientationItem(
                          context: context,
                          mediaSrc: "${PATH_PREFIX_ICON}icon_portrait.png",
                          isSelected: _pageSizeIsPortrait,
                          onTap: () {
                            // thay doi offset neu co
                            setState(() {
                              if (_pageSizeIsPortrait == false) {
                                _tranferValuePageSize();
                              }
                              _pageSizeIsPortrait = true;
                            });
                            rerenderFunc();
                          },
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 6)),
                      const SizedBox(width: 10),
                      buildPageSizeOrientationItem(
                          context: context,
                          mediaSrc: "${PATH_PREFIX_ICON}icon_landscape.png",
                          isSelected: !_pageSizeIsPortrait,
                          onTap: () {
                            setState(() {
                              if (_pageSizeIsPortrait == true) {
                                _tranferValuePageSize();
                              }
                              _pageSizeIsPortrait = false;
                            });
                            rerenderFunc();
                          },
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 9)),
                    ],
                  ),
                )
              ]),
            ),
          )
        : const SizedBox();
  }
}
