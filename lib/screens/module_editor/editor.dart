import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:photo_to_pdf/helpers/pdf_file_helper.dart';
import 'package:photo_to_pdf/screens/module_editor/bodies/body_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as flutter_riverpod;
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/extract_list.dart';
import 'package:photo_to_pdf/helpers/random_number.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/providers/project_provider.dart';
import 'package:photo_to_pdf/screens/module_editor/bodies/body_paper.dart';
import 'package:photo_to_pdf/screens/module_editor/bodies/body_cover_photos.dart';
import 'package:photo_to_pdf/screens/module_editor/bodies/body_selected_photos.dart';
import 'package:photo_to_pdf/screens/module_pdf/hello.dart';
import 'package:photo_to_pdf/screens/module_pdf/preview_pdf.dart';
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
  late bool _paperSizeIsPortrait = true;
  int? _indexPageSizeSelectionWidget;

  late dynamic _paperConfig;
  late dynamic _layoutConfig;
  late dynamic _photosConfig;
  late dynamic _coverConfig;
  // selected photos
  late double _sliderCompressionValue;
  late List pdfFiles;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _fileNameController.text =
        _project.title == "Untitled" ? "" : _project.title;

    _paperConfig = {
      "mediaSrc": "${pathPrefixIcon}icon_letter.png",
      "title": "Paper Size",
      "content": _project.paper ?? LIST_PAGE_SIZE[5]
    };

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
    _sliderCompressionValue = _project.compression;
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
                          onApply: () async {
                            pushCustomMaterialPageRoute(
                                context, PdfViewerPage());
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
                  onApply: (project) {
                    _project = project;
                    _layoutConfig = {
                      ..._layoutConfig,
                      "content": "Layout ${_project.layoutIndex + 1}"
                    };
                    setState(() {});
                    popNavigator(context);
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
                  pageSizeIsPortrait: _paperSizeIsPortrait,
                  onApply: (newPaper, pageSizeIsPortrait) {
                    _project = _project.copyWith(paper: newPaper);
                    _paperSizeIsPortrait = pageSizeIsPortrait;
                    setState(() {});
                    popNavigator(context);
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
                  _project = _project.copyWith(
                      listMedia: newProject.listMedia,
                      compression: newProject.compression);
                  _photosConfig = {
                    ..._photosConfig,
                    "content": "${_project.listMedia.length} Photos"
                  };
                });
                setStatefull(() {});
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
                onUpdatePhoto: (newCoverPhoto) {
                  if (newCoverPhoto.backPhoto != null &&
                      newCoverPhoto.frontPhoto != null) {
                    _coverConfig["content"] = "Edit";
                  } else {
                    _coverConfig["content"] = "None";
                  }
                  _project = _project.copyWith(coverPhoto: newCoverPhoto);
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

  Widget _buildPreviewProjectBody() {
    if (_project.useAvailableLayout != true &&
        _project.placements != null &&
        _project.placements!.isNotEmpty) {
      List list = extractList(_project.placements!.length, _project.listMedia);
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
          return const SizedBox();
        }
      }
    }
  }

}
