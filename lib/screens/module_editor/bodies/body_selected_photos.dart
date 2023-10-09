import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/helpers/compress_file.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/helpers/pdf_file_helper.dart';
import 'package:photo_to_pdf/helpers/pick_media.dart';
import 'package:photo_to_pdf/helpers/random_number.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/screens/module_editor/preview.dart';
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
  final Function(Project project) onApply;
  const SelectedPhotosBody({
    super.key,
    required this.project,
    required this.sliderCompressionLevelValue,
    required this.onChangedSlider,
    required this.reRenderFunction,
    required this.onApply,
  });

  @override
  State<SelectedPhotosBody> createState() => _SelectedPhotosBodyState();
}

class _SelectedPhotosBodyState extends State<SelectedPhotosBody> {
  late bool _isFocusProject;
  late Project _project;
  late List<dynamic> compressList;
  @override
  void initState() {
    super.initState();
    _isFocusProject = false;
    _project = widget.project;
    compressList = [];
  }

  _pickFiles() async {
    final result = await pickImage(ImageSource.gallery, true);
    _project = _project.copyWith(listMedia: [..._project.listMedia, ...result]);
    setState(() {});
    widget.reRenderFunction();
  }

  _pickImages() async {
    final result = await pickImage(ImageSource.gallery, true);
    _project = _project.copyWith(listMedia: [..._project.listMedia, ...result]);
    setState(() {});
    widget.reRenderFunction();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    print("compressList ${compressList}");
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
                children: _project.listMedia.map((e) {
                  final index = _project.listMedia.indexOf(e);
                  return WProjectItemHomeBottom(
                    key: ValueKey(_project.listMedia[index]),
                    project: _project,
                    isFocusByLongPress: _isFocusProject,
                    index: index,
                    onRemove: (value) {
                      setState(() {
                        _project = _project.copyWith(
                            listMedia: _project.listMedia
                                .where((element) => element != value)
                                .toList());
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          WSpacer(
            height: 5,
          ),
          SizedBox(
            width: size.width * 0.7,
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(
                  flex: 2,
                  child: WButtonFilled(
                    message: "Add Photo",
                    textColor: colorBlue,
                    textLineHeight: 14.32,
                    textSize: 12,
                    height: 30,
                    backgroundColor: const Color.fromRGBO(22, 115, 255, 0.08),
                    onPressed: () async {
                      _pickImages();
                    },
                    padding: EdgeInsets.zero,
                  ),
                ),
                WSpacer(
                  width: 10,
                ),
                Flexible(
                  flex: 2,
                  child: WButtonFilled(
                    message: "Add File",
                    height: 30,
                    textColor: colorBlue,
                    textLineHeight: 14.32,
                    textSize: 12,
                    backgroundColor: const Color.fromRGBO(22, 115, 255, 0.08),
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      _pickFiles();
                    },
                  ),
                ),
              ],
            ),
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
                        onChanged: widget.onChangedSlider,
                        min: 0,
                        max: 1,
                        onChangeEnd: (value) async {
                          // final newFiles =   await testCompressFile(
                          //       _project.listMedia as List<File>, value);
                          // _project = _project.copyWith(listMedia: newFiles);
                          // savePdf(SizedBox(), _project,"abcde${getRandomNumber()}");
                        },
                        thumbColor: colorWhite,
                        activeColor: colorBlue,
                        inactiveColor: const Color.fromRGBO(0, 0, 0, 0.1),
                      ),
                    )
                  ],
                ),
                WTextContent(
                  value: "Estimated Total Size: -- MB",
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
              widget.onApply(_project);
              final compressList1 = await testCompressFile(
                  _project.listMedia.map<File>((e) => File(e.path)).toList(),
                  widget.sliderCompressionLevelValue);
              // _project = _project.copyWith(listMedia: newFiles);
              setState(() {
                compressList = compressList1;
              });
              widget.reRenderFunction();
              await savePdf(SizedBox(), _project);
              pushNavigator(context, Preview(project: _project, indexPage: 0));
             
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
