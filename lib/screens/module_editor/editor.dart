import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart' as flutter_riverpod;
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/providers/project_provider.dart';
import 'package:photo_to_pdf/widgets/w_button.dart';
import 'package:photo_to_pdf/widgets/w_divider.dart';
import 'package:photo_to_pdf/widgets/w_project_item.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class Editor extends flutter_riverpod.ConsumerStatefulWidget {
  const Editor({
    super.key,
  });

  @override
  flutter_riverpod.ConsumerState<Editor> createState() => _EditorState();
}

class _EditorState extends flutter_riverpod.ConsumerState<Editor> {
  final TextEditingController _fileNameController =
      TextEditingController(text: "");
  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration.zero, () {
    _selectionList = [
      {
        "mediaSrc": "${pathPrefixIcon}icon_letter.png",
        "title": "Paper Size",
        "content": "Letter"
      },
      {
        "mediaSrc": "${pathPrefixIcon}icon_layout.png",
        "title": "Layout",
        "content": "Layout 1"
      },
      {
        "mediaSrc": "${pathPrefixIcon}icon_frame.png",
        "title": "Selected Photos",
        "content": "13 Photos"
      },
      {
        "mediaSrc": "${pathPrefixIcon}icon_frame_1.png",
        "title": "Cover Photos",
        "content": "None"
      },
    ];
    // });
  }

  late List _selectionList;

  TextStyle _buildTextStyleInputFileName(Color textColor) {
    return TextStyle(
        color: textColor,
        fontFamily: myCustomFont,
        fontWeight: FontWeight.w700,
        height: 19.09 / 16,
        fontSize: 16);
  }

  @override
  Widget build(BuildContext context) {
    final listProject = ref.watch(projectControllerProvider).listProject;
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
        body: SafeArea(
      child: Container(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //input
            Center(
              child: Container(
                alignment: Alignment.center,
                width: size.width * 0.9,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromRGBO(10, 132, 255, 1),
                    width: 2.0,
                  ),
                  color: const Color.fromRGBO(0, 0, 0, 0.03),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                height: 47,
                child: CupertinoTextField(
                  decoration: const BoxDecoration(),
                  style: const TextStyle(color: colorBlue),
                  controller: _fileNameController,
                  prefix: Container(
                    margin: const EdgeInsets.only(left: 15),
                    child: Text("File name",
                        style: _buildTextStyleInputFileName(
                            const Color.fromRGBO(0, 0, 0, 0.4))),
                  ),
                  placeholder: "Untitled",
                  placeholderStyle: _buildTextStyleInputFileName(colorBlue),
                ),
              ),
            ),
            //
            WSpacer(
              height: 10,
            ),
            // list image
            Expanded(
                child: Container(
              width: size.width * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromRGBO(0, 0, 0, 0.03),
              ),
              child: ReorderableGridView.count(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
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
                onDragStart: (dragIndex) {},
                children: listProject.map((e) {
                  final index = listProject.indexOf(e);
                  return WProjectItemEditor(
                    key: ValueKey(listProject[index]),
                    src: listProject[index],
                    isFocusByLongPress: false,
                    index: index,
                    title: "Page ${index + 1}",
                  );
                }).toList(),
              ),
            )),
            //
            SizedBox(
              height: size.height * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(children: [
                    WSpacer(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        WTextContent(
                          value: "${listProject.length} Pages",
                          textColor: const Color.fromRGBO(0, 0, 0, 0.5),
                          textLineHeight: 14.32,
                          textSize: 12,
                          textFontWeight: FontWeight.w600,
                        ),
                        WDivider(
                            width: 2,
                            height: 14,
                            color: const Color.fromRGBO(0, 0, 0, 0.1),
                            margin: const EdgeInsets.symmetric(horizontal: 10)),
                        WTextContent(
                          value: "File Size: ${"----"} MB",
                          textColor: const Color.fromRGBO(0, 0, 0, 0.5),
                          textLineHeight: 14.32,
                          textSize: 12,
                          textFontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    WSpacer(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSelection(
                            _selectionList[0]['mediaSrc'],
                            _selectionList[0]['title'],
                            _selectionList[0]['content']),
                        WSpacer(
                          width: 10,
                        ),
                        _buildSelection(
                            _selectionList[1]['mediaSrc'],
                            _selectionList[1]['title'],
                            _selectionList[1]['content']),
                      ],
                    ),
                    WSpacer(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSelection(
                            _selectionList[2]['mediaSrc'],
                            _selectionList[2]['title'],
                            _selectionList[2]['content']),
                        WSpacer(
                          width: 10,
                        ),
                        _buildSelection(
                            _selectionList[3]['mediaSrc'],
                            _selectionList[3]['title'],
                            _selectionList[3]['content']),
                      ],
                    ),
                  ]),
                  Container(
                    margin:
                        const EdgeInsets.only(bottom: 20, left: 10, right: 10),
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Flexible(
                          child: WButtonFilled(
                            message: "Close",
                            backgroundColor:
                                const Color.fromRGBO(0, 0, 0, 0.03),
                            height: 55,
                            textColor: const Color.fromRGBO(10, 132, 255, 1),
                            onPressed: () {},
                          ),
                        ),
                        WSpacer(
                          width: 10,
                        ),
                        Flexible(
                          child: WButtonFilled(
                            message: "Save to...",
                            height: 55,
                            textColor: colorWhite,
                            backgroundColor:
                                const Color.fromRGBO(10, 132, 255, 1),
                            onPressed: () {},
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }

  Widget _buildSelection(String mediaSrc, String title, String content,
      {Function()? function}) {
    final size = MediaQuery.sizeOf(context);
    return InkWell(
      onTap: function,
      child: Container(
        height: 60,
        width: size.width * 0.45,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color.fromRGBO(0, 0, 0, 0.03)),
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: size.width * 0.1,
              child: Image.asset(
                mediaSrc,
                height: 35,
              ),
            ),
            WSpacer(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WTextContent(
                  value: title,
                  textLineHeight: 14.32,
                  textFontWeight: FontWeight.w600,
                  textSize: 12,
                  textColor: const Color.fromRGBO(0, 0, 0, 0.4),
                ),
                WSpacer(
                  height: 5,
                ),
                WTextContent(
                  value: content,
                  textLineHeight: 19.09,
                  textSize: 16,
                  textColor: const Color.fromRGBO(10, 132, 255, 1),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
