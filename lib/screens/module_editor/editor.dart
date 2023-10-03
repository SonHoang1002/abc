import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as flutter_riverpod;
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/extract_list.dart';
import 'package:photo_to_pdf/helpers/random_number.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/models/cover_photo.dart';
import 'package:photo_to_pdf/models/placement.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/providers/project_provider.dart';
import 'package:photo_to_pdf/screens/module_editor/bodies/body_paper.dart';
import 'package:photo_to_pdf/screens/module_editor/editor_padding_spacing.dart';
import 'package:photo_to_pdf/screens/module_editor/bodies/body_add_cover.dart';
import 'package:photo_to_pdf/screens/module_editor/bodies/body_background.dart';
import 'package:photo_to_pdf/screens/module_editor/bodies/body_selected_photos.dart';
import 'package:photo_to_pdf/widgets/w_editor.dart';
import 'package:photo_to_pdf/widgets/w_button.dart';
import 'package:photo_to_pdf/widgets/w_divider.dart';
import 'package:photo_to_pdf/widgets/w_drag_zoom_image.dart';
import 'package:photo_to_pdf/widgets/w_project_item.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import 'package:photo_to_pdf/widgets/w_unit_selections.dart';

class Editor extends flutter_riverpod.ConsumerStatefulWidget {
  final Project project;
  const Editor({super.key, required this.project});

  @override
  flutter_riverpod.ConsumerState<Editor> createState() => _EditorState();
}

class _EditorState extends flutter_riverpod.ConsumerState<Editor> {
  late Project _project;
  final TextEditingController _fileNameController =
      TextEditingController(text: "");
  final TextEditingController _paperSizeWidthController =
      TextEditingController(text: "");
  final TextEditingController _paperSizeHeightController =
      TextEditingController(text: "");

  // late List _listProject;
  late Size _size;
  late bool _paperSizeIsPortrait = true;
  int? _indexPageSizeSelectionWidget;

  late dynamic _paperConfig;
  late dynamic _layoutConfig;
  late dynamic _photosConfig;
  late dynamic _coverConfig;
  int? _segmentCurrentIndex;
  late List _listLayoutStatus;

  // layout config keys
  final GlobalKey _keyResizeMode = GlobalKey();
  final GlobalKey _keyAlignment = GlobalKey();

  // layout alignment variables
  late ResizeAttribute _resizeModeSelectedValue;
  // layout alignment variables
  late List<dynamic> _listAlignment;

  //layout padding variables
  final TextEditingController _paddingHorizontalController =
      TextEditingController(text: "0.0");
  final TextEditingController _paddingVerticalController =
      TextEditingController(text: "0.0");
  late PaddingAttribute _paddingOptions;

  //layout spacing variables
  final TextEditingController _spacingHorizontalController =
      TextEditingController(text: "0.0");
  final TextEditingController _spacingVerticalController =
      TextEditingController(text: "0.0");
  late SpacingAttribute _spacingOptions;
  // layout custom variables
  final List<ValueNotifier<Matrix4>> _matrix4Notifiers = [];
  List<Placement> _listPlacement = [];
  Placement? _seletedPlacement;
  late PlacementAttribute _placementOptions;

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

  // background variable
  late Color _currentLayoutColor;
  @override
  void initState() {
    super.initState();
    _project = widget.project;
    print("_project.paper?.getInfor(): ${_project.paper?.getInfor()}");
    _fileNameController.text =
        _project.title == "Untitled" ? "" : _project.title;

    _paperConfig = {
      "mediaSrc": "${pathPrefixIcon}icon_letter.png",
      "title": "Paper Size",
      "content": _project.paper ?? LIST_PAGE_SIZE[5]
    };
    _paperSizeWidthController.text = (_paperConfig['content'].width).toString();
    _paperSizeHeightController.text =
        (_paperConfig['content'].height).toString();

    _layoutConfig = {
      "mediaSrc": "${pathPrefixIcon}icon_layout.png",
      "title": "Layout",
      "content": "Layout ${_project.layoutIndex + 1}"
    };
    _photosConfig = {
      "mediaSrc": "${pathPrefixIcon}icon_frame.png",
      "title": "Selected Photos",
      "content": "${_project.listMedia.length} Photos"
    };
    _coverConfig = {
      "mediaSrc": "${pathPrefixIcon}icon_frame_1.png",
      "title": "Cover Photos",
      "content": "None"
    };
    _resizeModeSelectedValue = _project.resizeAttribute ?? LIST_RESIZE_MODE[0];
    _segmentCurrentIndex = 0;
    _listLayoutStatus = LIST_LAYOUT.map((e) {
      return {"mediaSrc": e, "isFocus": false};
    }).toList();
    _listLayoutStatus[_project.layoutIndex]['isFocus'] = true;

    _listAlignment = LIST_ALIGNMENT.map((e) {
      return {"mediaSrc": e.mediaSrc, "title": e.title, "isFocus": false};
    }).toList();

    int indexOfAlignment = LIST_ALIGNMENT.indexWhere(
        (element) => element.title == _project.alignmentAttribute?.title);
    if (indexOfAlignment != -1) {
      _listAlignment[indexOfAlignment]['isFocus'] = true;
    } else {
      _listAlignment[2]['isFocus'] = true;
    }

    _paddingOptions = _project.paddingAttribute ?? PADDING_OPTIONS;
    _paddingHorizontalController.text =
        _paddingOptions.horizontalPadding.toString();
    _paddingVerticalController.text =
        _paddingOptions.verticalPadding.toString();

    _spacingOptions = _project.spacingAttribute ?? SPACING_OPTIONS;
    _spacingHorizontalController.text =
        _spacingOptions.horizontalSpacing.toString();
    _spacingVerticalController.text =
        _spacingOptions.verticalSpacing.toString();

    _sliderCompressionValue = _project.compression;
    _coverPhoto =
        _project.coverPhoto ?? CoverPhoto(backPhoto: null, frontPhoto: null);
    _currentLayoutColor = _project.backgroundColor;

    _placementOptions = _project.placementAttribute ?? PLACEMENT_OPTIONS;
  }

  void _resetLayoutSelections() {
    _listLayoutStatus = _listLayoutStatus = LIST_LAYOUT.map((e) {
      return {"mediaSrc": e, "isFocus": false};
    }).toList();
  }

  String _renderPreviewPaddingOptions() {
    return "${_paddingHorizontalController.text.trim()} ${_paddingOptions.unit?.value} , ${_paddingVerticalController.text.trim()} ${_paddingOptions.unit?.value}";
  }

  String _renderPreviewSpacingOptions() {
    return "${_spacingHorizontalController.text.trim()} ${_spacingOptions.unit?.value} , ${_spacingVerticalController.text.trim()} ${_spacingOptions.unit?.value}";
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
                // input
                buildFileNameInput(context, _project, _fileNameController,
                    (value) {
                  _project = Project(
                      id: _project.id,
                      title: value.trim(),
                      listMedia: _project.listMedia);
                  ref.read(projectControllerProvider.notifier).updateProject(
                      Project(
                          id: _project.id,
                          listMedia: _project.listMedia,
                          title: value.trim()));
                }),
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
                        child: SingleChildScrollView(
                            padding: const EdgeInsets.only(top: 15),
                            child: _buildPreviewProjectBody()))),
                // page size and bottom buttons
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
                              value: "${_project.listMedia.length} Pages",
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
                              _paperConfig['mediaSrc'],
                              _paperConfig['title'],
                              _paperConfig['content'].title,
                              onTap: () {
                                _showBottomSheetPaperSize();
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
                                _showBottomSheetSelectedPhotos(
                                  context: context,
                                  size: _size,
                                  project: _project,
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
                                _showBottomSheetCoveredPhotos(
                                  context: context,
                                  size: _size,
                                );
                              },
                            ),
                          ],
                        ),
                      ]),
                      buildBottomButton(
                          context: context,
                          onApply: () {},
                          onCancel: () {
                            // print(
                            //     "_project.paper?.getInfor(): ${_project.paper?.getInfor()}");
                            ref
                                .read(projectControllerProvider.notifier)
                                .updateProject(_project);
                            popNavigator(context);
                          },
                          titleApply: "Save to...")
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget _buildLayoutConfigs(
      void Function() rerenderFunction, bool showPaddingAndSpacing) {
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
                    content: _resizeModeSelectedValue.title,
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
                                    "mediaSrc": e.mediaSrc,
                                    "title": e.title,
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
                  content: "",
                  width: _size.width * 0.3,
                  contentWidgetColor: _currentLayoutColor,
                  onTap: () {
                    _showBottomSheetBackground(
                        rerenderFunction: rerenderFunction);
                  },
                ),
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
                        pushCustomVerticalMaterialPageRoute(
                            context,
                            EditorPaddingSpacing(
                                unit: _paddingOptions.unit!,
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
                                onUnitDone: (Unit newUnit) {
                                  setState(() {
                                    _paddingOptions =
                                        _paddingOptions.copyWith(unit: newUnit);
                                  });
                                  rerenderFunction();
                                }));
                      },
                    )),
                    Flexible(
                      child: buildLayoutConfigItem(
                        context: context,
                        title: TITLE_SPACING,
                        content: _renderPreviewSpacingOptions(),
                        width: _size.width * 0.46,
                        onTap: () {
                          pushCustomVerticalMaterialPageRoute(
                              context,
                              EditorPaddingSpacing(
                                  unit: _spacingOptions.unit!,
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
                                  onUnitDone: (Unit newUnit) {
                                    setState(() {
                                      _spacingOptions = _spacingOptions
                                          .copyWith(unit: newUnit);
                                    });
                                    rerenderFunction();
                                  }));
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
                    _matrix4Notifiers.add(matrix4);
                    _listPlacement.removeAt(index);
                    _listPlacement.add(placement);
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
                              id: getRandomNumber()));
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
                              pushCustomVerticalMaterialPageRoute(
                                  context,
                                  EditorPaddingSpacing(
                                    unit: _placementOptions.unit!,
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
                                    onUnitDone: (newUnit) {
                                      setState(() {
                                        _placementOptions = _placementOptions
                                            .copyWith(unit: newUnit);
                                      });
                                      rerenderFunction();
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
            return 
            
            Container(
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
                                                backgroundColor:
                                                    _currentLayoutColor,
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
                                                backgroundColor:
                                                    _currentLayoutColor,
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
                  buildBottomButton(
                      context: context,
                      onApply: () {
                        if (_segmentCurrentIndex == 0) {
                          _layoutConfig['content'] =
                              "Layout ${_listLayoutStatus.indexWhere((element) => element['isFocus']) + 1}";
                        }
                        // layout
                        setState(() {
                          _project = _project.copyWith(
                              layoutIndex: _listLayoutStatus.indexWhere(
                                  (element) => element['isFocus'] == true),
                              backgroundColor: _currentLayoutColor,
                              resizeAttribute: ResizeAttribute(
                                title: _resizeModeSelectedValue.title,
                              ),
                              spacingAttribute: SpacingAttribute(
                                  horizontalSpacing: double.parse(
                                    _spacingHorizontalController.text.trim(),
                                  ),
                                  verticalSpacing: double.parse(
                                      _spacingVerticalController.text.trim())),
                              paddingAttribute: PaddingAttribute(
                                  horizontalPadding: double.parse(
                                    _paddingHorizontalController.text.trim(),
                                  ),
                                  verticalPadding: double.parse(
                                      _paddingVerticalController.text.trim())));
                          // resize mode
                          // alignment
                          // background
                          // padding
                          // spacing
                        });
                        popNavigator(context);
                      },
                      onCancel: () {
                        print("hello");
                      })
                ],
              ),
            );
          });
        },
        isScrollControlled: true,
        backgroundColor: transparent);
  }

  void _showBottomSheetPaperSize() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: StatefulBuilder(builder: (context, setStatefull) {
              return PaperBody(
                  reRenderFunction: () {
                    setStatefull(() {});
                  },
                  indexPageSizeSelectionWidget: _indexPageSizeSelectionWidget,
                  paperConfig: _paperConfig,
                  values: [
                    _paperSizeWidthController.text.trim(),
                    _paperSizeHeightController.text.trim()
                  ],
                  pageSizeIsPortrait: _paperSizeIsPortrait,
                  onDone: (newPaper,pageSizeIsPortrait) {
                    _project = _project.copyWith(paper: newPaper);
                    _paperSizeHeightController.text =
                        newPaper.height.toString();
                    _paperSizeWidthController.text = newPaper.width.toString();
                    _paperSizeIsPortrait = pageSizeIsPortrait;
                    setState(() {});
                  });
            }),
          );
        },
        isScrollControlled: true,
        backgroundColor: transparent);
  }

  void _showBottomSheetSelectedPhotos(
      {required BuildContext context,
      required Size size,
      required Project project,
      required double sliderCompressionLevelValue,
      required Function(double value) onSliderChanged}) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStatefull) {
            return SelectedPhotosBody(
              reRenderFunction: () {
                setStatefull(() {});
              },
              project: _project,
              sliderCompressionLevelValue: sliderCompressionLevelValue,
              onChangedSlider: (value) {
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
              },
              onApply: (newProject) {
                setState(() {
                  _project = newProject;
                  _photosConfig = {
                    ..._photosConfig,
                    "content": "${_project.listMedia.length} Photos"
                  };
                });
                setStatefull(() {});
                ref
                    .read(projectControllerProvider.notifier)
                    .updateProject(_project);
              },
            );
          });
        },
        isScrollControlled: true,
        backgroundColor: transparent);
  }

  void _showBottomSheetCoveredPhotos({
    required BuildContext context,
    required Size size,
  }) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStatefull) {
            return AddCoverBody(
                coverPhoto: _coverPhoto,
                onUpdatePhoto: (newCoverPhoto) {
                  _coverPhoto = newCoverPhoto;
                  if (_coverPhoto.backPhoto != null &&
                      _coverPhoto.frontPhoto != null) {
                    _coverConfig["content"] = "Edit";
                  } else {
                    _coverConfig["content"] = "None";
                  }
                  setState(() {});
                  setStatefull(() {});
                  popNavigator(context);
                },
                reRenderFunction: () {
                  setStatefull(() {});
                });
          });
        },
        isScrollControlled: true,
        backgroundColor: transparent);
  }

  void _showBottomSheetBackground({required void Function()? rerenderFunction}) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStatefull) {
            return BackgroundBody(
              currentColor: _currentLayoutColor,
              onColorChanged: (color) {
                setState(() {
                  _currentLayoutColor = color;
                });
                setStatefull(() {});
                rerenderFunction != null ? rerenderFunction() : null;
              },
            );
          });
        },
        isScrollControlled: true,
        backgroundColor: transparent);
  }

  Widget _buildPreviewProjectBody() {
    if (_project.listMedia.isEmpty) {
      final blankProject = Project(
          id: getRandomNumber(),
          listMedia: ["${pathPrefixImage}blank_page.jpg"]);
      return Wrap(
        alignment: WrapAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: WProjectItemEditor(
              key: ValueKey(blankProject.id),
              project: blankProject,
              isFocusByLongPress: false,
              indexImage: 0,
              title: "Page ${1}",
            ),
          )
        ],
      );
    } else {
      if (_project.layoutIndex == 0) {
        return Wrap(
          alignment: WrapAlignment.center,
          children: _project.listMedia.map((e) {
            final index = _project.listMedia.indexOf(e);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: WProjectItemEditor(
                key: ValueKey(_project.listMedia[index]),
                project: _project,
                isFocusByLongPress: false,
                indexImage: index,
                title: "Page ${index + 1}",
              ),
            );
          }).toList(),
        );
      } else if (_project.layoutIndex == 1) {
        List list = extractList(2, _project.listMedia);
        return Wrap(
          alignment: WrapAlignment.center,
          children: list.map((e) {
            final index = list.indexOf(e);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: WProjectItemEditor(
                key: ValueKey(_project.listMedia[index]),
                project: _project,
                isFocusByLongPress: false,
                indexImage: index,
                layoutExtractList: list[index],
                title: "Page ${index + 1}",
              ),
            );
          }).toList(),
        );
      } else if ([2, 3].contains(_project.layoutIndex)) {
        List list = extractList(3, _project.listMedia);
        return Wrap(
          alignment: WrapAlignment.center,
          children: list.map((e) {
            final index = list.indexOf(e);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: WProjectItemEditor(
                key: ValueKey(_project.listMedia[index]),
                project: _project,
                isFocusByLongPress: false,
                indexImage: index,
                layoutExtractList: list[index],
                title: "Page ${index + 1}",
              ),
            );
          }).toList(),
        );
      } else {
        return Container(height: 50, width: 200, color: colorRed);
      }
    }
  }
}
