import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/helpers/pick_media.dart';
import 'package:photo_to_pdf/models/cover_photo.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/screens/module_editor/bodies/body_dialogs.dart';
import 'package:photo_to_pdf/widgets/w_editor.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class BodyCover extends StatefulWidget {
  final Project project;
  final Function(CoverPhoto newPhoto) onUpdatePhoto;
  final Function() reRenderFunction;
  const BodyCover(
      {super.key,
      required this.project,
      required this.onUpdatePhoto,
      required this.reRenderFunction});

  @override
  State<BodyCover> createState() => _BodyCoverState();
}

class _BodyCoverState extends State<BodyCover> {
  late Project _project;
  late CoverPhoto _coverPhoto;
  final GlobalKey _frontKey = GlobalKey();
  final GlobalKey _backKey = GlobalKey();
  late double MAXHEIGHT;
  late double MAXWIDTH;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _coverPhoto =
        _project.coverPhoto ?? CoverPhoto(backPhoto: null, frontPhoto: null);
  }

  void updatePhoto(String label, dynamic src) {
    if (label == "backPhoto") {
      _coverPhoto =
          CoverPhoto(backPhoto: src, frontPhoto: _coverPhoto.frontPhoto);
    }
    if (label == "frontPhoto") {
      _coverPhoto =
          CoverPhoto(backPhoto: _coverPhoto.backPhoto, frontPhoto: src);
    }
    widget.reRenderFunction();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    MAXHEIGHT = MAXWIDTH = (size.width - 30) / 2;
    return Container(
      height: size.height * 0.5,
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
              value: "Add Cover",
              textSize: 14,
              textLineHeight: 16.71,
              textColor: Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 20, left: 20),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                      flex: 1,
                      child: Container(
                        child: _buildCoverItem(
                            context: context,
                            project: _project,
                            label: "frontPhoto",
                            scaleAlignment: Alignment.bottomLeft,
                            key: _frontKey,
                            src: _coverPhoto.frontPhoto,
                            onSelectedCoverImage: updatePhoto),
                      )),
                  WSpacer(
                    width: 20,
                  ),
                  Flexible(
                      flex: 1,
                      child: _buildCoverItem(
                          context: context,
                          project: _project,
                          label: "backPhoto",
                          key: _backKey,
                          scaleAlignment: Alignment.bottomRight,
                          src: _coverPhoto.backPhoto,
                          onSelectedCoverImage: updatePhoto))
                ],
              ),
            ),
          ),
          buildBottomButton(
            context: context,
            onApply: () {
              widget.onUpdatePhoto(_coverPhoto);
            },
            onCancel: () {
              popNavigator(context);
            },
          ),
          WSpacer(
            height: 10,
          )
        ],
      ),
    );
  }

  _onTap(BuildContext context, String label, dynamic src, GlobalKey key,
      Alignment scaleAlignment) async {
    if (src != null) {
      final renderBox = key.currentContext!.findRenderObject() as RenderBox;
      final originOffset = renderBox.localToGlobal(Offset.zero);
      Offset offset;
      if (label == "frontPhoto") {
        offset = originOffset;
      } else {
        offset = Offset(MediaQuery.sizeOf(context).width - 30 - 200,
            originOffset.dy); // 30 is padding , 200 is width of dialog
      }
      showLayoutDialogWithOffset(
          context: context,
          newScreen: BodyDialogCustom(
            offset: offset,
            dialogWidget: buildDialogAddCover(
              context,
              (value) async {
                final listKeyAddCover = LIST_ADD_COVER.map((element) {
                  return element['key'];
                }).toList();
                if (value['key'] == listKeyAddCover[0]) {
                  final result = await pickImage(ImageSource.gallery, false);
                  if (result.isNotEmpty) {
                    updatePhoto(label, result[0]);
                  }
                } else if (value['key'] == listKeyAddCover[1]) {
                  updatePhoto(label, null);
                }
                popNavigator(context);
              },
            ),
            scaleAlignment: scaleAlignment,
          ));
    } else {
      final result = await pickImage(ImageSource.gallery, false);
      if (result.isNotEmpty) {
        updatePhoto(label, result[0]);
      }
    }
  }

  List<double> _getWidthAndHeight(Project project) {
    var maxWidth = MAXWIDTH * 0.9;
    var maxHeight = MAXHEIGHT * 0.9;
    var width = maxWidth;
    var height = maxHeight;
    if (project.paper != null &&
        project.paper!.width != 0 &&
        project.paper!.height != 0) {
      final ratioPaperHW = project.paper!.height / project.paper!.width;
      // height > width
      if (ratioPaperHW > 1) {
        width = maxWidth;
        height = width * ratioPaperHW;
        if (height > maxHeight) {
          height = maxHeight;
          width = height * 1 / ratioPaperHW;
        }
        // height < width
      } else if (ratioPaperHW < 1) {
        height = maxHeight;
        width = height * 1 / ratioPaperHW;
        if (width > maxWidth) {
          width = maxWidth;
          height = width * ratioPaperHW;
        }
        // height == width
      } else {
        width = height = maxWidth;
      }
    }
    final result = [width, height];
    return result;
  }

  bool _checkPaperTitleIsNone(Project project) {
    return project.paper?.title == "None";
  }

  Widget _buildCoverItem(
      {required BuildContext context,
      required Project project,
      required String label,
      required GlobalKey key,
      required Alignment scaleAlignment,
      dynamic src,
      double? width,
      void Function(String label, String? src)? onSelectedCoverImage}) {
    return GestureDetector(
      onTap: () async {
        await _onTap(context, label, src, key, scaleAlignment);
      },
      child: Container(
        width: width,
        constraints: BoxConstraints(maxHeight: MAXHEIGHT, minHeight: MAXWIDTH),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).cardColor),
        child: src != null
            ? Center(
                key: key,
                child: src is File
                    ? (project.paper?.title == LIST_PAGE_SIZE[0].title)
                        ? Container(
                            constraints: const BoxConstraints(maxHeight: 140),
                            alignment: Alignment.center,
                            child: Image.file(
                              src,
                              fit: BoxFit.fill,
                              filterQuality: FilterQuality.high,
                            ),
                          )
                        : Image.file(
                            src,
                            fit: _checkPaperTitleIsNone(project)
                                ? BoxFit.fitWidth
                                : BoxFit.cover,
                            height: _checkPaperTitleIsNone(project)
                                ? null
                                : _getWidthAndHeight(project)[1],
                            width: _getWidthAndHeight(project)[0],
                          )
                    : Image.asset(
                        src,
                        fit: _checkPaperTitleIsNone(project)
                            ? BoxFit.fitWidth
                            : BoxFit.cover,
                        height: _checkPaperTitleIsNone(project)
                            ? null
                            : _getWidthAndHeight(project)[1],
                        width: _getWidthAndHeight(project)[0],
                      ),
              )
            : Center(
                child: Container(
                  height: _checkPaperTitleIsNone(project)
                      ? 140
                      : _getWidthAndHeight(project)[1],
                  width: _checkPaperTitleIsNone(project)
                      ? 140
                      : _getWidthAndHeight(project)[0],
                  decoration: const BoxDecoration(
                      color: Color.fromRGBO(22, 115, 255, 0.08)),
                  child: Center(
                    child: Image.asset(
                      src ?? "${PATH_PREFIX_ICON}icon_add.png",
                      color: const Color.fromRGBO(22, 115, 255, 1),
                      height: 14,
                      width: 14,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
