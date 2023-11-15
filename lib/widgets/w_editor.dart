import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/commons/themes.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/w_button.dart';
import 'package:photo_to_pdf/widgets/w_divider.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:provider/provider.dart' as pv;

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
            barrierColor: transparent,
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
                              width: 200 /
                                  390 *
                                  MediaQuery.sizeOf(context).width,
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
                color: pv.Provider.of<ThemeManager>(context).isDarkMode
                    ? Colors.black.withOpacity(0.9)
                    : Theme.of(context).canvasColor,
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
    required Function(String value)? onChanged,
    String? placeholder}) {
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
        margin: const EdgeInsets.only(right: 20),
        child: Text(suffixValue,
            style: const TextStyle(
                color: Color.fromRGBO(10, 132, 255, 1),
                fontFamily: myCustomFont,
                fontWeight: FontWeight.w700,
                height: 16.71 / 14,
                fontSize: 14)),
      ),
      placeholder: placeholder ?? "Untitled",
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
    {required BuildContext context,
    required String mediaSrc,
    required bool isSelected,
    required Function() onTap,
    EdgeInsets? padding}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: isSelected
                ? const Color.fromRGBO(22, 115, 255, 0.16)
                : Theme.of(context).cardColor,
            border: Border.all(
                color: isSelected ? colorBlue : transparent, width: 2)),
        height: 40,
        width: 40,
        padding: padding,
        child: Image.asset(
          mediaSrc,
          fit: BoxFit.fill,
          width: 35,
        )),
  );
}

Widget buildFileNameInput(BuildContext context, Project project,
    TextEditingController controller, Function(String value) onChange,
    {bool autofocus = false, Function()? onTap}) {
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
        onTap: onTap,
        prefix: Container(
          margin: const EdgeInsets.only(left: 15),
          child: Text("File name",
              style: buildTextStyleInputFileName(
                  Theme.of(context).textTheme.bodyLarge!.color!)),
        ),
        placeholder: "Untitled",
        placeholderStyle: buildTextStyleInputFileName(colorBlue),
        autofocus: autofocus,
      ),
    ),
  );
}

Widget buildSelection(BuildContext context, Map<String, dynamic> mediaSrc,
    String title, String content,
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
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: size.width * 0.1,
            child: Image.asset(
              !(pv.Provider.of<ThemeManager>(context).isDarkMode)
                  ? mediaSrc["light"]
                  : mediaSrc['dark'],
              height: 35,
            ),
          ),
          WSpacer(
            width: 5,
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
                textOverflow: TextOverflow.ellipsis,
                textColor: Theme.of(context).textTheme.bodySmall!.color,
              ),
              WSpacer(
                height: 5,
              ),
              WTextContent(
                value: content,
                textLineHeight: 19.09,
                textSize: 16,
                textOverflow: TextOverflow.ellipsis,
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
                onPressed: onCancel)),
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
  bool isDarkMode = pv.Provider.of<ThemeManager>(context).isDarkMode;
  return CupertinoSlidingSegmentedControl<int>(
    groupValue: groupValue,
    backgroundColor: Theme.of(context).tabBarTheme.unselectedLabelColor!,
    onValueChanged: onValueChanged,
    thumbColor: thumbColorSegments,
    children: {
      0: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: WTextContent(
            value: "Presets",
            textColor: !isDarkMode
                ? colorBlack
                : groupValue == 0
                    ? colorBlack
                    : const Color.fromRGBO(255, 255, 255, 0.7),
            textSize: 14,
            textLineHeight: 16.71,
            textFontWeight: FontWeight.w600,
          )),
      1: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: WTextContent(
            value: "Custom",
            textColor: !isDarkMode
                ? colorBlack
                : groupValue == 1
                    ? colorBlack
                    : const Color.fromRGBO(255, 255, 255, 0.7),
            textSize: 14,
            textLineHeight: 16.71,
            textFontWeight: FontWeight.w600,
          ))
    },
  );
}

// general

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

void showLayoutDialogWithOffset(
    {required BuildContext context, required Widget newScreen}) {
  showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return newScreen;
      },
      barrierColor: transparent);
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
    const WDivider(
        height: 1,
        // color: Color.fromRGBO(0, 0, 0, 0.1),
        color: Colors.black),
    _buildDialogInformationItem(
        context,
        LIST_RESIZE_MODE[1].mediaSrc,
        LIST_RESIZE_MODE[1].title,
        () => onSelected(
              LIST_RESIZE_MODE[1],
            ),
        boxDecoration:
            BoxDecoration(color: Theme.of(context).dialogBackgroundColor)),
    const WDivider(height: 1, color: Colors.black),
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
          _buildDialogAlignmentItem(context, datas[0]["alignment"].mediaSrc,
              datas[0]["alignment"].title, () {
            onSelected!(0, datas[0]);
          }, datas[0]["isFocus"]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildDialogAlignmentItem(context, datas[1]["alignment"].mediaSrc,
                  datas[1]["alignment"].title, () {
                onSelected!(1, datas[1]);
              }, datas[1]["isFocus"]),
              _buildDialogAlignmentItem(context, datas[2]["alignment"].mediaSrc,
                  datas[2]["alignment"].title, () {
                onSelected!(2, datas[2]);
              }, datas[2]["isFocus"]),
              _buildDialogAlignmentItem(context, datas[3]["alignment"].mediaSrc,
                  datas[3]["alignment"].title, () {
                onSelected!(3, datas[3]);
              }, datas[3]["isFocus"]),
            ],
          ),
          _buildDialogAlignmentItem(context, datas[4]["alignment"].mediaSrc,
              datas[4]["alignment"].title, () {
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
        color: Theme.of(context).dialogBackgroundColor),
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
    WDivider(height: 1, color: Theme.of(context).dividerColor),
    _buildDialogInformationItem(
        context,
        LIST_ADD_COVER[1]['mediaSrc'],
        LIST_ADD_COVER[1]['title'],
        () => onSelected(
              LIST_ADD_COVER[1],
            ),
        boxDecoration:
            BoxDecoration(color: Theme.of(context).dialogBackgroundColor)),
    WDivider(height: 1, color: Theme.of(context).dividerColor),
    _buildDialogInformationItem(
      context,
      LIST_ADD_COVER[2]['mediaSrc'],
      LIST_ADD_COVER[2]['title'],
      () => onSelected(
        LIST_ADD_COVER[2],
      ),
      textColor: Theme.of(context).textTheme.bodyMedium!.color,
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
            color: textColor,
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
