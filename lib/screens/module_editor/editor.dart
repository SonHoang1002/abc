import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as flutter_riverpod;
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/models/cover_photo.dart';
import 'package:photo_to_pdf/models/placement.dart';
import 'package:photo_to_pdf/providers/project_provider.dart';
import 'package:photo_to_pdf/screens/module_editor/editor_padding_spacing.dart';
import 'package:photo_to_pdf/screens/module_editor/widgets/body_add_cover.dart';
import 'package:photo_to_pdf/screens/module_editor/widgets/body_selected_photos.dart';
import 'package:photo_to_pdf/screens/module_editor/widgets/w_editor.dart';
import 'package:photo_to_pdf/widgets/w_button.dart';
import 'package:photo_to_pdf/widgets/w_divider.dart';
import 'package:photo_to_pdf/widgets/w_drag_zoom_image.dart';
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

  // layout alignment variables
  late dynamic _resizeModeSelectedValue;
  // layout alignment variables
  late List<dynamic> _listAlignment;

  //layout padding variables
  final TextEditingController _paddingHorizontalController =
      TextEditingController(text: "0.0");
  final TextEditingController _paddingVerticalController =
      TextEditingController(text: "0.0");
  late dynamic _paddingOptions;

  //layout spacing variables
  final TextEditingController _spacingHorizontalController =
      TextEditingController(text: "0.0");
  final TextEditingController _spacingVerticalController =
      TextEditingController(text: "0.0");
  late dynamic _spacingOptions;
  // layout custom variables
  final List<ValueNotifier<Matrix4>> _matrix4Notifiers = [];
  List<Placement> _listPlacement = [];
  Placement? _seletedPlacement;

  final TextEditingController _placementTopController =
      TextEditingController(text: "0.0");
  final TextEditingController _placementLeftController =
      TextEditingController(text: "0.0");
  final TextEditingController _placementRightController =
      TextEditingController(text: "0.0");
  final TextEditingController _placementBottomController =
      TextEditingController(text: "0.0");
  final TextEditingController _placementWidthController =
      TextEditingController(text: "0.0");
  final TextEditingController _placementHeightController =
      TextEditingController(text: "0.0");

  // selected photos
  late double _sliderCompressionValue;

  // add cover
  late CoverPhoto _coverPhoto;

  @override
  void initState() {
    super.initState();

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

    _pageSizeWidthController.text =
        (_pageConfig['content']['width']).toString();
    _pageSizeHeightController.text =
        (_pageConfig['content']['height']).toString();

    _resizeModeSelectedValue = LIST_RESIZE_MODE[0];

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
    _paddingHorizontalController.text = _paddingOptions['values'][0];
    _paddingVerticalController.text = _paddingOptions['values'][1];

    _spacingOptions = SPACING_OPTIONS;
    _spacingHorizontalController.text = _spacingOptions['values'][0];
    _spacingVerticalController.text = _spacingOptions['values'][1];
    _sliderCompressionValue = 1;
    _coverPhoto = CoverPhoto(
        backPhoto: "${pathPrefixImage}test_image_1.png",
        frontPhoto: "${pathPrefixImage}test_image_1.png");
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

  String _renderPreviewPaddingOptions() {
    return "${_paddingHorizontalController.text.trim()}${_paddingOptions['unit']} , ${_paddingVerticalController.text.trim()} ${_paddingOptions['unit']}";
  }

  String _renderPreviewSpacingOptions() {
    return "${_spacingHorizontalController.text.trim()}${_spacingOptions['unit']} , ${_spacingVerticalController.text.trim()} ${_spacingOptions['unit']}";
  }

  void _onChangedEditPlacement(int index, String value) {
    switch (index) {
      case 0:
        _placementWidthController.text = value;
        break;
      case 1:
        _placementHeightController.text = value;
        break;
      case 2:
        _placementTopController.text = value;
        break;
      case 3:
        _placementLeftController.text = value;
        break;
      case 4:
        _placementRightController.text = value;
        break;
      case 5:
        _placementBottomController.text = value;
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.sizeOf(context);
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    color: Theme.of(context).cardColor,
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
                              textColor:
                                  Theme.of(context).textTheme.bodyMedium!.color,
                              textLineHeight: 14.32,
                              textSize: 12,
                              textFontWeight: FontWeight.w600,
                            ),
                            WDivider(
                                width: 2,
                                height: 14,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10)),
                            WTextContent(
                              value: "File Size: ${"----"} MB",
                              textColor:
                                  Theme.of(context).textTheme.bodyMedium!.color,
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
                              _photosConfig['content'],
                              onTap: () {
                                showBottomSheetSelectedPhotos(
                                  context: context,
                                  size: _size,
                                  datas: ref
                                      .watch(projectControllerProvider)
                                      .listProject,
                                  onReorderFunction: (oldIndex, newIndex) {
                                    setState(() {
                                      final tempListProject = ref
                                          .watch(projectControllerProvider)
                                          .listProject;
                                      final element =
                                          tempListProject.removeAt(oldIndex);
                                      tempListProject.insert(newIndex, element);
                                      ref
                                          .read(projectControllerProvider
                                              .notifier)
                                          .setProject(tempListProject);
                                    });
                                  },
                                  onSliderChanged: (value) {
                                    setState(() {
                                      _sliderCompressionValue = value;
                                    });
                                  },
                                  sliderCompressionLevelValue:
                                      _sliderCompressionValue,
                                );
                              },
                            ),
                            WSpacer(
                              width: 10,
                            ),
                            buildSelection(
                              context,
                              _coverConfig['mediaSrc'],
                              _coverConfig['title'],
                              _coverConfig['content'],
                              onTap: () {
                                showBottomSheetCoveredPhotos(
                                  context: context,
                                  size: _size,
                                );
                              },
                            ),
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
                                backgroundColor: Theme.of(context).cardColor,
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

  Widget _buildLayoutConfigs(
      Function rerenderFunction, bool showPaddingAndSpacing) {
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
                    context: context,
                    key: _keyResizeMode,
                    title: "Resize Mode",
                    content: _resizeModeSelectedValue['title'],
                    width: _size.width * 0.3,
                    onTap: () {
                      final renderBoxResize = _keyResizeMode.currentContext
                          ?.findRenderObject() as RenderBox;
                      final widgetPosition =
                          renderBoxResize.localToGlobal(Offset.zero);
                      showLayoutDialogWithOffset(
                          context: context,
                          offset: widgetPosition,
                          dialogWidget: buildDialogResizeMode(
                            context,
                            (value) {
                              setState(() {
                                _resizeModeSelectedValue = value;
                              });
                              rerenderFunction();
                              popNavigator(context);
                            },
                          ));
                    }),
              ),
              Flexible(
                  child: buildLayoutConfigItem(
                      context: context,
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
                        showLayoutDialogWithOffset(
                            context: context,
                            offset: Offset(_size.width * (1 - (200 / 390)) / 2,
                                widgetOffset.dy),
                            dialogWidget:
                                buildDialogAlignment(context, _listAlignment,
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
                    context: context,
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
          showPaddingAndSpacing
              ? Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        child: buildLayoutConfigItem(
                      context: context,
                      title: TITLE_PADDING,
                      content: _renderPreviewPaddingOptions(),
                      width: _size.width * 0.46,
                      onTap: () {
                        pushCustomMaterialPageRoute(
                            context,
                            EditorPaddingSpacing(
                              title: TITLE_PADDING,
                              controllers: [
                                _paddingHorizontalController,
                                _paddingVerticalController
                              ],
                              onChanged: (index, value) {
                                if (index == 0) {
                                  _paddingHorizontalController.text = value;
                                }
                                if (index == 1) {
                                  _paddingVerticalController.text = value;
                                }
                              },
                            ));
                      },
                    )),
                    Flexible(
                      child: buildLayoutConfigItem(
                        context: context,
                        title: TITLE_SPACING,
                        content: _renderPreviewSpacingOptions(),
                        width: _size.width * 0.46,
                        onTap: () {
                          pushCustomMaterialPageRoute(
                              context,
                              EditorPaddingSpacing(
                                title: TITLE_SPACING,
                                controllers: [
                                  _spacingHorizontalController,
                                  _spacingVerticalController
                                ],
                                onChanged: (index, value) {
                                  if (index == 0) {
                                    _spacingHorizontalController.text = value;
                                  }
                                  if (index == 1) {
                                    _spacingVerticalController.text = value;
                                  }
                                },
                              ));
                        },
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildCustomArea(
    Function rerenderFunction,
  ) {
    void disablePlacement() {
      setState(() {
        _seletedPlacement = null;
      });
      rerenderFunction();
    }

    return GestureDetector(
      onTap: () {
        disablePlacement();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        height: _size.height * 404 / 791 * 0.9,
        width: _size.width,
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: GestureDetector(
          onTap: () {
            disablePlacement();
          },
          child: Column(children: [
            Expanded(
                child: WDragZoomImage(
              reRenerFunction: rerenderFunction,
              listPlacement: _listPlacement,
              matrix4Notifiers: _matrix4Notifiers,
              updatePlacement: (placements) {
                setState(() {
                  _listPlacement = placements;
                });
                rerenderFunction();
                // _listPlacement.forEach((element) {
                //   element.getInfor();
                // });
              },
              onFocusPlacement: (placement, matrix4) {
                setState(() {
                  int index = _listPlacement.indexWhere(
                    (element) {
                      return element.id == placement.id;
                    },
                  );
                  if (index != -1) {
                    _matrix4Notifiers.removeAt(index);
                    _matrix4Notifiers.insert(0, matrix4);
                    _listPlacement.removeAt(index);
                    _listPlacement.insert(0, placement);
                  }
                });
                rerenderFunction();
                setState(() {
                  _seletedPlacement = placement;
                });
                rerenderFunction();
              },
              seletedPlacement: _seletedPlacement,
            )),
            WSpacer(height: 10),
            SizedBox(
              width: _size.width * 0.7,
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  Flexible(
                    flex: 4,
                    child: WButtonFilled(
                      message: "Add Placement",
                      textColor: colorBlue,
                      textLineHeight: 14.32,
                      textSize: 12,
                      height: 30,
                      backgroundColor: const Color.fromRGBO(22, 115, 255, 0.08),
                      onPressed: () {
                        setState(() {
                          _matrix4Notifiers
                              .add(ValueNotifier(Matrix4.identity()));
                          _listPlacement.add(Placement(
                              width: 70,
                              height: 70,
                              alignment: Alignment.center,
                              offset: Offset(_size.width * 0.4 - 35,
                                  _size.width * 0.4 - 35),
                              id: Random().nextInt(10000)));
                          _seletedPlacement = _listPlacement.last;
                        });
                        rerenderFunction();
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  _seletedPlacement != null
                      ? WSpacer(
                          width: 10,
                        )
                      : const SizedBox(),
                  _seletedPlacement != null
                      ? Flexible(
                          flex: 2,
                          child: WButtonFilled(
                            message: "Edit",
                            height: 30,
                            textColor: colorBlue,
                            textLineHeight: 14.32,
                            textSize: 12,
                            backgroundColor:
                                const Color.fromRGBO(22, 115, 255, 0.08),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              pushCustomMaterialPageRoute(
                                  context,
                                  EditorPaddingSpacing(
                                    title: TITLE_EDIT_PLACEMENT,
                                    // width and height is 0 and 1 to comparable with EditorPaddingSpacing (2 controller)
                                    controllers: [
                                      _placementWidthController,
                                      _placementHeightController,
                                      _placementTopController,
                                      _placementLeftController,
                                      _placementRightController,
                                      _placementBottomController,
                                    ],
                                    onChanged: (index, value) {
                                      _onChangedEditPlacement(index, value);
                                    },
                                  ));
                            },
                          ),
                        )
                      : const SizedBox(),
                  _seletedPlacement != null
                      ? WSpacer(
                          width: 10,
                        )
                      : const SizedBox(),
                  _seletedPlacement != null
                      ? Flexible(
                          flex: 2,
                          child: WButtonFilled(
                            message: "Delete",
                            height: 30,
                            textColor: const Color.fromRGBO(255, 63, 51, 1),
                            textLineHeight: 14.32,
                            textSize: 12,
                            backgroundColor:
                                const Color.fromRGBO(255, 63, 51, 0.1),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              final index =
                                  _listPlacement.indexOf(_seletedPlacement!);
                              _listPlacement.removeAt(index);
                              _matrix4Notifiers.removeAt(index);
                              _seletedPlacement = null;
                              setState(() {});
                              rerenderFunction();
                            },
                          ),
                        )
                      : const SizedBox()
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }

  void _showBottomSheetLayout() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStatefull) {
            return Container(
              height: _size.height * 0.95,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
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
                      textColor: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ),
                  WSpacer(
                    height: 20,
                  ),
                  buildSegmentControl(
                    context: context,
                    groupValue: _segmentCurrentIndex,
                    onValueChanged: (value) {
                      setState(() {
                        _segmentCurrentIndex = value;
                      });
                      setStatefull(() {});
                    },
                  ),
                  Expanded(
                    child: _segmentCurrentIndex == 0
                        ? Container(
                            height: _size.height * 404 / 791 * 0.9,
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                              margin:
                                                  const EdgeInsets.symmetric(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: _listLayoutStatus
                                            .sublist(
                                                2, _listLayoutStatus.length)
                                            .toList()
                                            .map(
                                          (e) {
                                            final index =
                                                _listLayoutStatus.indexOf(e);
                                            return Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
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
                                )))
                        : _buildCustomArea(() {
                            setStatefull(() {});
                          }),
                  ),
                  _buildLayoutConfigs(() {
                    setStatefull(() {});
                  }, _segmentCurrentIndex == 0),
                  buildBottomButton(context)
                ],
              ),
            );
          });
        },
        isScrollControlled: true,
        backgroundColor: transparent);
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
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
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
                            textSize: 16,
                            textLineHeight: 19.09,
                            textFontWeight: FontWeight.w600,
                            textColor:
                                Theme.of(context).textTheme.bodyMedium!.color,
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
                                      onTap: () {
                                        setState(() {
                                          _indexPageSizeSelectionWidget = 1;
                                        });
                                        setStatefull(() {});
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
                                      onTap: () {
                                        setState(() {
                                          _indexPageSizeSelectionWidget = 2;
                                        });
                                        setStatefull(() {});
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
                                          color: colorWhite,
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
    );
  }

  void showBottomSheetSelectedPhotos(
      {required BuildContext context,
      required Size size,
      required List datas,
      required void Function(int, int) onReorderFunction,
      required double sliderCompressionLevelValue,
      required Function(double value) onSliderChanged}) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStatefull) {
            return SelectedPhotosBody(
                onReorder: (oldIndex, newIndex) {
                  onReorderFunction(oldIndex, newIndex);
                  setStatefull(() {});
                },
                datas: datas,
                sliderCompressionLevelValue: sliderCompressionLevelValue,
                onChanged: (value) {
                  setState(() {
                    // use sliderCompressionLevelValue to announce for selected photos
                    // body that have changable variable
                    // if only use _sliderCompressionValue, don't change value
                    // sliderCompressionLevelValue because pass data
                    // through every child and don't listen changes
                    sliderCompressionLevelValue = value;
                    _sliderCompressionValue = value;
                  });
                  setStatefull(() {});
                });
          });
        },
        isScrollControlled: true,
        backgroundColor: transparent);
  }

  void showBottomSheetCoveredPhotos({
    required BuildContext context,
    required Size size,
  }) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStatefull) {
            return AddCoverBody(
              coverPhoto: _coverPhoto,
              updatePhoto: (label, src) {
                if (label == "backPhoto") {
                  _coverPhoto = CoverPhoto(
                      backPhoto: src, frontPhoto: _coverPhoto.frontPhoto);
                  setState(() {});
                  setStatefull(() {});
                }
                if (label == "frontPhoto") {
                  _coverPhoto = CoverPhoto(
                      backPhoto: _coverPhoto.backPhoto, frontPhoto: src);
                  setState(() {});
                  setStatefull(() {});
                }
              },
            );
          });
        },
        isScrollControlled: true,
        backgroundColor: transparent);
  }
}
