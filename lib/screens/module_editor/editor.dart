import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:photo_to_pdf/helpers/firebase_helper.dart';
import 'package:photo_to_pdf/helpers/share_pdf.dart';
import 'package:photo_to_pdf/helpers/show_popup_review.dart';
import 'package:photo_to_pdf/providers/ratio_images_provider.dart';
import 'package:photo_to_pdf/screens/module_editor/bodies/body_saveTo.dart';
import 'package:share_plus/share_plus.dart';
import 'package:photo_to_pdf/helpers/convert.dart';
import 'package:photo_to_pdf/helpers/pdf/create_pdf.dart';
import 'package:photo_to_pdf/helpers/pdf/pdf_size.dart';
import 'package:photo_to_pdf/helpers/pdf/save_pdf.dart';
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
  late String _sizeOfFile;
  late int _segmentCurrentIndex;
  late int? _lengthOfProjectList;
  late bool _isShowPreview;
  late List<double> _previewRatio;
  late int? _indexCurrentCarousel;
  late bool _isLoading;
  // dung de luu tru ratio cua moi anh trong truong hop preset none, chi duoc update moi khi call _getFileSize() function
  List<GlobalKey> _listGlobalKeyForImages = [];
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
    _fileNameController.text = _project.title;
    _autofocusFileName = _project.title == "Untitled" || _project.title == "";

    _paperConfig = {
      "mediaSrc": {
        "light": "${PATH_PREFIX_ICON}icon_letter_lm.png",
        "dark": "${PATH_PREFIX_ICON}icon_letter_dm.png"
      },
      "title": "Paper Size",
      "content": _project.paper ?? LIST_PAGE_SIZE[0]
    };

    if (_project.useAvailableLayout) {
      _layoutConfig = {
        "mediaSrc": {
          "light": "${PATH_PREFIX_ICON}icon_layout_lm.png",
          "dark": "${PATH_PREFIX_ICON}icon_layout_dm.png",
        },
        "title": "Layout",
        "content": "Layout ${_project.layoutIndex + 1}"
      };
    } else {
      _layoutConfig = {
        "mediaSrc": {
          "light": "${PATH_PREFIX_ICON}icon_layout_lm.png",
          "dark": "${PATH_PREFIX_ICON}icon_layout_dm.png",
        },
        "title": "Layout",
        "content": "Edit"
      };
    }

    _photosConfig = {
      "mediaSrc": {
        "light": "${PATH_PREFIX_ICON}icon_frame_border_lm.png",
        "dark": "${PATH_PREFIX_ICON}icon_frame_border_dm.png",
      },
      "title": "Selected Photos",
      "content": "${_project.listMedia.length} Photos"
    };

    if (_project.coverPhoto?.frontPhoto != null ||
        _project.coverPhoto?.backPhoto != null) {
      _coverConfig = {
        "mediaSrc": {
          "light": "${PATH_PREFIX_ICON}icon_cover_lm.png",
          "dark": "${PATH_PREFIX_ICON}icon_cover_dm.png",
        },
        "title": "Cover Photos",
        "content": "Edit"
      };
    } else {
      _coverConfig = {
        "mediaSrc": {
          "light": "${PATH_PREFIX_ICON}icon_cover_lm.png",
          "dark": "${PATH_PREFIX_ICON}icon_cover_dm.png",
        },
        "title": "Cover Photos",
        "content": "None"
      };
    }

    _sliderCompressionValue = _project.compression;
    _sizeOfFile = "0.0 MB";
    _segmentCurrentIndex = _project.useAvailableLayout == true ? 0 : 1;
    _isShowPreview = false;
    _isLoading = false;
    _listGlobalKeyForImages =
        _project.listMedia.map((e) => GlobalKey()).toList();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _getFileSize();
      if (_autofocusFileName) {
        _fileNameController.selection = TextSelection(
            baseOffset: 0, extentOffset: _fileNameController.value.text.length);
      }
    });
  }

  void _updateRatioWHImages() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      List<double> listRatioWH = [];
      List<Size> testAbc = [];
      for (var key in _listGlobalKeyForImages) {
        final renderBox = key.currentContext?.findRenderObject() as RenderBox;
        final imageSize = renderBox.size;
        listRatioWH.add(imageSize.width / imageSize.height);
        testAbc.add(imageSize);
        ref
            .read(ratioWHImagesControllerProvider.notifier)
            .setRatioWHImages(listRatioWH);
      }
    });
  }

  Future<void> _getFileSize() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(milliseconds: 200), () async {
        // goi update lai ratioWH cua moi anh neu nhu preset dang la none
        if (_project.paper?.title == "None") {
          _updateRatioWHImages();
        }
        _sizeOfFile = convertByteUnit(await getPdfFileSize(
            _project, context, _getRatioProject(LIST_RATIO_PDF),
            compressValue: _sliderCompressionValue,
            ratioWHImages:
                ref.watch(ratioWHImagesControllerProvider).listRatioWH));
        setState(() {});
      });
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
      final result = [oldRatioTarget[0], oldRatioTarget[0] * heightForWidth];
      return result;
    }
    return oldRatioTarget;
  }

  Future<void> _onCancel() async {
    ref.read(projectControllerProvider.notifier).updateProject(_project);
    popNavigator(context);
    await IsarProjectService().updateProject(_project);
  }

  Future<void> _onShare(File file) async {
    popNavigator(context);
    sharePdf([
      XFile(file.path),
    ]);
    var isRating = await checkRating();
    // check xem da danh gia hay chua
    if (!isRating) {
      await ShowPopupReview.showPopupReview();
      await updateRating();
    }
  }

  Future<bool> _onSave(File file, String fileName) async {
    final pickedDirectory = await FlutterFileDialog.pickDirectory();

    if (pickedDirectory != null) {
      final result = await FlutterFileDialog.saveFileToDirectory(
        directory: pickedDirectory,
        data: file.readAsBytesSync(),
        mimeType: "application/pdf",
        fileName: fileName.split(".").first,
        replace: true,
      );
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.sizeOf(context);
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  bottom: MediaQuery.of(context).padding.bottom),
              child: WillPopScope(
                onWillPop: () async {
                  _onCancel();
                  return true;
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      child: Container(
                        color: transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // input
                            WSpacer(
                              height: 10,
                            ),
                            buildFileNameInput(
                              context,
                              _project,
                              _fileNameController,
                              (value) async {
                                _project =
                                    _project.copyWith(title: value.trim());
                                ref
                                    .read(projectControllerProvider.notifier)
                                    .updateProject(_project);
                                await IsarProjectService()
                                    .updateProject(_project);
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
                                    child: _buildPreviewProjectBody())),
                            // page size and bottom buttons
                            SizedBox(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(children: [
                                    WSpacer(height: 10),
                                    // information
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                            color: Theme.of(context).cardColor,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10)),
                                        WTextContent(
                                          value: "File Size: $_sizeOfFile",
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        buildEditorSelection(
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
                                        buildEditorSelection(
                                          context,
                                          _layoutConfig['mediaSrc'],
                                          _layoutConfig['title'],
                                          _layoutConfig['content'],
                                          onTap: () {
                                            if (_paperConfig['content'].title ==
                                                "None") {
                                              _showDialogWarningSelectPaperSize();
                                              return;
                                            }
                                            _showBottomSheetLayout();
                                          },
                                        ),
                                      ],
                                    ),
                                    WSpacer(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        buildEditorSelection(
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
                                                  _sliderCompressionValue =
                                                      value;
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
                                        buildEditorSelection(
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
                                      titleCancel: "Close",
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 15),
                                      onApply: () async {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        // createAndPreviewPdf(
                                        //   _project,
                                        //   context,
                                        //   _getRatioProject(LIST_RATIO_PDF),
                                        //   compressValue:
                                        //       _sliderCompressionValue,
                                        // );
                                        Uint8List data = await createPdfFile(
                                            _project,
                                            context,
                                            _getRatioProject(LIST_RATIO_PDF),
                                            compressValue:
                                                _sliderCompressionValue,
                                            ratioWHImages: ref
                                                .watch(
                                                    ratioWHImagesControllerProvider)
                                                .listRatioWH);
                                        final result = await savePdf(data,
                                            title: _project.title);
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        _showBottomSheetSaveTo(
                                            result["data"], result['fileName']);
                                      },
                                      onCancel: () async {
                                        await _onCancel();
                                      },
                                      titleApply: "Save to...")
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                        child: _isLoading
                            ? Container(
                                color: colorGrey.withOpacity(0.3),
                                child: const Center(
                                    child: CircularProgressIndicator(
                                  color: colorBlue,
                                )),
                              )
                            : const SizedBox())
                  ],
                ),
              ),
            ),
            _isShowPreview
                ? PreviewProject(
                    project: _project,
                    indexPage: _indexCurrentCarousel!,
                    ratioTarget: _previewRatio,
                    onClose: () {
                      setState(() {
                        _isShowPreview = false;
                        _indexCurrentCarousel = null;
                      });
                    })
                : const SizedBox(),
          ],
        ));
  }

  void _showDialogWarningSelectPaperSize() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(TITLE_LAYOUT_WARNING),
            content: const Text(CONTENT_LAYOUT_WARNING),
            backgroundColor: Theme.of(context).dialogBackgroundColor,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            actions: [
              TextButton(
                  onPressed: () {
                    popNavigator(context);
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(color: colorBlue),
                  )),
            ],
          );
        });
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
                child: BodyLayout(
                  project: _project,
                  reRenderFunction: () {
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
                    popNavigator(context);
                    await _getFileSize();
                    // ignore: use_build_context_synchronously
                    await IsarProjectService().updateProject(project);
                  },
                ));
          });
        },
        isDismissible: false,
        isScrollControlled: true,
        enableDrag: true,
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
              return BodyPaper(
                  project: _project,
                  reRenderFunction: () {
                    setStatefull(() {});
                  },
                  indexPageSizeSelectionWidget: _indexPageSizeSelectionWidget,
                  paperConfig: _paperConfig,
                  onApply: (newPaper, pageSizeIsPortrait) async {
                    _paperConfig['content'] = newPaper;
                    final oldPaper = _project.paper;
                    if (oldPaper != null && oldPaper != newPaper) {
                      List<Placement> newPlacements = [];
                      // tinh lai offset neu co placement va khong dung layout co san
                      if (!_project.useAvailableLayout &&
                          _project.placements != null) {
                        var oldPlacements = _project.placements!;
                        newPlacements = oldPlacements;
                        for (var item in oldPlacements) {
                          final index = oldPlacements.indexOf(item);
                          newPlacements[index] = newPlacements[index].copyWith(
                              ratioOffset: [
                                item.ratioOffset[0],
                                item.ratioOffset[1],
                              ],
                              ratioHeight: item.ratioHeight,
                              ratioWidth: item.ratioWidth);
                        }
                      }
                      // check preset is none -> return template 1 to render pdf list
                      if (newPaper.title == LIST_PAGE_SIZE[0].title) {
                        _project = _project.copyWith(
                            useAvailableLayout: true, layoutIndex: 0);
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
            return BodySelectedPhotos(
              reRenderFunction: () {
                setStatefull(() {});
              },
              sizeOfFileValue: _sizeOfFile,
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
                  _listGlobalKeyForImages =
                      newProject.listMedia.map((e) => GlobalKey()).toList();
                  _sizeOfFile = size;
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
                return BodyCover(
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

  Widget _buildPreviewProjectBody() {
    if (_project.listMedia.isEmpty ||
        (_project.listMedia.length == 1 && _project.listMedia[0] is String)) {
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
              project: _project.copyWith(listMedia: [BLANK_PAGE]),
              indexImage: 0,
              title: "Page ${1}",
              ratioWHImages:
                  ref.watch(ratioWHImagesControllerProvider).listRatioWH,
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
                  _indexCurrentCarousel = 0;
                  _isShowPreview = true;
                });
              },
              ratioTarget: _getRatioProject(LIST_RATIO_PROJECT_ITEM),
            ),
          )
        ],
      );
    } else {
      if (_project.useAvailableLayout != true &&
          _project.placements != null &&
          _project.placements!.isNotEmpty) {
        List list =
            extractList(_project.placements!.length, _project.listMedia);
        setState(() {
          _lengthOfProjectList = list.length;
        });
        return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 5,
              mainAxisSpacing: 2,
              crossAxisCount: 2,
              childAspectRatio: 9 / 10.5,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: _size.width * 0.4,
                height: 300,
                child: WProjectItemEditor(
                    key: ValueKey(_project.listMedia[index]),
                    project: _project,
                    isFocusByLongPress: false,
                    indexImage: index,
                    layoutExtractList: list[index],
                    title: "Page ${index + 1}",
                    ratioWHImages:
                        ref.watch(ratioWHImagesControllerProvider).listRatioWH,
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
                        _indexCurrentCarousel = index;
                        _isShowPreview = true;
                      });
                    },
                    ratioTarget: _getRatioProject(LIST_RATIO_PROJECT_ITEM)),
              );
            });
      } else {
        final abc = extractList1(
            LIST_LAYOUT_SUGGESTION[_project.layoutIndex], _project.listMedia);
        setState(() {
          _lengthOfProjectList = abc.length;
        });
        return GridView.builder(
          itemCount: abc.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            crossAxisCount: 2,
            childAspectRatio: 9 / 10.5,
          ),
          itemBuilder: (context, index) {
            return SizedBox(
              width: _size.width * 0.4,
              height: 300,
              child: WProjectItemEditor(
                key: ValueKey(_project.listMedia[index]),
                project: _project,
                indexImage: index,
                ratioWHImages:
                    ref.watch(ratioWHImagesControllerProvider).listRatioWH,
                layoutExtractList: abc[index],
                imageKey: _listGlobalKeyForImages[index],
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
                    _indexCurrentCarousel = index;
                    _isShowPreview = true;
                  });
                },
                ratioTarget: _getRatioProject(LIST_RATIO_PROJECT_ITEM),
              ),
            );
          },
        );
      }
    }
  }

  void _showBottomSheetSaveTo(File file, String fileName) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BodySaveTo(
            project: _project,
            onSave: () async {
              final result = await _onSave(file, fileName);
              return result;
            },
            onShare: () {
              _onShare(file);
            },
            fileSizeValue: _sizeOfFile,
          );
        },
        isScrollControlled: true,
        backgroundColor: transparent);
  }
}
