import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/convert.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/helpers/pdf/create_pdf.dart';
import 'package:photo_to_pdf/helpers/pick_media.dart';
import 'package:photo_to_pdf/helpers/scan_document.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/w_editor.dart';
import 'package:photo_to_pdf/widgets/w_button.dart';
import 'package:photo_to_pdf/widgets/project_items/w_project_item_bottom.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import 'package:photo_to_pdf/widgets/w_thumb_slider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class SelectedPhotosBody extends StatefulWidget {
  final Project project;
  final double sliderCompressionLevelValue;
  final Function(double)? onChangedSlider;
  final Function() reRenderFunction;
  final Function(Project project, String sizeValue, double sliderValue) onApply;
  final String sizeOfFileValue;
  const SelectedPhotosBody(
      {super.key,
      required this.project,
      required this.sliderCompressionLevelValue,
      required this.onChangedSlider,
      required this.reRenderFunction,
      required this.onApply,
      required this.sizeOfFileValue});

  @override
  State<SelectedPhotosBody> createState() => _SelectedPhotosBodyState();
}

class _SelectedPhotosBodyState extends State<SelectedPhotosBody> {
  late bool _isFocusProject;
  late Project _project;
  late String _sizeOfFileValue;
  late double _sliderValue;
  List<GlobalKey> _listGlobalKeyForImages = [];
  @override
  void initState() {
    super.initState();
    _isFocusProject = false;
    _project = widget.project;
    _sizeOfFileValue = widget.sizeOfFileValue;
    _sliderValue = widget.sliderCompressionLevelValue;
    _listGlobalKeyForImages =
        _project.listMedia.map((e) => GlobalKey()).toList();
  }

  _pickImages() async {
    List<File> result = await pickImage(ImageSource.gallery, true);
    _updateListMedia(result);
  }

  _scanDocument() async {
    List<String>? imagePaths = await scanDocument();
    if (imagePaths == null) return;
    _updateListMedia(imagePaths.map((e) => File(e)).toList());
  }

  _updateListMedia(List files) {
    _project = _project.copyWith(listMedia: [..._project.listMedia, ...files]);
    _listGlobalKeyForImages = [
      ..._listGlobalKeyForImages,
      ...files.map((e) => GlobalKey()).toList()
    ];
    setState(() {});
    widget.reRenderFunction();
    _getFileSize(_sliderValue);
  }

  void _getFileSize(
    double value,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    Future.delayed(const Duration(milliseconds: 100), () async {
      List<double> ratioWHImages = [];
      for (var key in _listGlobalKeyForImages) {
        final renderBox = key.currentContext?.findRenderObject() as RenderBox;
        final imageSize = renderBox.size;
        ratioWHImages.add(imageSize.width / imageSize.height);
      }
      // ignore: use_build_context_synchronously
      final pdfUint8List = await createPdfFile(
          _project, context, _getRatioProject(LIST_RATIO_PDF),
          compressValue: value, ratioWHImages: ratioWHImages);
      // render to file
      final pdfFile = await convertUint8ListToFilePDF(pdfUint8List);
      _sizeOfFileValue = convertByteUnit((await pdfFile.length()) / 1024);
      setState(() {});
      widget.reRenderFunction();
    });
    });
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      height: size.height * 0.95,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 15),
                child: WTextContent(
                  value: "Selected Photos",
                  textSize: 14,
                  textLineHeight: 16.71,
                  textColor: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
              _isFocusProject
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(),
                          WTextContent(
                            value: "Done",
                            textSize: 14,
                            textLineHeight: 16.71,
                            textColor: colorBlue,
                            onTap: () {
                              setState(() {
                                _isFocusProject = false;
                              });
                            },
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
          Expanded(
            child: Container(
              height: size.height * 404 / 791 * 0.9,
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10)),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isFocusProject = false;
                  });
                },
                child: ReorderableGridView.count(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  shrinkWrap: true,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  crossAxisCount: 3,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      final tempListProject = _project.listMedia;
                      final element = tempListProject.removeAt(oldIndex);
                      tempListProject.insert(newIndex, element);
                      _project = _project.copyWith(listMedia: tempListProject);
                    });
                    widget.reRenderFunction();
                  },
                  onDragStart: (dragIndex) {
                    setState(() {
                      _isFocusProject = true;
                    });
                  },
                  dragWidgetBuilderV2: DragWidgetBuilderV2.createByOldBuilder9(
                      (index, child) => WProjectItemHomeBottom(
                            key: ValueKey(_project.listMedia[index]),
                            project: _project,
                            isFocusByLongPress: _isFocusProject,
                            index: index,
                            onRemove: (value) async {},
                          )),
                  children: _project.listMedia.map((e) {
                    final index = _project.listMedia.indexOf(e);
                    return WProjectItemHomeBottom(
                      key: ValueKey(_project.listMedia[index]),
                      project: _project,
                      isFocusByLongPress: _isFocusProject,
                      index: index,
                      imageKeys: _listGlobalKeyForImages,
                      onRemove: (value) async {
                        int indexRemove = _project.listMedia.indexOf(value);
                        if (indexRemove != -1) {
                          List abc = List.from(_project.listMedia);
                          List<GlobalKey> listKeys =
                              List.from(_listGlobalKeyForImages);
                          abc.removeAt(indexRemove);
                          listKeys.removeAt(indexRemove);
                          _project = _project.copyWith(listMedia: abc);
                          _listGlobalKeyForImages = listKeys;
                          setState(() {});
                          widget.reRenderFunction();
                          _getFileSize(_sliderValue);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          WSpacer(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              WButtonFilled(
                message: "Add Photo",
                textColor: colorBlue,
                textLineHeight: 14.32,
                textSize: 12,
                height: 30,
                width: size.width * 0.3,
                backgroundColor: const Color.fromRGBO(22, 115, 255, 0.08),
                onPressed: () async {
                  _pickImages();
                },
                padding: EdgeInsets.zero,
              ),
              WSpacer(
                width: size.width * 0.05,
              ),
              WButtonFilled(
                message: "Scan",
                textColor: colorBlue,
                textLineHeight: 14.32,
                textSize: 12,
                height: 30,
                width: size.width * 0.3,
                backgroundColor: const Color.fromRGBO(22, 115, 255, 0.08),
                onPressed: () async {
                  await _scanDocument();
                },
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          WSpacer(
            height: 15,
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context).cardColor),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          WTextContent(
                            value: "Compression Level",
                            textFontWeight: FontWeight.w600,
                            textSize: 14,
                            textLineHeight: 16.71,
                            textColor:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          WTextContent(
                            value: widget.sliderCompressionLevelValue == 1.0
                                ? "Original"
                                : "${(widget.sliderCompressionLevelValue * 100).toStringAsFixed(0)}%",
                            textSize: 14,
                            textLineHeight: 16.71,
                            textColor: const Color.fromRGBO(10, 132, 255, 1),
                          ),
                        ],
                      ),
                    ),
                    SliderTheme(
                      data: const SliderThemeData(
                        trackHeight: 2,
                        activeTrackColor: colorBlue,
                        thumbShape: CustomSliderThumbCircle(
                            thumbRadius: 14.0,
                            borderColor: colorBlue,
                            borderWidth: 4.0,
                            backgroundColor: colorWhite,
                            thumbHeight: 24),
                      ),
                      child: Slider(
                        value: widget.sliderCompressionLevelValue,
                        onChanged: (value) {
                          widget.onChangedSlider!(value);
                          _sliderValue = value;
                          setState(() {});
                          widget.reRenderFunction();
                        },
                        min: 0,
                        max: 1,
                        onChangeEnd: (value) async {
                          _project = _project.copyWith(
                            compression: value,
                          );
                          _listGlobalKeyForImages =
                              List<GlobalKey>.from(_listGlobalKeyForImages);
                          setState(() {});
                          widget.reRenderFunction();
                          print("_sliderValue ${_sliderValue}");
                          _getFileSize(value);
                        },
                        thumbColor: colorWhite,
                        activeColor: colorBlue,
                        inactiveColor: const Color.fromRGBO(0, 0, 0, 0.1),
                      ),
                    )
                  ],
                ),
                WTextContent(
                  value: "Estimated Total Size: ${_sizeOfFileValue}",
                  textSize: 14,
                  textLineHeight: 16.71,
                  textColor: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ],
            ),
          ),
          buildBottomButton(
            context: context,
            onApply: () async {
              widget.onApply(_project, _sizeOfFileValue, _sliderValue);
              widget.reRenderFunction();
              popNavigator(context);
            },
            onCancel: () {
              popNavigator(context);
            },
          )
        ],
      ),
    );
  }
}
