import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/helpers/random_number.dart';
import 'package:photo_to_pdf/models/placement.dart';
import 'package:photo_to_pdf/screens/module_editor/bodies/body_background.dart';
import 'package:photo_to_pdf/widgets/w_button.dart';
import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/screens/module_editor/editor_padding_spacing.dart';
import 'package:photo_to_pdf/widgets/w_drag_zoom_image.dart';
import 'package:photo_to_pdf/widgets/w_editor.dart';
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
  List<ValueNotifier<Matrix4>> _matrix4Notifiers = [];
  List<Placement> _listPlacement = [];
  Placement? _seletedPlacement;

  // background variable
  late Color _currentLayoutColor;
  late List<double> _ratioTarget;
  @override
  void dispose() {
    super.dispose();
    _listAlignment = [];
    _matrix4Notifiers = [];
    _listPlacement = [];
    _seletedPlacement = null;
  }

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _resizeModeSelectedValue = _project.resizeAttribute ?? LIST_RESIZE_MODE[0];
    _segmentCurrentIndex = widget.segmentCurrentIndex;
    _listLayoutStatus = LIST_LAYOUT.map((e) {
      return {"mediaSrc": e, "isFocus": false};
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
    _listPlacement = _project.placements ?? [];
    _listPlacement.forEach((element) {
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
  }

  void _resetLayoutSelections() {
    _listLayoutStatus = _listLayoutStatus = LIST_LAYOUT.map((e) {
      return {"mediaSrc": e, "isFocus": false};
    }).toList();
  }

  String _renderPreviewPaddingOptions() {
    return "${_paddingOptions.horizontalPadding} ${_paddingOptions.unit?.value} , ${_paddingOptions.verticalPadding} ${_paddingOptions.unit?.value}";
  }

  String _renderPreviewSpacingOptions() {
    return "${_spacingOptions.horizontalSpacing} ${_spacingOptions.unit?.value} , ${_spacingOptions.verticalSpacing} ${_spacingOptions.unit?.value}";
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.sizeOf(context);
    return Column(
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
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children:
                                  _listLayoutStatus.sublist(0, 2).toList().map(
                                (e) {
                                  final index = _listLayoutStatus.indexOf(e);
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: buildLayoutWidget(
                                      context: context,
                                      mediaSrc: e['mediaSrc'],
                                      title: "Layout ${index + 1}",
                                      isFocus: e['isFocus'],
                                      backgroundColor: _currentLayoutColor,
                                      indexLayoutItem: index,
                                      onTap: () {
                                        _resetLayoutSelections();
                                        setState(() {
                                          _listLayoutStatus[index]['isFocus'] =
                                              true;
                                        });
                                        widget.reRenderFunction();
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: _listLayoutStatus
                                  .sublist(2, _listLayoutStatus.length)
                                  .toList()
                                  .map(
                                (e) {
                                  final index = _listLayoutStatus.indexOf(e);
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: buildLayoutWidget(
                                      context: context,
                                      mediaSrc: e['mediaSrc'],
                                      title: "Layout ${index + 1}",
                                      isFocus: e['isFocus'],
                                      indexLayoutItem: index,
                                      backgroundColor: _currentLayoutColor,
                                      onTap: () {
                                        setState(() {
                                          _resetLayoutSelections();
                                          _listLayoutStatus[index]['isFocus'] =
                                              true;
                                        });
                                        widget.reRenderFunction();
                                      },
                                    ),
                                  );
                                },
                              ).toList())
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
            if (_segmentCurrentIndex == 0) {
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
                  placements: _listPlacement,
                  useAvailableLayout: true);
            } else if (_segmentCurrentIndex == 1) {
              _project = _project.copyWith(
                  layoutIndex: null,
                  resizeAttribute: _resizeModeSelectedValue,
                  alignmentAttribute: _listAlignment
                      .where((element) => element['isFocus'] == true)
                      .toList()
                      .first['alignment'],
                  backgroundColor: _currentLayoutColor,
                  placements: _listPlacement,
                  useAvailableLayout: false);
            }
            widget.onApply(_project, _segmentCurrentIndex);
          },
          onCancel: () {
            popNavigator(context);
          },
        )
      ],
    );
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
                              widget.reRenderFunction();
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
                          .first['alignment']
                          .title,
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
                                  return {'alignment': e, "isFocus": false};
                                }).toList();
                                _listAlignment[index]["isFocus"] = true;
                              });
                              widget.reRenderFunction();
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

  Widget _buildCustomArea(
    Function rerenderFunction,
  ) {
    void _disablePlacement() {
      setState(() {
        _seletedPlacement = null;
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
              reRenerFunction: rerenderFunction,
              listPlacement: _listPlacement,
              matrix4Notifiers: _matrix4Notifiers,
              updatePlacement: (placements) {
                setState(() {
                  _listPlacement = placements;
                });
                widget.reRenderFunction();
              },
              onFocusPlacement: (placement, matrix4) {
                // setState(() {
                //   int index = _listPlacement.indexWhere(
                //     (element) {
                //       return element.id == placement.id;
                //     },
                //   );
                //   if (index != -1) {
                //     _matrix4Notifiers.removeAt(index);
                //     _matrix4Notifiers.add(matrix4);
                //     _listPlacement.removeAt(index);
                //     _listPlacement.add(placement);
                //   }
                // });
                // widget.reRenderFunction();
                setState(() {
                  _seletedPlacement = placement;
                });
                widget.reRenderFunction();
              },
              seletedPlacement: _seletedPlacement,
              paperAttribute: _project.paper,
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
                              id: getRandomNumber(),
                              width: 70,
                              height: 70,
                              offset: Offset(
                                  _size.width * _ratioTarget[0] / 2 - 35,
                                  _size.width * _ratioTarget[1] / 2 - 35),
                              placementAttribute: PLACEMENT_ATTRIBUTE));
                          _seletedPlacement = _listPlacement.last;
                        });
                        widget.reRenderFunction();
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
                                    placement: _seletedPlacement,
                                    unit: (_seletedPlacement!
                                        .placementAttribute!.unit!),
                                    title: TITLE_EDIT_PLACEMENT,
                                    // width and height is 0 and 1 to comparable with EditorPaddingSpacing (2 controller)
                                    inputValues: [
                                      _seletedPlacement!
                                          .placementAttribute!.horizontal
                                          .toString(),
                                      _seletedPlacement!
                                          .placementAttribute!.vertical
                                          .toString(),
                                      _seletedPlacement!.placementAttribute!.top
                                          .toString(),
                                      _seletedPlacement!
                                          .placementAttribute!.left
                                          .toString(),
                                      _seletedPlacement!
                                          .placementAttribute!.right
                                          .toString(),
                                      _seletedPlacement!
                                          .placementAttribute!.bottom
                                          .toString(),
                                    ],
                                    onChanged: (index, value) {},
                                    onDone: (newData) {
                                      for (var placement in _listPlacement) {
                                        if (placement.id == newData.id) {
                                          final index =
                                              _listPlacement.indexOf(placement);
                                          _listPlacement[index] =
                                              _listPlacement[index].copyWith(
                                                  placementAttribute: newData
                                                      .placementAttribute);
                                        }
                                      }
                                      _disablePlacement();
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
