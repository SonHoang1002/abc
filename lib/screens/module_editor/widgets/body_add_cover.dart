import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/helpers/pick_image.dart';
import 'package:photo_to_pdf/models/cover_photo.dart';
import 'package:photo_to_pdf/screens/module_editor/widgets/w_editor.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class AddCoverBody extends StatefulWidget {
  final CoverPhoto coverPhoto;
  final Function(CoverPhoto newPhoto) onUpdatePhoto;
  final Function() reRenderFunction;
  const AddCoverBody(
      {super.key,
      required this.coverPhoto,
      required this.onUpdatePhoto,
      required this.reRenderFunction});

  @override
  State<AddCoverBody> createState() => _AddCoverBodyState();
}

class _AddCoverBodyState extends State<AddCoverBody> {
  late CoverPhoto _coverPhoto;
  final GlobalKey _frontKey = GlobalKey();
  final GlobalKey _backKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _coverPhoto = widget.coverPhoto;
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
            margin: const EdgeInsets.only(top: 10),
            child: WTextContent(
              value: "Add Cover",
              textSize: 14,
              textLineHeight: 16.71,
              textColor: Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 20, right: 10, left: 10),
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  Flexible(
                      child: _buildCoverItem(
                          context: context,
                          label: "frontPhoto",
                          key: _frontKey,
                          src: _coverPhoto.frontPhoto,
                          onSelectedCoverImage: updatePhoto)),
                  WSpacer(
                    width: 10,
                  ),
                  Flexible(
                      child: _buildCoverItem(
                          context: context,
                          label: "backPhoto",
                          key: _backKey,
                          src: _coverPhoto.backPhoto,
                          onSelectedCoverImage: updatePhoto))
                ],
              ),
            ),
          ),
          buildBottomButton(context, () {
            widget.onUpdatePhoto(_coverPhoto);
          })
        ],
      ),
    );
  }

  _onTap(BuildContext context, String label, dynamic src, GlobalKey key) async {
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
          offset: offset,
          dialogWidget: buildDialogAddCover(context, (value) async {
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
          }));
    } else {
      final result = await pickImage(ImageSource.gallery, false);
      if (result.isNotEmpty) {
        updatePhoto(label, result[0]);
      }
    }
  }

  Widget _buildCoverItem(
      {required BuildContext context,
      required String label,
      required GlobalKey key,
      dynamic src,
      double? width,
      void Function(String label, String? src)? onSelectedCoverImage}) {
    return GestureDetector(
      onTap: () async {
        await _onTap(context, label, src, key);
      },
      child: Container(
        width: width,
        constraints: const BoxConstraints(maxHeight: 250, minHeight: 170),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).cardColor),
        child: src != null
            ? Center(
                key: key,
                child: src is File
                    ? Image.file(
                        src,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        src,
                        fit: BoxFit.cover,
                      ),
              )
            : Container(
                decoration: const BoxDecoration(
                    color: Color.fromRGBO(22, 115, 255, 0.08)),
                child: Center(
                  child: Image.asset(
                    src ?? "${pathPrefixIcon}icon_add.png",
                    color: const Color.fromRGBO(22, 115, 255, 1),
                    height: 14,
                    width: 14,
                  ),
                ),
              ),
      ),
    );
  }
}
