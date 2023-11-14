import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/helpers/change_list.dart';
import 'package:photo_to_pdf/helpers/convert.dart';
import 'package:photo_to_pdf/helpers/random_number.dart';
import 'package:photo_to_pdf/models/placement.dart';
import 'package:photo_to_pdf/screens/module_editor/bodies/body_background.dart';
import 'package:photo_to_pdf/screens/module_editor/bodies/body_dialogs.dart';
import 'package:photo_to_pdf/widgets/w_button.dart';
import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/screens/module_editor/editor_padding_spacing.dart';
import 'package:photo_to_pdf/widgets/w_drag_zoom_image.dart';
import 'package:photo_to_pdf/widgets/w_editor.dart';
import 'package:photo_to_pdf/widgets/w_layout_suggestion.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class LayoutBody extends StatefulWidget {
  final Project project;
  final Function() reRenderFunction;
  final Function(Project project, int segmentIndex) onApply;
  final int segmentCurrentIndex;
  const LayoutBody(
      {super.key,
      required this.project,
      required this.reRenderFunction,
      required this.onApply,
      required this.segmentCurrentIndex});

  @override
  State<LayoutBody> createState() => _LayoutBodyState();
}

class _LayoutBodyState extends State<LayoutBody> {
  late Project _project;
  late int _segmentCurrentIndex;
  late List _listLayoutStatus;
  late Size _size;

  // layout config keys
  final GlobalKey _keyResizeMode = GlobalKey();
  final GlobalKey _keyAlignment = GlobalKey();

  // layout alignment variables
  late ResizeAttribute _resizeModeSelectedValue;

  // layout alignment variables
  late List<dynamic> _listAlignment;

  //layout padding variables
  late PaddingAttribute _paddingOptions;

  //layout spacing variables
  late SpacingAttribute _spacingOptions;

  // layout custom variables
  final List<ValueNotifier<Matrix4>> _matrix4Notifiers = [];
  List<Placement> _listPlacement = [];
  Placement? _selectedPlacement;

  // background variable
  late Color _currentLayoutColor;
  late List<double> _ratioTarget;
  late Offset _alignmentDialogOffset;
  late bool _isShowAlignmentDialog; 
  late List<GlobalKey> _listGlobalKey = [];

  @override
  void initState() {
    super.initState();
    _project = widget.project
        .copyWith(placements: List.from(widget.project.placements ?? []));
    _resizeModeSelectedValue = _project.resizeAttribute ?? LIST_RESIZE_MODE[0];
    _segmentCurrentIndex = widget.segmentCurrentIndex;
    _listLayoutStatus = LIST_LAYOUT_SUGGESTION.map((e) {
      return {"layout": e, "isFocus": false};
    }).toList();
    _listLayoutStatus[_project.layoutIndex]['isFocus'] = true;
    _listAlignment = LIST_ALIGNMENT.map((e) {
      return {"alignment": e, "isFocus": false};
    }).toList();

    int indexOfAlignment = LIST_ALIGNMENT.indexWhere(
        (element) => element.title == _project.alignmentAttribute?.title);
    if (indexOfAlignment != -1) {
      _listAlignment[indexOfAlignment]['isFocus'] = true;
    } else {
      _listAlignment[2]['isFocus'] = true;
    }

    _paddingOptions = _project.paddingAttribute ?? PADDING_OPTIONS;
    _spacingOptions = _project.spacingAttribute ?? SPACING_OPTIONS;
    _currentLayoutColor = _project.backgroundColor; 
    _listPlacement = (_project.placements ?? []); 
    _listPlacement.forEach((_) {
      _matrix4Notifiers.add(ValueNotifier<Matrix4>(Matrix4.identity()));
    });
    _ratioTarget = LIST_RATIO_PLACEMENT_BOARD;
    if (_project.paper != null &&
        _project.paper?.height != 0 &&
        _project.paper?.width != 0) {
      _ratioTarget = [
        _ratioTarget[0],
        _project.paper!.height / _project.paper!.width * _ratioTarget[0]
      ];
    }
    _listGlobalKey = _listPlacement.map((e) => GlobalKey()).toList();
    _isShowAlignmentDialog = false;
  }

  @override
  void dispose() {
    super.dispose();
    _listAlignment.clear();
    _matrix4Notifiers.clear();
    _selectedPlacement = null;
    _listLayoutStatus.clear();
  }

  void _resetLayoutSelections() {
    _listLayoutStatus = LIST_LAYOUT_SUGGESTION.map((e) {
      return {"layout": e, "isFocus": false};
    }).toList();
  }

  String _renderPreviewPaddingOptions() {
    return "${_paddingOptions.horizontalPadding} ${_paddingOptions.unit?.value} , ${_paddingOptions.verticalPadding} ${_paddingOptions.unit?.value}";
  }

  String _renderPreviewSpacingOptions() {
    return "${_spacingOptions.horizontalSpacing} ${_spacingOptions.unit?.value} , ${_spacingOptions.verticalSpacing} ${_spacingOptions.unit?.value}";
  }

  void _onDone(Placement newData, List<String> paddingAttributeList,
      double convertWidth, double convertHeight) {
    for (var placement in _listPlacement) {
      if (placement.id == newData.id) {
        final index = _listPlacement.indexOf(placement);
        // update ratioHeight, ratioWidth, ratioOffset of _listPlacement[index]
        // convert unit
        List<double> paddingAttributeList0 = [];
        paddingAttributeList0 = paddingAttributeList.map((e) {
          return convertUnit(_selectedPlacement!.placementAttribute!.unit!,
              newData.placementAttribute!.unit!, double.parse(e));
        }).toList();
        final convertWidth0 = convertUnit(
            _selectedPlacement!.placementAttribute!.unit!,
            newData.placementAttribute!.unit!,
            convertWidth);
        final convertHeight0 = convertUnit(
            _selectedPlacement!.placementAttribute!.unit!,
            newData.placementAttribute!.unit!,
            convertHeight);
        final deltaTop =
            (newData.placementAttribute!.top - paddingAttributeList0[2]);
        final deltaLeft =
            (newData.placementAttribute!.left - paddingAttributeList0[3]);
        final deltaRight =
            (newData.placementAttribute!.right - paddingAttributeList0[4]);
        final deltaBottom =
            (newData.placementAttribute!.bottom - paddingAttributeList0[5]);

        // padding top
        if (deltaTop > 0) {
          _listPlacement[index].ratioHeight -=
              (deltaTop / convertHeight0).abs();
          _listPlacement[index].ratioOffset[1] +=
              (deltaTop / convertHeight0).abs();
        } else if (deltaTop < 0) {
          _listPlacement[index].ratioHeight +=
              (deltaTop / convertHeight0).abs();
          _listPlacement[index].ratioOffset[1] -=
              (deltaTop / convertHeight0).abs();
        }
        // padding left
        if (deltaLeft > 0) {
          _listPlacement[index].ratioWidth -= (deltaLeft / convertWidth0).abs();
          _listPlacement[index].ratioOffset[0] +=
              (deltaLeft / convertWidth0).abs();
        } else if (deltaLeft < 0) {
          _listPlacement[index].ratioWidth += (deltaLeft / convertWidth0).abs();
          _listPlacement[index].ratioOffset[0] -=
              (deltaLeft / convertWidth0).abs();
        }
        // padding right
        if (deltaRight > 0) {
          _listPlacement[index].ratioWidth -=
              (deltaRight / convertWidth0).abs();
        } else if (deltaRight < 0) {
          _listPlacement[index].ratioWidth +=
              (deltaRight / convertWidth0).abs();
        }
        // padding bottom
        if (deltaBottom > 0) {
          _listPlacement[index].ratioHeight -=
              (deltaBottom / convertHeight0).abs();
        } else if (deltaBottom < 0) {
          _listPlacement[index].ratioHeight +=
              (deltaBottom / convertHeight0).abs();
        }
        // update list placements
        _listPlacement[index] = _listPlacement[index].copyWith(
            placementAttribute: newData.placementAttribute!.copyWith(
                horizontal: newData.placementAttribute!.horizontal,
                vertical: newData.placementAttribute!.vertical,
                left: newData.placementAttribute!.left,
                right: newData.placementAttribute!.right,
                top: newData.placementAttribute!.top,
                bottom: newData.placementAttribute!.bottom,
                unit: newData.placementAttribute!.unit));
      }
    }
    // _disablePlacement();
  }

  void _showBottomSheetBackground(
      {required void Function()? rerenderFunction}) {
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

  Placement _createNewPlacement() {
    final newPlacement = Placement(
      id: getRandomNumber(),
      ratioWidth: 0.3,
      ratioHeight: _project.paper != null
          ? (0.3 * _project.paper!.width / _project.paper!.height)
          : 0.25,
      ratioOffset: [
        0.5 - 0.15,
        0.5 -
            (_project.paper != null
                    ? (0.3 * _project.paper!.width / _project.paper!.height)
                    : 0.25) /
                2
      ],
      placementAttribute: PLACEMENT_ATTRIBUTE,
    );
    return newPlacement;
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.sizeOf(context);
    return Stack(
      children: [
        Column(
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
                  _segmentCurrentIndex = value!;
                });
                widget.reRenderFunction();
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
                              _buildLayoutSuggestion(0, 2),
                              WSpacer(
                                height: 20,
                              ),
                              _buildLayoutSuggestion(2, 4),
                              WSpacer(
                                height: 20,
                              ),
                              _buildLayoutSuggestion(
                                  4, _listLayoutStatus.length),
                            ],
                          )))
                  : _buildCustomArea(() {
                      widget.reRenderFunction();
                    }),
            ),
            _buildLayoutConfigs(() {
              widget.reRenderFunction();
            }, _segmentCurrentIndex == 0),
            buildBottomButton(
              context: context,
              onApply: () {
                if (_segmentCurrentIndex == 0 ||
                    (_segmentCurrentIndex == 1 && _listPlacement.isEmpty)) {
                  _project = _project.copyWith(
                      layoutIndex: _listLayoutStatus
                          .indexWhere((element) => element['isFocus'] == true),
                      resizeAttribute: _resizeModeSelectedValue,
                      alignmentAttribute: _listAlignment
                          .where((element) => element['isFocus'] == true)
                          .toList()
                          .first['alignment'],
                      backgroundColor: _currentLayoutColor,
                      paddingAttribute: _paddingOptions,
                      spacingAttribute: _spacingOptions,
                      placements: _listPlacement.map((e) => e).toList(),
                      useAvailableLayout: true);
                  widget.onApply(_project, _segmentCurrentIndex);
                  return;
                }
                if (_segmentCurrentIndex == 1) {
                  _project = _project.copyWith(
                      layoutIndex: null,
                      resizeAttribute: _resizeModeSelectedValue,
                      alignmentAttribute: _listAlignment
                          .where((element) => element['isFocus'] == true)
                          .toList()
                          .first['alignment'],
                      backgroundColor: _currentLayoutColor,
                      placements: _listPlacement.map((e) => e).toList(),
                      useAvailableLayout: false);
                  widget.onApply(_project, _segmentCurrentIndex);
                  return;
                }
              },
              onCancel: () {
                popNavigator(context);
              },
            )
          ],
        ),
        _isShowAlignmentDialog
            ? BodyDialogCustom(
                offset: Offset(_size.width * (1 - (200 / 390)) / 2,
                    _alignmentDialogOffset.dy),
                dialogWidget: buildDialogAlignment(context, _listAlignment,
                    onSelected: (index, value) {
                  setState(() {
                    _listAlignment = LIST_ALIGNMENT.map((e) {
                      return {'alignment': e, "isFocus": false};
                    }).toList();
                    _listAlignment[index]["isFocus"] = true;
                  });
                  widget.reRenderFunction();
                }),
                onTapBackground: () {
                  setState(() {
                    _isShowAlignmentDialog = false;
                  });
                  widget.reRenderFunction();
                },
              )
            : const SizedBox()
      ],
    );
  }

  Widget _buildLayoutSuggestion(int start, int end) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _listLayoutStatus.sublist(start, end).toList().map(
          (e) {
            final index = _listLayoutStatus.indexOf(e);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: buildLayoutWidget(
                context: context,
                title: "Layout ${index + 1}",
                isFocus: e['isFocus'],
                backgroundColor: _currentLayoutColor,
                layoutSuggestion: e["layout"],
                onTap: () {
                  _resetLayoutSelections();
                  setState(() {
                    _listLayoutStatus[index]['isFocus'] = true;
                  });
                  widget.reRenderFunction();
                },
              ),
            );
          },
        ).toList());
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
                        newScreen: BodyDialogCustom(
                          offset: widgetPosition,
                          dialogWidget: buildDialogResizeMode(
                            context,
                            (value) {
                              setState(() {
                                _resizeModeSelectedValue = value;
                              });
                              widget.reRenderFunction();
                              popNavigator(context);
                            },
                          ),
                          scaleAlignment: Alignment.bottomLeft,
                        ),
                      );
                    }),
              ),
              Flexible(
                  child: buildLayoutConfigItem(
                      context: context,
                      title: "Alignment",
                      content: _listAlignment
                          .where((element) => element['isFocus'] == true)
                          .toList()
                          .first['alignment']
                          .title,
                      width: _size.width * 0.3,
                      key: _keyAlignment,
                      onTap: () {
                        final renderBoxAlignment = _keyAlignment.currentContext
                            ?.findRenderObject() as RenderBox;
                        final widgetOffset =
                            renderBoxAlignment.localToGlobal(Offset.zero);
                        setState(() {
                          _isShowAlignmentDialog = true;
                          _alignmentDialogOffset = widgetOffset;
                        });
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
                                paddingAttribute: _paddingOptions,
                                title: TITLE_PADDING,
                                inputValues: [
                                  _paddingOptions.horizontalPadding.toString(),
                                  _paddingOptions.verticalPadding.toString()
                                ],
                                onChanged: (index, value) {},
                                onDone: (newPaddingAttribute) {
                                  setState(() {
                                    _paddingOptions = newPaddingAttribute;
                                  });
                                  widget.reRenderFunction();
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
                                  spacingAttribute: _spacingOptions,
                                  inputValues: [
                                    _spacingOptions.horizontalSpacing
                                        .toString(),
                                    _spacingOptions.verticalSpacing.toString(),
                                  ],
                                  onChanged: (index, value) {},
                                  onDone: (newSpacingAttribute) {
                                    setState(() {
                                      _spacingOptions = newSpacingAttribute;
                                    });
                                    widget.reRenderFunction();
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
    void _disablePlacement() {
      setState(() {
        _selectedPlacement = null;
      });
      widget.reRenderFunction();
    }

    return GestureDetector(
      onTap: () {
        _disablePlacement();
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
            _disablePlacement();
          },
          child: Column(children: [
            Expanded(
                child: WDragZoomImage(
              backgroundColor: _currentLayoutColor,
              listGlobalKey: _listGlobalKey,
              matrix4Notifiers: _matrix4Notifiers,
              rerenderFunction: () {
                widget.reRenderFunction();
              },
              selectedPlacement: _selectedPlacement,
              paperAttribute: _project.paper,
              listPlacement: _listPlacement,
              onUpdatePlacement: (List<Rectangle1> rectangles,
                  Rectangle1? focusRectangle, List<double> ratios) {
                //parse rectangle to placement
                List<Placement> newListPlacement = [];
                for (int i = 0; i < rectangles.length; i++) {
                  newListPlacement.add(_listPlacement[i].copyWith(
                    ratioOffset: [
                      rectangles[i].x / ratios[0],
                      rectangles[i].y / ratios[1]
                    ],
                    ratioHeight: rectangles[i].height / ratios[1],
                    ratioWidth: rectangles[i].width / ratios[0],
                  ));
                }
                _listPlacement = newListPlacement;

                if (focusRectangle != null) {
                  final indexSelectedRect = rectangles.indexOf(focusRectangle);
                  if (indexSelectedRect != -1) {
                    _selectedPlacement = _listPlacement[indexSelectedRect];
                    _listPlacement.removeAt(indexSelectedRect);
                    _listPlacement.add(_selectedPlacement!);
                  }
                }
                setState(() {});
                widget.reRenderFunction();
              },
              onCancelFocusRectangle1: () {
                _disablePlacement();
              },
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
                          final newPlacement = _createNewPlacement();
                          _listPlacement.add(newPlacement); 
                          _listGlobalKey.add(GlobalKey());
                          _selectedPlacement = _listPlacement.last;
                        });
                        widget.reRenderFunction();
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  _selectedPlacement != null
                      ? WSpacer(
                          width: 10,
                        )
                      : const SizedBox(),
                  _selectedPlacement != null
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
                              final convertHeight = convertUnit(
                                  _project.paper!.unit!,
                                  _selectedPlacement!.placementAttribute!.unit!,
                                  _project.paper!.height);
                              final convertWidth = convertUnit(
                                  _project.paper!.unit!,
                                  _selectedPlacement!.placementAttribute!.unit!,
                                  _project.paper!.width);
                              // horizontal, vertical, top, left, right, bottom
                              // width and height is 0 and 1 to comparable with EditorPaddingSpacing (2 controller)
                              List<String> paddingAttributeList = [];
                              paddingAttributeList.add(((_selectedPlacement!
                                          .placementAttribute?.horizontal) ??
                                      0.0)
                                  .toString());
                              paddingAttributeList.add(((_selectedPlacement!
                                          .placementAttribute?.vertical) ??
                                      0.0)
                                  .toString());
                              //top
                              paddingAttributeList.add(
                                  (_selectedPlacement!.ratioOffset[1] *
                                          convertHeight)
                                      .toStringAsFixed(2));
                              //left
                              paddingAttributeList.add(
                                  (_selectedPlacement!.ratioOffset[0] *
                                          convertWidth)
                                      .toStringAsFixed(2));
                              //right
                              paddingAttributeList.add(((1 -
                                          (_selectedPlacement!.ratioOffset[0] +
                                              _selectedPlacement!.ratioWidth)) *
                                      convertWidth)
                                  .toStringAsFixed(2));
                              // bottom
                              paddingAttributeList.add(((1 -
                                          (_selectedPlacement!.ratioOffset[1] +
                                              _selectedPlacement!
                                                  .ratioHeight)) *
                                      convertHeight)
                                  .toStringAsFixed(2));
                              pushCustomVerticalMaterialPageRoute(
                                  context,
                                  EditorPaddingSpacing(
                                    placement: _selectedPlacement!,
                                    unit: (_selectedPlacement!
                                        .placementAttribute!.unit!),
                                    title: TITLE_EDIT_PLACEMENT,
                                    inputValues: paddingAttributeList,
                                    onChanged: (index, value) {},
                                    onDone: (newData) {
                                      _onDone(newData, paddingAttributeList,
                                          convertWidth, convertHeight);
                                      _disablePlacement();
                                    },
                                  ));
                            },
                          ),
                        )
                      : const SizedBox(),
                  _selectedPlacement != null
                      ? WSpacer(
                          width: 10,
                        )
                      : const SizedBox(),
                  _selectedPlacement != null
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
                                  _listPlacement.map((e) => e.id).toList().indexOf(_selectedPlacement!.id);
                              if (index != -1) {
                                _listPlacement.removeAt(index);
                                _matrix4Notifiers.removeAt(index);
                                _listGlobalKey.removeAt(index);
                              }
                              _selectedPlacement = null;
                              setState(() {});
                              widget.reRenderFunction();
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
}
