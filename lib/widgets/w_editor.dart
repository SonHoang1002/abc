import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/screens/module_editor/bodies/body_add_cover.dart';
import 'package:photo_to_pdf/widgets/w_button.dart';
import 'package:photo_to_pdf/widgets/w_divider.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';

///////////// PAGE SIZE ///////////////

Widget buildPageSizePreset(
    {required dynamic item,
    required BuildContext context,
    required Function() onTap,
    required bool isFocus,
    required Function(dynamic value) onSelected}) {
  return Flexible(
    child: Container(
        height: 50,
        width: 200 / 390 * MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).cardColor,
            border: Border.all(
                color: isFocus
                    ? const Color.fromRGBO(10, 132, 255, 1)
                    : transparent,
                width: 2)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<dynamic>(
            isExpanded: true,
            hint: Row(children: [
              Container(
                constraints: const BoxConstraints(minWidth: 55),
                child: WTextContent(
                  value: "Preset",
                  textSize: 14,
                  textLineHeight: 16.71,
                  textColor: Theme.of(context).textTheme.bodyMedium!.color,
                  textFontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    WTextContent(
                      value: item['content'].title,
                      textSize: 14,
                      textLineHeight: 16.71,
                      textColor: const Color.fromRGBO(10, 132, 255, 1),
                    ),
                  ],
                ),
              )
            ]),
            items: LIST_PAGE_SIZE.map((dynamic item) {
              final index = LIST_PAGE_SIZE.indexOf(item);
              return DropdownMenuItem<dynamic>(
                  value: item,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(),
                      WTextContent(
                        value: item.title,
                        textColor: const Color.fromRGBO(10, 132, 255, 1),
                        textSize: 14,
                        textLineHeight: 19.09,
                      ),
                      index != LIST_PAGE_SIZE.length - 1
                          ? WDivider(
                              color: const Color.fromRGBO(0, 0, 0, 0.3),
                              width:
                                  200 / 390 * MediaQuery.sizeOf(context).width,
                              height: 1,
                              margin: EdgeInsets.zero,
                            )
                          : const SizedBox()
                    ],
                  ));
            }).toList(),
            onChanged: (dynamic value) {
              onSelected(value);
            },
            onMenuStateChange: (bool isOpen) {
              onTap();
            },
            buttonStyleData: ButtonStyleData(
              height: 50,
              width: 200 / 390 * MediaQuery.sizeOf(context).width,
              padding: const EdgeInsets.only(left: 14, right: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            iconStyleData: IconStyleData(
              icon: Container(
                margin: const EdgeInsets.only(bottom: 5),
                child: const Icon(
                  FontAwesomeIcons.sortDown,
                  color: Color.fromRGBO(10, 132, 255, 1),
                  size: 15,
                ),
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: MediaQuery.sizeOf(context).height * 0.3,
              width: 185,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Theme.of(context).canvasColor,
              ),
              offset: const Offset(5, -5),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: MaterialStateProperty.all<double>(0),
                thumbVisibility: MaterialStateProperty.all<bool>(false),
              ),
            ),
          ),
        )),
  );
}

Widget buildCupertinoInput(
    {required BuildContext context,
    required TextEditingController controller,
    required String title,
    required String suffixValue,
    required Function() onTap,
    required bool isFocus,
    required Function(String value)? onChanged}) {
  return Container(
    width: 200 / 390 * MediaQuery.sizeOf(context).width,
    decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
            color:
                isFocus ? const Color.fromRGBO(10, 132, 255, 1) : transparent,
            width: 2)),
    height: 47,
    child: CupertinoTextField(
      onTap: () {
        controller.selection = TextSelection(
            baseOffset: 0, extentOffset: controller.text.trim().length);
        onTap();
      },
      onChanged: onChanged,
      decoration: const BoxDecoration(),
      style: const TextStyle(
          color: colorBlue,
          height: 16.71 / 14,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          fontFamily: myCustomFont),
      controller: controller,
      keyboardType: TextInputType.number,
      prefix: Container(
        constraints: const BoxConstraints(minWidth: 50),
        margin: const EdgeInsets.only(left: 15),
        child: Text(title,
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium!.color,
                fontFamily: myCustomFont,
                fontWeight: FontWeight.w700,
                height: 16.71 / 14,
                fontSize: 14)),
      ),
      suffix: Container(
        alignment: Alignment.centerLeft,
        constraints: const BoxConstraints(minWidth: 50),
        margin: const EdgeInsets.only(right: 30),
        child: Text(suffixValue,
            style: const TextStyle(
                color: Color.fromRGBO(10, 132, 255, 1),
                fontFamily: myCustomFont,
                fontWeight: FontWeight.w700,
                height: 16.71 / 14,
                fontSize: 14)),
      ),
      placeholder:  "Untitled",
      placeholderStyle: const TextStyle(
          color: colorBlue,
          fontFamily: myCustomFont,
          fontWeight: FontWeight.w700,
          height: 19.09 / 16,
          fontSize: 16),
    ),
  );
}

Widget buildPageSizeOrientationItem(
    {required String mediaSrc,
    required bool isSelected,
    required Function() onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: const Color.fromRGBO(
              0,
              0,
              0,
              0.03,
            ),
            border: isSelected
                ? Border.all(
                    color: isSelected ? colorBlue : transparent, width: 2)
                : null),
        height: 40,
        width: 40,
        padding: const EdgeInsets.all(10),
        child: Image.asset(
          mediaSrc,
          fit: BoxFit.cover,
        )),
  );
}

Widget buildFileNameInput(BuildContext context, Project project,
    TextEditingController controller, Function(String value) onChange) {
  TextStyle buildTextStyleInputFileName(Color textColor) {
    return TextStyle(
        color: textColor,
        fontFamily: myCustomFont,
        fontWeight: FontWeight.w700,
        height: 19.09 / 16,
        fontSize: 16);
  }

  return Center(
    child: Container(
      alignment: Alignment.center,
      width: MediaQuery.sizeOf(context).width * 0.9,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromRGBO(10, 132, 255, 1),
          width: 2.0,
        ),
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15.0),
      ),
      height: 47,
      child: CupertinoTextField(
        onChanged: onChange,
        decoration: const BoxDecoration(),
        style: const TextStyle(color: colorBlue),
        controller: controller,
        prefix: Container(
          margin: const EdgeInsets.only(left: 15),
          child: Text("File name",
              style: buildTextStyleInputFileName(
                  Theme.of(context).textTheme.bodyLarge!.color!)),
        ),
        placeholder: "Untitled",
        placeholderStyle: buildTextStyleInputFileName(colorBlue),
      ),
    ),
  );
}

Widget buildSelection(
    BuildContext context, String mediaSrc, String title, String content,
    {Function()? onTap}) {
  final size = MediaQuery.sizeOf(context);
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 60,
      width: size.width * 0.45,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).cardColor),
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: size.width * 0.1,
            child: Image.asset(
              mediaSrc,
              height: 35,
              // color: Theme.of(context).cardColor,
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
                textColor: Theme.of(context).textTheme.bodySmall!.color,
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

Widget buildBottomButton(
    {required BuildContext context,
    required void Function() onApply,
    String? titleApply,
    void Function()? onCancel}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
    child: Flex(
      direction: Axis.horizontal,
      children: [
        Flexible(
            child: WButtonFilled(
          message: "Cancel",
          backgroundColor: Theme.of(context).cardColor,
          textColor: colorBlue,
          height: 60,
          onPressed: () {
            onCancel != null ? onCancel() : null;
          },
        )),
        WSpacer(
          width: 20,
        ),
        Flexible(
            child: WButtonFilled(
          message: titleApply ?? "Apply",
          textColor: colorWhite,
          height: 60,
          backgroundColor: const Color.fromRGBO(10, 132, 255, 1),
          onPressed: onApply,
        ))
      ],
    ),
  );
}

///////////// LAYOUT ///////////////

Widget buildSegmentControl(
    {required BuildContext context,
    required int? groupValue,
    required void Function(int?) onValueChanged}) {
  return CupertinoSlidingSegmentedControl<int>(
    groupValue: groupValue,
    // _segmentCurrentIndex,
    backgroundColor: const Color.fromRGBO(0, 0, 0, 0.04),
    onValueChanged: onValueChanged,
    children: {
      0: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: WTextContent(
            value: "Presets",
            textColor: Theme.of(context).textTheme.titleLarge!.color,
            textSize: 14,
            textLineHeight: 16.71,
            textFontWeight: FontWeight.w600,
          )),
      1: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: WTextContent(
            value: "Custom",
            textColor: Theme.of(context).textTheme.titleLarge!.color,
            textSize: 14,
            textLineHeight: 16.71,
            textFontWeight: FontWeight.w600,
          ))
    },
  );
}

// general
Widget buildLayoutWidget({
  required BuildContext context,
  required String mediaSrc,
  required String title,
  required Color backgroundColor,
  required bool isFocus,
  required Function() onTap,
  required int indexLayoutItem,
}) {
  return Column(
    children: [
      GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  width: 2,
                  color: isFocus
                      ? const Color.fromRGBO(22, 115, 255, 1)
                      : transparent)),
          child: indexLayoutItem == 0
              ? _buildLayoutItem1(backgroundColor)
              : indexLayoutItem == 1
                  ? _buildLayoutItem2(backgroundColor)
                  : indexLayoutItem == 2
                      ? _buildLayoutItem34(backgroundColor)
                      : _buildLayoutItem34(backgroundColor, reverse: true),
        ),
      ),
      WSpacer(
        height: 15,
      ),
      GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isFocus ? const Color.fromRGBO(22, 115, 255, 1) : null),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          width: 80,
          child: Center(
            child: WTextContent(
              value: title,
              textLineHeight: 14.32,
              textSize: 12,
              textColor: isFocus
                  ? colorWhite
                  : Theme.of(context).textTheme.bodyMedium!.color,
              textFontWeight: FontWeight.w600,
            ),
          ),
        ),
      )
    ],
  );
}

Widget buildLayoutConfigItem(
    {required BuildContext context,
    required String title,
    required String content,
    required double width,
    Color? contentWidgetColor,
    Function()? onTap,
    Key? key}) {
  return GestureDetector(
    key: key,
    onTap: onTap,
    child: Container(
      width: width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).cardColor),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Column(children: [
        WTextContent(
          value: title,
          textSize: 12,
          textLineHeight: 14.32,
          textFontWeight: FontWeight.w600,
          textColor: Theme.of(context).textTheme.bodyMedium!.color,
        ),
        WSpacer(
          height: 10,
        ),
        contentWidgetColor != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: contentWidgetColor,
                        border: Border.all(
                            color: const Color.fromRGBO(0, 0, 0, 0.1),
                            width: 2),
                        borderRadius: BorderRadius.circular(47)),
                    height: 20,
                    width: 20,
                  ),
                  WSpacer(
                    width: 5,
                  ),
                  WTextContent(
                    value: content,
                    textSize: 14,
                    textLineHeight: 16.71,
                    textColor: const Color.fromRGBO(10, 132, 255, 1),
                  ),
                ],
              )
            : Center(
                child: WTextContent(
                  value: content,
                  textSize: 14,
                  textLineHeight: 16.71,
                  textColor: const Color.fromRGBO(10, 132, 255, 1),
                ),
              ),
      ]),
    ),
  );
}

Widget _buildLayoutItem1(Color backgroundColor) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
    decoration: BoxDecoration(color: backgroundColor, boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        spreadRadius: 0.5,
        blurRadius: 5,
        offset: const Offset(0, 1),
      ),
    ]),
    child: Center(
      child: Image.asset(
        "${pathPrefixIcon}icon_layout_11.png",
        fit: BoxFit.cover,
        height: 125,
      ),
    ),
  );
}

Widget _buildLayoutItem2(Color backgroundColor) {
  return Container(
    // height: 185,
    // width: 150,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
    decoration: BoxDecoration(color: backgroundColor, boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        spreadRadius: 0.5,
        blurRadius: 5,
        offset: const Offset(0, 1),
      ),
    ]),
    child: Center(
      child: Column(
        children: [
          Image.asset(
            "${pathPrefixIcon}icon_layout_21.png",
            fit: BoxFit.cover,
            height: 60,
          ),
          WSpacer(
            height: 5,
          ),
          Image.asset(
            "${pathPrefixIcon}icon_layout_21.png",
            fit: BoxFit.cover,
            height: 60,
          ),
        ],
      ),
    ),
  );
}

Widget _buildLayoutItem34(Color backgroundColor, {bool reverse = false}) {
  return Container(
    // height: 185,
    // width: 150,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
    decoration: BoxDecoration(color: backgroundColor, boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        spreadRadius: 0.5,
        blurRadius: 5,
        offset: const Offset(0, 1),
      ),
    ]),
    child: Center(
      child: !reverse
          ? Column(
              children: [
                Image.asset(
                  "${pathPrefixIcon}icon_layout_21.png",
                  fit: BoxFit.cover,
                  height: 60,
                ),
                WSpacer(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "${pathPrefixIcon}icon_layout_31.png",
                      fit: BoxFit.cover,
                      height: 60,
                    ),
                    WSpacer(
                      width: 5,
                    ),
                    Image.asset(
                      "${pathPrefixIcon}icon_layout_31.png",
                      fit: BoxFit.cover,
                      height: 60,
                    ),
                  ],
                )
              ],
            )
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "${pathPrefixIcon}icon_layout_31.png",
                      fit: BoxFit.cover,
                      height: 60,
                    ),
                    WSpacer(
                      width: 5,
                    ),
                    Image.asset(
                      "${pathPrefixIcon}icon_layout_31.png",
                      fit: BoxFit.cover,
                      height: 60,
                    ),
                  ],
                ),
                WSpacer(
                  height: 5,
                ),
                Image.asset(
                  "${pathPrefixIcon}icon_layout_21.png",
                  fit: BoxFit.cover,
                  height: 60,
                ),
              ],
            ),
    ),
  );
}

// resize mode
void showLayoutDialogWithOffset(
    {required BuildContext context,
    required Offset offset,
    required Widget dialogWidget}) {
  final size = MediaQuery.sizeOf(context);
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) {
      return Material(
        color: transparent,
        child: Stack(children: [
          Positioned.fill(child: GestureDetector(
            onTap: () {
              popNavigator(context);
            },
            // child: Container(color: Color.fromRGBO(0, 0, 0, 0.03)),
          )),
          Positioned(
              bottom: size.height - offset.dy,
              left: offset.dx,
              child: dialogWidget)
        ]),
      );
    },
  );
}

Widget buildDialogResizeMode(
    BuildContext context, Function(dynamic value) onSelected) {
  return Column(children: [
    _buildDialogInformationItem(
      context,
      LIST_RESIZE_MODE[0].mediaSrc,
      LIST_RESIZE_MODE[0].title,
      () => onSelected(
        LIST_RESIZE_MODE[0],
      ),
      boxDecoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        color: Theme.of(context).dialogBackgroundColor,
      ),
    ),
    WDivider(
      height: 1,
      color: const Color.fromRGBO(0, 0, 0, 0.3),
    ),
    _buildDialogInformationItem(
        context,
        LIST_RESIZE_MODE[1].mediaSrc,
        LIST_RESIZE_MODE[1].title,
        () => onSelected(
              LIST_RESIZE_MODE[1],
            ),
        boxDecoration:
            BoxDecoration(color: Theme.of(context).dialogBackgroundColor)),
    WDivider(
      height: 1,
      color: const Color.fromRGBO(0, 0, 0, 0.3),
    ),
    _buildDialogInformationItem(
      context,
      LIST_RESIZE_MODE[2].mediaSrc,
      LIST_RESIZE_MODE[2].title,
      () => onSelected(
        LIST_RESIZE_MODE[2],
      ),
      boxDecoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        color: Theme.of(context).dialogBackgroundColor,
      ),
    ),
  ]);
}

Widget buildDialogAlignment(BuildContext context, List<dynamic> datas,
    {Function(int index, dynamic value)? onSelected}) {
  // final size = MediaQuery.sizeOf(context);
  return Container(
    height: 200,
    width: 200,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).dialogBackgroundColor),
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildDialogAlignmentItem(
              context, datas[0]["mediaSrc"], datas[0]["title"], () {
            onSelected!(0, datas[0]);
          }, datas[0]["isFocus"]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildDialogAlignmentItem(
                  context, datas[1]["mediaSrc"], datas[1]["title"], () {
                onSelected!(1, datas[1]);
              }, datas[1]["isFocus"]),
              _buildDialogAlignmentItem(
                  context, datas[2]["mediaSrc"], datas[2]["title"], () {
                onSelected!(2, datas[2]);
              }, datas[2]["isFocus"]),
              _buildDialogAlignmentItem(
                  context, datas[3]["mediaSrc"], datas[3]["title"], () {
                onSelected!(3, datas[3]);
              }, datas[3]["isFocus"]),
            ],
          ),
          _buildDialogAlignmentItem(
              context, datas[4]["mediaSrc"], datas[4]["title"], () {
            onSelected!(4, datas[4]);
          }, datas[4]["isFocus"]),
        ]),
  );
}

Widget buildDialogPadding(
    {required BuildContext context,
    required List<String> listValue,
    required Function(int index, dynamic value) onChanged}) {
  final size = MediaQuery.sizeOf(context);
  final horizontalController = TextEditingController(text: listValue[0]);
  final verticalController = TextEditingController(text: listValue[1]);
  return Container(
    height: 150,
    padding: const EdgeInsets.all(10),
    alignment: Alignment.center,
    width: size.width * 0.9,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color.fromRGBO(255, 255, 255, 0.8)),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        WTextContent(
          value: "Padding",
          textColor: const Color.fromRGBO(0, 0, 0, 0.5),
          textLineHeight: 16.71,
          textSize: 14,
        ),
        Flex(direction: Axis.horizontal, children: [
          Flexible(
            child: Column(
              children: [
                _buildPaddingInput(
                  horizontalController,
                  (value) {
                    onChanged(0, value);
                  },
                ),
                WSpacer(
                  height: 7,
                ),
                WTextContent(
                  value: "Horizontal",
                  textSize: 12,
                  textFontWeight: FontWeight.w600,
                  textLineHeight: 14.32,
                  textColor: const Color.fromRGBO(0, 0, 0, 0.5),
                ),
              ],
            ),
          ),
          WSpacer(
            width: 20,
          ),
          Flexible(
            child: Column(
              children: [
                _buildPaddingInput(
                  verticalController,
                  (value) {
                    onChanged(1, value);
                  },
                ),
                WSpacer(
                  height: 7,
                ),
                WTextContent(
                  value: "Horizontal",
                  textSize: 12,
                  textFontWeight: FontWeight.w600,
                  textLineHeight: 14.32,
                  textColor: const Color.fromRGBO(0, 0, 0, 0.5),
                ),
              ],
            ),
          ),
        ]),
        const SizedBox()
      ],
    ),
  );
}

Widget buildDialogAddCover(
    BuildContext context, Function(dynamic value) onSelected) {
  return Column(children: [
    _buildDialogInformationItem(
      context,
      LIST_ADD_COVER[0]['mediaSrc'],
      LIST_ADD_COVER[0]['title'],
      () => onSelected(
        LIST_ADD_COVER[0],
      ),
      boxDecoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        color: Theme.of(context).dialogBackgroundColor,
      ),
    ),
    WDivider(
      height: 1,
      color: const Color.fromRGBO(0, 0, 0, 0.3),
    ),
    _buildDialogInformationItem(
        context,
        LIST_ADD_COVER[1]['mediaSrc'],
        LIST_ADD_COVER[1]['title'],
        () => onSelected(
              LIST_ADD_COVER[1],
            ),
        boxDecoration:
            BoxDecoration(color: Theme.of(context).dialogBackgroundColor)),
    WDivider(
      height: 1,
      color: const Color.fromRGBO(0, 0, 0, 0.3),
    ),
    _buildDialogInformationItem(
      context,
      LIST_ADD_COVER[2]['mediaSrc'],
      LIST_ADD_COVER[2]['title'],
      () => onSelected(
        LIST_ADD_COVER[2],
      ),
      textColor: const Color.fromRGBO(0, 0, 0, 0.5),
      boxDecoration: BoxDecoration(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(20)),
          color: Theme.of(context).dialogBackgroundColor),
    ),
  ]);
}

//////////////////////

Widget _buildPaddingInput(
    TextEditingController controller, void Function(String)? onChanged) {
  return Container(
      height: 30,
      width: 170,
      // padding: EdgeInsets.only(top: 5),
      alignment: Alignment.center,
      child: CupertinoTextField(
        onTap: () {},
        textAlign: TextAlign.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color.fromRGBO(255, 255, 255, 1),
            border: Border.all(
                color: const Color.fromRGBO(98, 161, 255, 1), width: 2)),
        style: const TextStyle(
          color: colorBlue,
          height: 16.71 / 14,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          fontFamily: myCustomFont,
        ),
        controller: controller,
      ));
}

Widget _buildDialogInformationItem(
    BuildContext context, String mediaSrc, String value, Function() onTap,
    {Color? textColor = const Color.fromRGBO(10, 132, 255, 1),
    BoxDecoration? boxDecoration}) {
  final size = MediaQuery.sizeOf(context);
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 135 / 3,
      width: (200 / 390) * size.width,
      decoration: boxDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Image.asset(
            mediaSrc,
            height: 14,
            width: 14,
          ),
          WSpacer(
            width: 10,
          ),
          WTextContent(
            value: value,
            textColor: textColor,
            textLineHeight: 16.71,
            textSize: 14,
          ),
        ],
      ),
    ),
  );
}

Widget _buildDialogAlignmentItem(BuildContext context, String mediaSrc,
    String value, Function()? onTap, bool isFocus) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 50,
      width: 50,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: isFocus
              ? const Color.fromRGBO(10, 132, 255, 1)
              : const Color.fromRGBO(22, 115, 255, 0.08)),
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Image.asset(
          mediaSrc,
          height: 14,
          width: 14,
          color: isFocus ? colorWhite : null,
        ),
      ),
    ),
  );
}
