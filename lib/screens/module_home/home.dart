import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart' as flutter_riverpod;
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/providers/project_provider.dart';
import 'package:photo_to_pdf/widgets/w_project_item.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

final testImageList = [
  "${pathPrefixImage}test_image_1.png",
  "${pathPrefixImage}test_image_2.png",
  "${pathPrefixImage}test_image_3.png",
];

class HomePage extends flutter_riverpod.ConsumerStatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  flutter_riverpod.ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends flutter_riverpod.ConsumerState<HomePage> {
  final String PHOTO_TO_PDF = "Photo to PDF";
  final String CONTENT_PHOTO_TO_PDF =
      "Easily create PDF documents from your photos";

  int _naviSelected = 0;
  late bool _galleryIsEmpty;
  late bool _isFocusProjectList;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      ref.read(projectControllerProvider.notifier).setProject(testImageList);
    });
    _isFocusProjectList = false;
    _galleryIsEmpty = false;
  }

  @override
  Widget build(BuildContext context) {
    final listProject = ref.watch(projectControllerProvider).listProject;
    return Scaffold(
        appBar: _galleryIsEmpty
            ? null
            : AppBar(
                centerTitle: true,
                title: WBuildTextContent(
                  value: "All Files",
                  textSize: 15,
                  textFontWeight: FontWeight.w700,
                  textLineHeight: 17.9,
                  textColor: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                shadowColor: transparent,
                actions: [
                  Center(
                    child: WBuildTextContent(
                        value: "Done",
                        textColor: Theme.of(context).textTheme.bodyLarge!.color,
                        textSize: 15,
                        textLineHeight: 17.9,
                        textFontWeight: FontWeight.w700,
                        onTap: () {
                          setState(
                            () {
                              _isFocusProjectList = false;
                            },
                          );
                        }),
                  )
                ],
                backgroundColor: grey.shade100),
        body: Stack(
          alignment: _galleryIsEmpty
              ? Alignment.center
              : AlignmentDirectional.topStart,
          children: [
            _galleryIsEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      WBuildTextContent(
                          value: PHOTO_TO_PDF,
                          textAlign: TextAlign.center,
                          textSize: 32,
                          textFontWeight: FontWeight.w700,
                          textLineHeight: 38.19),
                      WBuildSpacer(height: 10),
                      WBuildTextContent(
                          value: CONTENT_PHOTO_TO_PDF,
                          textAlign: TextAlign.center,
                          textSize: 14,
                          textFontWeight: FontWeight.w500,
                          textLineHeight: 16.71),
                      WBuildSpacer(height: 20),
                      _buildButtonSelect()
                    ],
                  )
                : ReorderableGridView.count(
                    padding: const EdgeInsets.only(top: 10),
                    shrinkWrap: true,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 2,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        final tempListProject = listProject;
                        final element = tempListProject.removeAt(oldIndex);
                        tempListProject.insert(newIndex, element);
                        ref
                            .read(projectControllerProvider.notifier)
                            .setProject(tempListProject);
                      });
                    },
                    onDragStart: (dragIndex) {
                      setState(() {
                        _isFocusProjectList = true;
                      });
                    },
                    children: listProject.map((e) {
                      final index = listProject.indexOf(e);
                      return WProjectItem(
                        key: ValueKey(listProject[index]),
                        src: listProject[index],
                        isFocusByLongPress: _isFocusProjectList,
                        index: index,
                      );
                    }).toList(),
                  ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const SizedBox(), _buildBottomNavigatorButtons()],
            )
          ],
        ));
  }

  Widget buildItem(String text) {
    return Card(
      key: ValueKey(text),
      child: Text(text),
    );
  }

  Widget _buildBottomNavigatorButtons() {
    return Container(
      color: grey.shade100,
      height: 112,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonNavi(
              iconValue: "${pathPrefixIcon}icon_union_files.png",
              name: "All Files",
              isSelected: _naviSelected == 0,
              onTap: () {
                setState(() {
                  _naviSelected = 0;
                });
              }),
          _buildButtonNaviPlus(),
          _buildButtonNavi(
              iconValue: "${pathPrefixIcon}icon_setting.png",
              name: "Settings",
              isSelected: _naviSelected == 2,
              onTap: () {
                setState(() {
                  _naviSelected = 2;
                });
              }),
        ],
      ),
    );
  }

  Widget _buildButtonSelect() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.only(bottom: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            shadowColor: colorLightBlue,
            elevation: 2,
            backgroundColor: colorBlue),
        onPressed: () {},
        child: SizedBox(
          width: 255,
          height: 60,
          // decoration: BoxDecoration(borderRadius: BorderRadius.circular(60)),
          child: Center(
            child: WBuildTextContent(
                value: "Select Photos",
                textFontWeight: FontWeight.w700,
                textSize: 15,
                textLineHeight: 34),
          ),
        ));
  }

  Widget _buildButtonNavi(
      {String? iconValue,
      String? name,
      bool? isSelected = false,
      Function()? onTap}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 50, maxHeight: 65),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            iconValue != null
                ? Image.asset(
                    iconValue,
                    color: isSelected == true
                        ? colorBlue
                        : colorBlack.withOpacity(0.8),
                    height: 32.76,
                    width: 26.63,
                  )
                : const SizedBox(),
            name != null
                ? WBuildTextContent(
                    value: name,
                    textSize: 13,
                    textColor: isSelected == true
                        ? colorBlue
                        : colorBlack.withOpacity(0.8),
                    textLineHeight: 15.51,
                    textFontWeight: FontWeight.w700)
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  Widget _buildButtonNaviPlus() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _naviSelected = 1;
        });
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        elevation: 10,
        shadowColor: const Color(0xFFB250FF),
      ),
      child: Container(
        width: 50.0,
        height: 50.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Color(0xFF4378FF),
              Color(0xFFB250FF),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.only(top: 7),
          child: Image.asset(
            "${pathPrefixIcon}icon_plus.png",
            scale: 4,
          ),
        ),
      ),
    );
  }
}
