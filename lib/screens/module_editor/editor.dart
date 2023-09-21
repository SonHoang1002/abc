import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as flutter_riverpod;
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/providers/project_provider.dart';
import 'package:photo_to_pdf/screens/module_editor/widgets/w_editor.dart';
import 'package:photo_to_pdf/widgets/w_button.dart';
import 'package:photo_to_pdf/widgets/w_divider.dart';
import 'package:photo_to_pdf/widgets/w_project_item.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class Editor extends flutter_riverpod.ConsumerStatefulWidget {
  const Editor({
    super.key,
  });

  @override
  flutter_riverpod.ConsumerState<Editor> createState() => _EditorState();
}

class _EditorState extends flutter_riverpod.ConsumerState<Editor> {
  final TextEditingController _fileNameController =
      TextEditingController(text: "");
  final TextEditingController _pageSizeWidthController =
      TextEditingController(text: "");
  final TextEditingController _pageSizeHeightController =
      TextEditingController(text: "");

  late List _listProject;
  late Size _size;
  late bool _pageSizeIsPortrait = true;
  FocusNode _widthFocusNode = FocusNode();
  FocusNode _heightFocusNode = FocusNode();
  FocusNode _presetFocusNode = FocusNode();
  int? _indexPageSizeSelectionWidget;

  late dynamic _pageConfig;
  late dynamic _layoutConfig;
  late dynamic _photosConfig;
  late dynamic _coverConfig;
  int? _segmentCurrentIndex;
  late List _listLayoutStatus;

  // layout config keys
  final GlobalKey _keyResizeMode = GlobalKey();
  final GlobalKey _keyAlignment = GlobalKey();
  final GlobalKey _keyBackground = GlobalKey();
  final GlobalKey _keyPadding = GlobalKey();
  final GlobalKey _keySpacing = GlobalKey();

  // layout alignment variables
  late List<dynamic> _listAlignment;

  //layout padding variables
  late dynamic _paddingOptions;

  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration.zero, () {
    _pageConfig = {
      "mediaSrc": "${pathPrefixIcon}icon_letter.png",
      "title": "Paper Size",
      "content": LIST_PAGE_SIZE[5]
    };
    _layoutConfig = {
      "mediaSrc": "${pathPrefixIcon}icon_layout.png",
      "title": "Layout",
      "content": "Layout 1"
    };
    _photosConfig = {
      "mediaSrc": "${pathPrefixIcon}icon_frame.png",
      "title": "Selected Photos",
      "content": "13 Photos"
    };
    _coverConfig = {
      "mediaSrc": "${pathPrefixIcon}icon_frame_1.png",
      "title": "Cover Photos",
      "content": "None"
    };
    _listProject = ref.read(projectControllerProvider).listProject;
    // });

    _pageSizeWidthController.text =
        (_pageConfig['content']['width']).toString();
    _pageSizeHeightController.text =
        (_pageConfig['content']['height']).toString();

    _widthFocusNode.addListener(() {
      if (_widthFocusNode.hasFocus) {
        setState(() {
          _indexPageSizeSelectionWidget = 1;
        });
      }
    });
    _heightFocusNode.addListener(() {
      if (_heightFocusNode.hasFocus) {
        setState(() {
          _indexPageSizeSelectionWidget = 2;
        });
      }
    });
    _presetFocusNode.addListener(() {
      if (_presetFocusNode.hasFocus) {
        setState(() {
          _indexPageSizeSelectionWidget = 0;
        });
      }
    });
    _segmentCurrentIndex = 0;
    _listLayoutStatus = LIST_LAYOUT.map((e) {
      return {"mediaSrc": e, "isFocus": false};
    }).toList();
    _listLayoutStatus[0]['isFocus'] = true;

    _listAlignment = LIST_ALIGNMENT.map((e) {
      return {"mediaSrc": e['mediaSrc'], "title": e['title'], "isFocus": false};
    }).toList();
    _listAlignment[2]['isFocus'] = true;

    _paddingOptions = PADDING_OPTIONS;
  }

  _tranferValuePageSize() {
    final config = _pageConfig["content"];
    _pageConfig["content"] = {
      "title": config['title'],
      "width": config['height'],
      "height": config['width'],
      "unit": config['unit']
    };
    final width = _pageSizeWidthController.text;
    final height = _pageSizeHeightController.text;
    _pageSizeHeightController.text = width;
    _pageSizeWidthController.text = height;
  }

  bool _overWHValue() {
    return (double.parse(_pageSizeHeightController.text.trim()) > 50.0 ||
        double.parse(_pageSizeWidthController.text.trim()) > 50.0);
  }

  double _renderPreviewHeight() {
    if (_overWHValue()) {
      return 0;
    }
    return (_pageSizeIsPortrait ? 220 : 170) *
        double.parse(_pageSizeHeightController.text.trim()) /
        double.parse(_pageSizeWidthController.text.trim());
  }

  double _renderPreviewWidth() {
    if (_overWHValue()) {
      return 0;
    }
    return (_pageSizeIsPortrait ? 170 : 220) *
        double.parse(_pageSizeWidthController.text.trim()) /
        double.parse(_pageSizeHeightController.text.trim());
  }

  void _resetLayoutSelections() {
    _listLayoutStatus = _listLayoutStatus = LIST_LAYOUT.map((e) {
      return {"mediaSrc": e, "isFocus": false};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.sizeOf(context);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //input
                buildFileNameInput(context, _fileNameController),
                //
                WSpacer(
                  height: 10,
                ),
                // list image
                Expanded(
                    child: Container(
                  width: _size.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromRGBO(0, 0, 0, 0.03),
                  ),
                  child: ReorderableGridView.count(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    shrinkWrap: true,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 2,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        final tempListProject = _listProject;
                        final element = tempListProject.removeAt(oldIndex);
                        tempListProject.insert(newIndex, element);
                        setState(() {
                          _listProject = tempListProject;
                        });
                      });
                    },
                    onDragStart: (dragIndex) {},
                    children: _listProject.map((e) {
                      final index = _listProject.indexOf(e);
                      return WProjectItemEditor(
                        key: ValueKey(_listProject[index]),
                        src: _listProject[index],
                        isFocusByLongPress: false,
                        index: index,
                        title: "Page ${index + 1}",
                      );
                    }).toList(),
                  ),
                )),
                //
                SizedBox(
                  height: _size.height * 0.4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(children: [
                        WSpacer(height: 10),
                        // information
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            WTextContent(
                              value: "${_listProject.length} Pages",
                              textColor: const Color.fromRGBO(0, 0, 0, 0.5),
                              textLineHeight: 14.32,
                              textSize: 12,
                              textFontWeight: FontWeight.w600,
                            ),
                            WDivider(
                                width: 2,
                                height: 14,
                                color: const Color.fromRGBO(0, 0, 0, 0.1),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10)),
                            WTextContent(
                              value: "File Size: ${"----"} MB",
                              textColor: const Color.fromRGBO(0, 0, 0, 0.5),
                              textLineHeight: 14.32,
                              textSize: 12,
                              textFontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                        //
                        WSpacer(
                          height: 20,
                        ),
                        // selections
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildSelection(
                              context,
                              _pageConfig['mediaSrc'],
                              _pageConfig['title'],
                              _pageConfig['content']['title'],
                              onTap: () {
                                _showBottomSheetPageSize();
                              },
                            ),
                            WSpacer(
                              width: 10,
                            ),
                            buildSelection(
                              context,
                              _layoutConfig['mediaSrc'],
                              _layoutConfig['title'],
                              _layoutConfig['content'],
                              onTap: () {
                                _showBottomSheetLayout();
                              },
                            ),
                          ],
                        ),
                        WSpacer(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildSelection(
                                context,
                                _photosConfig['mediaSrc'],
                                _photosConfig['title'],
                                _photosConfig['content']),
                            WSpacer(
                              width: 10,
                            ),
                            buildSelection(context, _coverConfig['mediaSrc'],
                                _coverConfig['title'], _coverConfig['content']),
                          ],
                        ),
                      ]),
                      Container(
                        margin: const EdgeInsets.only(
                            bottom: 20, left: 10, right: 10),
                        child: Flex(
                          direction: Axis.horizontal,
                          children: [
                            Flexible(
                              child: WButtonFilled(
                                message: "Close",
                                backgroundColor:
                                    const Color.fromRGBO(0, 0, 0, 0.03),
                                height: 55,
                                textColor:
                                    const Color.fromRGBO(10, 132, 255, 1),
                                onPressed: () {
                                  popNavigator(context);
                                },
                              ),
                            ),
                            WSpacer(
                              width: 10,
                            ),
                            Flexible(
                              child: WButtonFilled(
                                message: "Save to...",
                                height: 55,
                                textColor: colorWhite,
                                backgroundColor:
                                    const Color.fromRGBO(10, 132, 255, 1),
                                onPressed: () {},
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  _showBottomSheetLayout() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom >= 100
                    ? MediaQuery.of(context).viewInsets.bottom - 100
                    : 0.0),
            child: StatefulBuilder(builder: (context, setStatefull) {
              return Container(
                height: _size.height * 0.95,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: WTextContent(
                        value: "Layout",
                        textSize: 14,
                        textLineHeight: 16.71,
                      ),
                    ),
                    WSpacer(
                      height: 20,
                    ),
                    buildSegmentControl(
                      groupValue: _segmentCurrentIndex,
                      onValueChanged: (value) {
                        setState(() {
                          _segmentCurrentIndex = value;
                        });
                        setStatefull(() {});
                      },
                    ),
                    Expanded(
                      child: Container(
                        height: _size.height * 404 / 791 * 0.9,
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(0, 0, 0, 0.03),
                            borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 20),
                        child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: _listLayoutStatus
                                        .sublist(0, 2)
                                        .toList()
                                        .map(
                                      (e) {
                                        final index =
                                            _listLayoutStatus.indexOf(e);
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: buildLayoutWidget(
                                            context: context,
                                            mediaSrc: e['mediaSrc'],
                                            title: "Layout ${index + 1}",
                                            isFocus: e['isFocus'],
                                            indexLayoutItem: index,
                                            onTap: () {
                                              _resetLayoutSelections();
                                              setState(() {
                                                _listLayoutStatus[index]
                                                    ['isFocus'] = true;
                                              });
                                              setStatefull(() {});
                                            },
                                          ),
                                        );
                                      },
                                    ).toList()),
                                WSpacer(
                                  height: 20,
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: _listLayoutStatus
                                        .sublist(2, _listLayoutStatus.length)
                                        .toList()
                                        .map(
                                      (e) {
                                        final index =
                                            _listLayoutStatus.indexOf(e);
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: buildLayoutWidget(
                                            context: context,
                                            mediaSrc: e['mediaSrc'],
                                            title: "Layout ${index + 1}",
                                            isFocus: e['isFocus'],
                                            indexLayoutItem: index,
                                            onTap: () {
                                              setState(() {
                                                _resetLayoutSelections();
                                                _listLayoutStatus[index]
                                                    ['isFocus'] = true;
                                              });
                                              setStatefull(() {});
                                            },
                                          ),
                                        );
                                      },
                                    ).toList())
                              ],
                            )),
                      ),
                    ),
                    _buildLayoutConfigs(() {
                      setStatefull(() {});
                    }),
                    buildBottomButton(context)
                  ],
                ),
              );
            }),
          );
        },
        isScrollControlled: true,
        backgroundColor: transparent);
  }

  Widget _buildLayoutConfigs(Function rerenderFunction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: buildLayoutConfigItem(
                    key: _keyResizeMode,
                    title: "Resize Mode",
                    content: "Aspect Fit",
                    width: _size.width * 0.3,
                    onTap: () {
                      final renderBoxResize = _keyResizeMode.currentContext
                          ?.findRenderObject() as RenderBox;
                      final widgetPosition =
                          renderBoxResize.localToGlobal(Offset.zero);
                      showLayoutDialogWidthOffset(
                          context: context,
                          offset: widgetPosition,
                          dialogWidget: buildResizeModeDialog(context, [
                            () {
                              popNavigator(context);
                            },
                            () {
                              popNavigator(context);
                            },
                            () {
                              popNavigator(context);
                            }
                          ]));
                    }),
              ),
              Flexible(
                  child: buildLayoutConfigItem(
                      title: "Alignment",
                      content: _listAlignment
                          .where((element) => element['isFocus'] == true)
                          .toList()
                          .first['title'],
                      width: _size.width * 0.3,
                      key: _keyAlignment,
                      onTap: () {
                        final renderBoxAlignment = _keyAlignment.currentContext
                            ?.findRenderObject() as RenderBox;
                        final widgetOffset =
                            renderBoxAlignment.localToGlobal(Offset.zero);
                        showLayoutDialogWidthOffset(
                            context: context,
                            offset: Offset(_size.width * (1 - (200 / 390)) / 2,
                                widgetOffset.dy),
                            dialogWidget:
                                buildAlignmentDialog(context, _listAlignment,
                                    onSelected: (index, value) {
                              setState(() {
                                _listAlignment = LIST_ALIGNMENT.map((e) {
                                  return {
                                    "mediaSrc": e['mediaSrc'],
                                    "title": e['title'],
                                    "isFocus": false
                                  };
                                }).toList();
                                _listAlignment[index]["isFocus"] = true;
                              });
                              rerenderFunction();
                              popNavigator(context);
                            }));
                      })),
              Flexible(
                child: buildLayoutConfigItem(
                    title: "Background",
                    content: "White",
                    width: _size.width * 0.3,
                    contentWidgetColor: Colors.white),
              ),
            ],
          ),
          WSpacer(
            height: 10,
          ),
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: buildLayoutConfigItem(
                      title: "Padding",
                      content: _paddingOptions['values'].join(",") +
                          " " +
                          _paddingOptions['unit'],
                      width: _size.width * 0.46)),
              Flexible(
                child: buildLayoutConfigItem(
                  title: "Spacing",
                  content: "10pt,10pt",
                  width: _size.width * 0.46,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBottomSheetPageSize() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom >= 100
                    ? MediaQuery.of(context).viewInsets.bottom - 100
                    : 0.0),
            child: StatefulBuilder(builder: (context, setStatefull) {
              return Container(
                height: _size.height * 0.55,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: WTextContent(
                            value: "Paper Size",
                            textSize: 14,
                            textLineHeight: 16.71,
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
                                    item: _pageConfig,
                                    onTap: () {
                                      setState(() {
                                        _indexPageSizeSelectionWidget = 0;
                                      });
                                      setStatefull(() {});
                                    },
                                    isFocus: _indexPageSizeSelectionWidget == 0,
                                    onSelected: (value) {
                                      setState(() {
                                        _pageConfig['content'] = value;
                                        _pageSizeWidthController.text =
                                            (_pageConfig['content']['width'])
                                                .toString();
                                        _pageSizeHeightController.text =
                                            (_pageConfig['content']['height'])
                                                .toString();
                                      });
                                      setStatefull(() {});
                                    },
                                  ),
                                  WSpacer(
                                    height: 10,
                                  ),
                                  // width
                                  buildCupertinoInput(
                                      context: context,
                                      controller: _pageSizeWidthController,
                                      title: "Width",
                                      focusNode: _widthFocusNode,
                                      onTap: () {
                                        if (_widthFocusNode.hasFocus) {
                                          setState(() {
                                            _indexPageSizeSelectionWidget = 1;
                                          });
                                          setStatefull(() {});
                                        }
                                      },
                                      onChanged: (value) {
                                        if (_pageSizeWidthController.text
                                                .trim() !=
                                            _pageConfig['content']['width']) {
                                          setState(() {
                                            _pageConfig['content'] =
                                                LIST_PAGE_SIZE[7];
                                          });
                                          setStatefull(() {});
                                        }
                                        if (value.trim().isEmpty) {
                                          _pageSizeWidthController.text = "1";
                                        }
                                      },
                                      suffixValue: _pageConfig['content']
                                          ['unit'],
                                      isFocus:
                                          _indexPageSizeSelectionWidget == 1),
                                  WSpacer(
                                    height: 10,
                                  ),
                                  // height
                                  buildCupertinoInput(
                                      context: context,
                                      controller: _pageSizeHeightController,
                                      title: "Height",
                                      focusNode: _heightFocusNode,
                                      onTap: () {
                                        if (_heightFocusNode.hasFocus) {
                                          setState(() {
                                            _indexPageSizeSelectionWidget = 2;
                                          });
                                          setStatefull(() {});
                                        }
                                      },
                                      onChanged: (value) {
                                        if (_pageSizeHeightController.text
                                                .trim() !=
                                            _pageConfig['content']['height']) {
                                          setState(() {
                                            _pageConfig['content'] =
                                                LIST_PAGE_SIZE[7];
                                          });
                                          setStatefull(() {});
                                        }
                                        if (value.trim().isEmpty) {
                                          _pageSizeHeightController.text = "1";
                                        }
                                      },
                                      suffixValue: _pageConfig['content']
                                          ['unit'],
                                      isFocus:
                                          _indexPageSizeSelectionWidget == 2),
                                  WSpacer(
                                    height: 10,
                                  ),
                                  // orientation
                                  _overWHValue()
                                      ? const SizedBox()
                                      : _buildOrientation(() {
                                          setStatefull(() {});
                                        })
                                ],
                              ),
                            ),
                            // page size preview
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(
                                    right: 20, left: 20, top: 20),
                                alignment: Alignment.topCenter,
                                child: Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    AnimatedContainer(
                                      alignment: Alignment.topCenter,
                                      duration:
                                          const Duration(milliseconds: 400),
                                      constraints: const BoxConstraints(
                                          maxHeight: 150, maxWidth: 150),
                                      height: _renderPreviewHeight(),
                                      width: _renderPreviewWidth(),
                                      decoration: BoxDecoration(
                                          border: _overWHValue()
                                              ? null
                                              : Border.all(
                                                  color: const Color.fromRGBO(
                                                      0, 0, 0, 0.1),
                                                  width: 2)),
                                      padding: const EdgeInsets.all(10),
                                    ),
                                    !_overWHValue()
                                        ? Positioned.fill(
                                            child: Container(
                                                alignment: Alignment.center,
                                                child: WTextContent(
                                                  value:
                                                      "${_pageSizeWidthController.text.trim()}x${_pageSizeHeightController.text.trim()}${_pageConfig['content']['unit']}",
                                                  textSize: 16,
                                                  textLineHeight: 19.09,
                                                  textFontWeight:
                                                      FontWeight.w600,
                                                  textColor:
                                                      const Color.fromRGBO(
                                                          0, 0, 0, 0.5),
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                )),
                                          )
                                        : Container(
                                            alignment: Alignment.topCenter,
                                            child: WTextContent(
                                              value:
                                                  "${_pageSizeWidthController.text.trim()}x${_pageSizeHeightController.text.trim()}${_pageConfig['content']['unit']}",
                                              textSize: 16,
                                              textLineHeight: 19.09,
                                              textFontWeight: FontWeight.w600,
                                              textColor: const Color.fromRGBO(
                                                  0, 0, 0, 0.5),
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                            ))
                                  ],
                                ),
                              ),
                            )
                          ],
                        )),
                        buildBottomButton(context)
                      ],
                    ),
                  ],
                ),
              );
            }),
          );
        },
        isScrollControlled: true,
        backgroundColor: transparent);
  }

  Widget _buildOrientation(
    Function() rerenderFunc,
  ) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 70,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color.fromRGBO(0, 0, 0, 0.03),
        ),
        child: Row(children: [
          Container(
            constraints: const BoxConstraints(minWidth: 50, maxWidth: 70),
            padding: const EdgeInsets.only(left: 5),
            child: WTextContent(
              value: "Orientation",
              textSize: 14,
              textLineHeight: 16.71,
              textColor: const Color.fromRGBO(0, 0, 0, 0.5),
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
    );
  }
}
