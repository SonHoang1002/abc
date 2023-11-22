import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/commons/themes.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/project_items/w_layout_media_project.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import "package:provider/provider.dart" as pv;

// ignore: must_be_immutable
class WProjectItemEditor extends StatelessWidget {
  final Project project;
  final bool isFocusByLongPress;

  /// index of image on project
  final int indexImage;
  final Function()? onRemove;
  final String? title;
  final List<dynamic>? layoutExtractList;
  final Function()? onTap;
  final List<double>? ratioTarget;
  // kiem tra xem co uu tien dung anh bia de hien thi khong
  final bool? useCoverPhoto;
  // chi su dung key nay trong truong hop paper size la none,
  // nham muc dich lay ra ratio width - height cua anh, phuc vu cho viec tao pdf
  final GlobalKey? imageKey;

  WProjectItemEditor(
      {super.key,
      required this.project,
      required this.indexImage,
      this.isFocusByLongPress = false,
      this.title,
      this.onRemove,
      this.layoutExtractList,
      this.onTap,
      this.useCoverPhoto,
      this.imageKey,
      this.ratioTarget = LIST_RATIO_PROJECT_ITEM});

  double? maxHeight;
  double? maxWidth;
  late Size _size;

  double _getWidth(BuildContext context) {
    return (MediaQuery.sizeOf(context).width * 0.4) * (1 + ratioTarget![0]);
  }

  double _getHeight(BuildContext context) {
    return (MediaQuery.sizeOf(context).width * 0.3) * (1 + ratioTarget![1]);
  }

  List<double> _getRealWH(BuildContext context) {
    double realHeight;
    double realWidth = maxWidth!;
    if (project.paper != null &&
        project.paper!.height != 0 &&
        project.paper!.width != 0) {
      final ratioHW = project.paper!.height / project.paper!.width;
      // height > width
      if (ratioHW > 1) {
        realHeight = maxHeight!;
        realWidth = realHeight * (1 / ratioHW);
        // height < width
      } else if (ratioHW < 1) {
        realWidth = maxWidth!;
        realHeight = realWidth * ratioHW;
        // height = width
      } else {
        realHeight = realWidth = maxWidth!;
      }
      return [realWidth, realHeight];
    } else {
      return [_getWidth(context), _getHeight(context)];
    }
  }

  Widget _buildNormalLayoutMedia(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        width: _getRealWH(context)[0],
        height: _getRealWH(context)[1],
        decoration: BoxDecoration(color: project.backgroundColor, boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ]),
        child: LayoutMedia(
            indexImage: indexImage,
            project: project,
            layoutExtractList: layoutExtractList,
            widthAndHeight: _getRealWH(context),
            useCoverPhoto: useCoverPhoto,
            listWH: _getRealWH(context)),
      ),
    );
  }

  Widget _buildNoneLayoutMedia(BuildContext context) {
    return Container(
      width: _getRealWH(context)[0],
      decoration: BoxDecoration(color: project.backgroundColor, boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 0,
          blurRadius: 7,
          offset: const Offset(0, 2),
        ),
      ]),
      child: Image.file(
        layoutExtractList?[0][0],
        key: imageKey,
        fit: BoxFit.fitWidth,
        width: _getRealWH(context)[0], // delete height
        filterQuality: FilterQuality.high,
      ),
    );
  }

  Widget _buildMainRootItem(BuildContext context) {
    if (useCoverPhoto == true ||
        !(project.paper?.title == LIST_PAGE_SIZE[0].title &&
            layoutExtractList != null)) {
      return _buildNormalLayoutMedia(context);
    }
    return _buildNoneLayoutMedia(context);
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.sizeOf(context);
    maxHeight ??= _size.width * 0.35;
    maxWidth ??= _size.width * 0.35;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [const SizedBox(), _buildMainRootItem(context)],
                  ),
                  Container(
                      height: _getRealWH(context)[1] + 20,
                      width: _getRealWH(context)[0] + 20,
                      alignment: Alignment.topLeft,
                      child: Stack(
                        children: [
                          const SizedBox(
                            width: 30,
                            height: 30,
                          ),
                          isFocusByLongPress
                              ? Positioned.fill(
                                  top: -10,
                                  left: -10,
                                  child: GestureDetector(
                                    onTap: onRemove,
                                    child: Image.asset(
                                      pv.Provider.of<ThemeManager>(context)
                                              .isDarkMode
                                          ? "${PATH_PREFIX_ICON}icon_remove_dark.png"
                                          : "${PATH_PREFIX_ICON}icon_remove_light.png",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ))
                ],
              ),
              WSpacer(
                height: 10,
              ),
              WTextContent(
                value: title ?? "",
                textFontWeight: FontWeight.w600,
                textLineHeight: 14.32,
                textSize: 12,
                textColor: Theme.of(context).textTheme.bodyMedium!.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
