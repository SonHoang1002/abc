import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/commons/themes.dart';
import 'package:photo_to_pdf/helpers/extract_list.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/project_items/w_project_item_main.dart';
import 'package:photo_to_pdf/widgets/w_button.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import 'package:provider/provider.dart';

class BodySaveTo extends StatefulWidget {
  final Future<bool> Function()? onSave;
  final void Function()? onShare;
  // final void Function()? onPreview;
  final Project project;
  final String fileSizeValue;
  const BodySaveTo({
    super.key,
    required this.project,
    required this.onSave,
    required this.onShare,
    required this.fileSizeValue,
  });

  @override
  State<BodySaveTo> createState() => _BodySaveToState();
}

class _BodySaveToState extends State<BodySaveTo> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlayVideo = false;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        Navigator.pop(context);
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeManager>(context).isDarkMode;
    return Container(
      height: 500,
      decoration: BoxDecoration(
          color: isDarkMode
              ? const Color.fromRGBO(51, 51, 51, 1)
              : const Color.fromRGBO(245, 245, 245, 1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          )),
      padding: EdgeInsets.fromLTRB(
          15, 20, 15, MediaQuery.of(context).padding.bottom),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              popNavigator(context);
            },
            child: Image.asset(
              PATH_PREFIX_ICON +
                  (isDarkMode
                      ? "icon_close_bottom_dark.png"
                      : "icon_close_bottom_light.png"),
              height: 25,
            ),
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                _buildProjectItemHome(context),
                WSpacer(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    WTextContent(
                      value: "PDF Document",
                      textSize: 14,
                      textFontWeight: FontWeight.w500,
                      textLineHeight: 17.5,
                    ),
                    Container(
                      height: 4,
                      width: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 7),
                      decoration: BoxDecoration(
                          color: Theme.of(context).textTheme.bodySmall!.color,
                          borderRadius: BorderRadius.circular(3)),
                    ),
                    WTextContent(
                      value: widget.fileSizeValue,
                      textSize: 14,
                      textFontWeight: FontWeight.w500,
                      textLineHeight: 17.5,
                    )
                  ],
                ),
                WSpacer(
                  height: 30,
                ),
              ],
            ),
            if (_isPlayVideo)
              Lottie.asset(
                'assets/videos/video_lottie.json',
                controller: _controller,
                height: 150,
                width: 150,
                fit: BoxFit.fill,
              )
          ],
        ),
        WButtonFilled(
          message: "  Save to Files",
          mediaValue: "${PATH_PREFIX_ICON}icon_save.png",
          mediaSize: 30,
          height: 58,
          borderRadius: 20,
          backgroundColor: colorWhite,
          isVerticalAlignment: false,
          textColor: colorBlack,
          isHaveTextShadow: false,
          onPressed: () async {
            final result = await widget.onSave!();
            if (result) {
              _isPlayVideo = true;
              setState(() {
                _controller.reset();
                _controller.forward();
              });
            }
          },
        ),
        WSpacer(
          height: 10,
        ),
        WButtonFilled(
          message: "   Share",
          mediaValue: "${PATH_PREFIX_ICON}icon_share_pdf.png",
          mediaSize: 30,
          height: 58,
          borderRadius: 20,
          mediaColor: colorWhite,
          backgroundColor: colorBlue,
          isVerticalAlignment: false,
          textColor: colorWhite,
          isHaveTextShadow: false,
          onPressed: widget.onShare,
        ),
      ]),
    );
  }

  List<double> _getRatioProject(Project project, List<double> oldRatioTarget) {
    if (project.paper?.width != null &&
        project.paper?.width != 0 &&
        project.paper?.height != null &&
        project.paper?.height != 0) {
      final heightForWidth = (project.paper!.height / project.paper!.width);
      final result = [oldRatioTarget[0], oldRatioTarget[0] * heightForWidth];
      return result;
    }
    return oldRatioTarget;
  }

  List? _getEtractList(int index) {
    var result;
    if (widget.project.listMedia.isEmpty) return result;
    if (widget.project.paper?.title == LIST_PAGE_SIZE[0].title) {
      result =
          extractList1(LIST_LAYOUT_SUGGESTION[0], widget.project.listMedia);
    }
    if (widget.project.useAvailableLayout) {
      result = extractList1(LIST_LAYOUT_SUGGESTION[widget.project.layoutIndex],
          widget.project.listMedia)[0];
    } else {
      if (widget.project.placements != null) {
        result = extractList(
            widget.project.placements!.length, widget.project.listMedia)[0];
      }
    }
    return result;
  }

  Widget _buildProjectItemHome(BuildContext context) {
    return WProjectItemEditor(
      project: widget.project,
      isFocusByLongPress: false,
      indexImage: 0,
      useCoverPhoto: true,
      layoutExtractList: _getEtractList(0),
      title: widget.project.title,
      textSize: 16,
      textLineHeight: 20,
      textFontWeight: FontWeight.w700,
      textColor: Provider.of<ThemeManager>(context).isDarkMode
          ? colorWhite
          : colorBlack,
      ratioTarget: _getRatioProject(widget.project, LIST_RATIO_PROJECT_ITEM),
    );
  }
}
