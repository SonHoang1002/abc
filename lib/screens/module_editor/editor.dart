import 'package:photo_to_pdf/helpers/convert_byte_unit.dart';
import 'package:photo_to_pdf/helpers/create_pdf.dart';
import 'package:photo_to_pdf/models/placement.dart';
import 'package:photo_to_pdf/screens/module_editor/bodies/body_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as flutter_riverpod;
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/extract_list.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/providers/project_provider.dart';
import 'package:photo_to_pdf/screens/module_editor/bodies/body_paper.dart';
import 'package:photo_to_pdf/screens/module_editor/bodies/body_cover_photos.dart';
import 'package:photo_to_pdf/screens/module_editor/bodies/body_selected_photos.dart';
import 'package:photo_to_pdf/screens/module_editor/preview.dart';
import 'package:photo_to_pdf/services/isar_project_service.dart';
import 'package:photo_to_pdf/widgets/w_editor.dart';
import 'package:photo_to_pdf/widgets/w_divider.dart';
import 'package:photo_to_pdf/widgets/project_items/w_project_item_main.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

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
  // late List _listProject;
  late Size _size;
  int? _indexPageSizeSelectionWidget;

  late dynamic _paperConfig;
  late dynamic _layoutConfig;
  late dynamic _photosConfig;
  late dynamic _coverConfig;
  // selected photos
  late double _sliderCompressionValue;
  late bool _autofocusFileName;
  late String _sizeOfFileValue;
  late int _segmentCurrentIndex;
  late int? _lengthOfProjectList;
  late bool _isShowPreview;
  late List<double> _previewRatio;
  late int? _currentCarouselIndex;
  @override
  void dispose() {
    super.dispose();
    _fileNameController.dispose();
    _indexPageSizeSelectionWidget = null;
    _paperConfig = null;
    _layoutConfig = null;
    _photosConfig = null;
    _coverConfig = null;
    _lengthOfProjectList = null;
  }

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _fileNameController.text =
        _project.title == "Untitled" ? "" : _project.title;

    _paperConfig = {
      "mediaSrc": {
        "light": "${pathPrefixIcon}icon_letter_lm.png",
        "dark": "${pathPrefixIcon}icon_letter_dm.png"
      },
      "title": "Paper Size",
      "content": _project.paper ?? LIST_PAGE_SIZE[5]
    };

    if (_project.useAvailableLayout) {
      _layoutConfig = {
        "mediaSrc": {
          "light": "${pathPrefixIcon}icon_layout_lm.png",
          "dark": "${pathPrefixIcon}icon_layout_dm.png",
        },
        "title": "Layout",
        "content": "Layout ${_project.layoutIndex + 1}"
      };
    } else {
      _layoutConfig = {
        "mediaSrc": {
          "light": "${pathPrefixIcon}icon_layout_lm.png",
          "dark": "${pathPrefixIcon}icon_layout_dm.png",
        },
        "title": "Layout",
        "content": "Edit"
      };
    }
    _photosConfig = {
      "mediaSrc": {
        "light": "${pathPrefixIcon}icon_frame_border_lm.png",
        "dark": "${pathPrefixIcon}icon_frame_border_dm.png",
      },
      "title": "Selected Photos",
      "content": "${_project.listMedia.length} Photos"
    };
    if (_project.coverPhoto?.frontPhoto != null ||
        _project.coverPhoto?.backPhoto != null) {
      _coverConfig = {
        "mediaSrc": {
          "light": "${pathPrefixIcon}icon_cover_lm.png",
          "dark": "${pathPrefixIcon}icon_cover_dm.png",
        },
        "title": "Cover Photos",
        "content": "Edit"
      };
    } else {
      _coverConfig = {
        "mediaSrc": {
          "light": "${pathPrefixIcon}icon_cover_lm.png",
          "dark": "${pathPrefixIcon}icon_cover_dm.png",
        },
        "title": "Cover Photos",
        "content": "None"
      };
    }
    _sliderCompressionValue = _project.compression;
    _autofocusFileName = _project.title == "Untitled" || _project.title == "";
    _sizeOfFileValue = "0.0 MB";
    _segmentCurrentIndex = _project.useAvailableLayout == true ? 0 : 1;
    _isShowPreview = false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _getFileSize();
    });
  }

  Future<void> _getFileSize() async {
    Future.delayed(Duration.zero, () async {
      _sizeOfFileValue = convertByteUnit(await getPdfFileSize(
          _project, context, _getRatioProject(LIST_RATIO_PDF),
          compressValue: _sliderCompressionValue));
      setState(() {});
    });
  }

  void _onTapFileNameInput() {
    _fileNameController.selection = TextSelection(
        baseOffset: 0, extentOffset: _fileNameController.value.text.length);
  }

  List<double> _getRatioProject(List<double> oldRatioTarget) {
    if (_project.paper?.width != null &&
        _project.paper?.width != 0 &&
        _project.paper?.height != null &&
        _project.paper?.height != 0) {
      final heightForWidth = (_project.paper!.height / _project.paper!.width);

      final result = [
        oldRatioTarget[0], oldRatioTarget[0] * heightForWidth
        // LIST_RATIO_PROJECT_ITEM[0],
        // heightForWidth/LIST_RATIO_PLACEMENT_BOARD[1] * LIST_RATIO_PLACEMENT_BOARD[0]
      ];
      return result;
    }
    return oldRatioTarget;
  }

  @override
  Widget build(BuildContext context) {
    // print("_currentCarouselIndex ${_currentCarouselIndex}");
    _size = MediaQuery.sizeOf(context);
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // input
                    buildFileNameInput(
                      context,
                      _project,
                      _fileNameController,
                      (value) async {
                        _project = _project.copyWith(title: value.trim());
                        ref
                            .read(projectControllerProvider.notifier)
                            .updateProject(_project);
                        await IsarProjectService().updateProject(_project);
                      },
                      autofocus: _autofocusFileName,
                      onTap: () {
                        _onTapFileNameInput();
                      },
                    ),
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
                                child: _buildPreviewProjectBody1()))),
                    // page size and bottom buttons
                    SizedBox(
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
                                  value: "$_lengthOfProjectList Pages",
                                  textColor: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
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
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10)),
                                WTextContent(
                                  value: "File Size: ${_sizeOfFileValue}",
                                  textColor: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
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
                              onApply: () async {
                                await createAndPreviewPdf(_project, context,
                                    _getRatioProject(LIST_RATIO_PDF),
                                    compressValue: _sliderCompressionValue);
                              },
                              onCancel: () {
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
              _isShowPreview
                  ? PreviewProject(
                      project: _project,
                      indexPage: _currentCarouselIndex!,
                      ratioTarget: _previewRatio,
                      onClose: () {
                        setState(() {
                          _isShowPreview = false;
                          _currentCarouselIndex = null;
                        });
                      })
                  : const SizedBox()
            ],
          ),
        ));
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
                child: LayoutBody(
                  project: _project,
                  reRenderFunction: () {
                    setState(() {});
                    setStatefull(() {});
                  },
                  segmentCurrentIndex: _segmentCurrentIndex,
                  onApply: (project, newSegmentIndex) async {
                    _project = project;
                    if (_project.useAvailableLayout) {
                      _layoutConfig = {
                        ..._layoutConfig,
                        "content": "Layout ${_project.layoutIndex + 1}"
                      };
                    } else {
                      _layoutConfig = {..._layoutConfig, "content": "Edit"};
                    }
                    ref
                        .read(projectControllerProvider.notifier)
                        .updateProject(project);
                    _segmentCurrentIndex = newSegmentIndex;
                    setState(() {});
                    await _getFileSize();
                    // ignore: use_build_context_synchronously
                    popNavigator(context);
                    await IsarProjectService().updateProject(project);
                  },
                ));
          });
        },
        isDismissible: false,
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
                  project: _project,
                  reRenderFunction: () {
                    setStatefull(() {});
                  },
                  indexPageSizeSelectionWidget: _indexPageSizeSelectionWidget,
                  paperConfig: _paperConfig,
                  onApply: (newPaper, pageSizeIsPortrait) async {
                    final oldPaper = _project.paper;
                    if (oldPaper != null && oldPaper != newPaper) {
                      List<Placement> newPlacements = [];
                      // tinh lai offset neu co placement
                      if (!_project.useAvailableLayout &&
                          _project.placements != null) {
                        var oldPlacements = _project.placements!;
                        oldPlacements.forEach((element) {
                          element.getInfor();
                        });
                        newPlacements = oldPlacements;
                        for (var item in oldPlacements) {
                          final index = oldPlacements.indexOf(item);
                          newPlacements[index] = newPlacements[index].copyWith(
                              offset: Offset(
                                  item.offset.dx /
                                      oldPaper.width *
                                      newPaper.width,
                                  item.offset.dy /
                                      oldPaper.height *
                                      newPaper.height));
                        }
                      }
                      _project = _project.copyWith(
                          paper: newPaper, placements: newPlacements);
                    } else {
                      _project = _project.copyWith(paper: newPaper);
                    }

                    setState(() {});
                    popNavigator(context);
                    await IsarProjectService().updateProject(_project);
                    await _getFileSize();
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
              sizeOfFileValue: _sizeOfFileValue,
              project: _project,
              sliderCompressionLevelValue: sliderCompressionLevelValue,
              onChangedSlider: (value) {
                setState(() {
                  sliderCompressionLevelValue = value;
                });
                setStatefull(() {});
              },
              onApply: (newProject, size, sliderValue) async {
                setState(() {
                  _project = _project.copyWith(
                      listMedia: newProject.listMedia,
                      compression: newProject.compression);
                  _photosConfig = {
                    ..._photosConfig,
                    "content": "${_project.listMedia.length} Photos"
                  };
                  _sizeOfFileValue = size;
                  _sliderCompressionValue = sliderValue;
                });
                setStatefull(() {});
                await IsarProjectService().updateProject(_project);
                await _getFileSize();
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
                return CoverBody(
                    project: _project,
                    onUpdatePhoto: (newCoverPhoto) async {
                      if (newCoverPhoto.backPhoto != null ||
                          newCoverPhoto.frontPhoto != null) {
                        _coverConfig["content"] = "Edit";
                      } else {
                        _coverConfig["content"] = "None";
                      }
                      _project = _project.copyWith(coverPhoto: newCoverPhoto);
                      setState(() {});
                      setStatefull(() {});
                      await IsarProjectService().updateProject(_project);
                      // ignore: use_build_context_synchronously
                      popNavigator(context);
                      await _getFileSize();
                    },
                    reRenderFunction: () {
                      setStatefull(() {});
                    });
              });
            },
            isScrollControlled: true,
            backgroundColor: transparent)
        .whenComplete(() {
      setState(() {});
    });
  }

  Widget _buildPreviewProjectBody1() {
    if (_project.useAvailableLayout != true &&
        _project.placements != null &&
        _project.placements!.isNotEmpty) {
      List list = extractList(_project.placements!.length, _project.listMedia);
      setState(() {
        _lengthOfProjectList = list.length;
      });
      return Wrap(
        alignment: WrapAlignment.center,
        children: list.map((e) {
          final index = list.indexOf(e);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: WProjectItemEditor1(
                key: ValueKey(_project.listMedia[index]),
                project: _project,
                isFocusByLongPress: false,
                indexImage: index,
                layoutExtractList: list[index],
                title: "Page ${index + 1}",
                onTap: () {
                  _previewRatio = LIST_RATIO_PREVIEW;
                  if (_project.paper != null &&
                      _project.paper!.height != 0 &&
                      _project.paper!.width != 0) {
                    _previewRatio = [
                      LIST_RATIO_PREVIEW[0],
                      LIST_RATIO_PREVIEW[0] *
                          _project.paper!.height /
                          _project.paper!.width
                    ];
                  }
                  setState(() {
                    _currentCarouselIndex = index;
                    _isShowPreview = true;
                  });
                },
                ratioTarget: _getRatioProject(LIST_RATIO_PROJECT_ITEM)),
          );
        }).toList(),
      );
    } else {
      if (_project.listMedia.isEmpty) {
        setState(() {
          _lengthOfProjectList = 0;
        });
        return Wrap(
          alignment: WrapAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: WProjectItemEditor(
                key: ValueKey(_project.id),
                project: _project
                    .copyWith(listMedia: ["${pathPrefixImage}blank_page.jpg"]),
                indexImage: 0,
                title: "Page ${1}",
                onTap: () {
                  _previewRatio = LIST_RATIO_PREVIEW;
                  if (_project.paper != null &&
                      _project.paper!.height != 0 &&
                      _project.paper!.width != 0) {
                    _previewRatio = [
                      LIST_RATIO_PREVIEW[0],
                      LIST_RATIO_PREVIEW[0] *
                          _project.paper!.height /
                          _project.paper!.width
                    ];
                  }
                  setState(() {
                    _currentCarouselIndex = 0;
                    _isShowPreview = true;
                  });
                },
                ratioTarget: _getRatioProject(LIST_RATIO_PROJECT_ITEM),
              ),
            )
          ],
        );
      } else {
        final abc = extractList1(
            LIST_LAYOUT_SUGGESTION[_project.layoutIndex], _project.listMedia);
        setState(() {
          _lengthOfProjectList = abc.length;
        });
        return Wrap(
          alignment: WrapAlignment.center,
          children: abc.map((e) {
            final index = abc.indexOf(e);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: WProjectItemEditor1(
                key: ValueKey(_project.listMedia[index]),
                project: _project,
                indexImage: index,
                layoutExtractList: abc[index],
                title: "Page ${index + 1}",
                onTap: () {
                  _previewRatio = LIST_RATIO_PREVIEW;
                  if (_project.paper != null &&
                      _project.paper!.height != 0 &&
                      _project.paper!.width != 0) {
                    _previewRatio = [
                      LIST_RATIO_PREVIEW[0],
                      LIST_RATIO_PREVIEW[0] *
                          _project.paper!.height /
                          _project.paper!.width
                    ];
                  }
                  setState(() {
                    _currentCarouselIndex = 0;
                    _isShowPreview = true;
                  });
                },
                ratioTarget: _getRatioProject(LIST_RATIO_PROJECT_ITEM),
              ),
            );
          }).toList(),
        );
      }
    }
  }
}
