import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/widgets/w_divider.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

Widget buildPageSizePreset(
    {required dynamic item,
    required Function() onTap,
    required bool isFocus,
    required Function(dynamic value) onSelected}) {
  return Flexible(
    child: GestureDetector(
      child: Container(
          height: 50,
          width: 200,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color.fromRGBO(0, 0, 0, 0.03),
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
                    textColor: const Color.fromRGBO(0, 0, 0, 0.5),
                    textFontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WTextContent(
                        value: item['content']["title"],
                        textSize: 14,
                        textLineHeight: 16.71,
                        textColor: const Color.fromRGBO(10, 132, 255, 1),
                      ),
                    ],
                  ),
                )
              ]),
              items: PAGE_SIZES.map((dynamic item) {
                final index = PAGE_SIZES.indexOf(item);
                return DropdownMenuItem<dynamic>(
                    value: item,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(),
                        WTextContent(
                          value: item['title'],
                          textColor: const Color.fromRGBO(10, 132, 255, 1),
                          textSize: 14,
                          textLineHeight: 19.09,
                        ),
                        index != PAGE_SIZES.length - 1
                            ? WDivider(
                                color: const Color.fromRGBO(0, 0, 0, 0.3),
                                width: 200,
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
                width: 200,
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
                maxHeight: 300,
                width: 185,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: colorWhite,
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
    ),
  );
}

Widget buildCupertinoInput(
    {required BuildContext context,
    required TextEditingController controller,
    required String title,
    required String suffixValue,
    required FocusNode focusNode,
    required Function() onTap,
    required bool isFocus,
    required Function(String value)? onChanged}) {
  return Container(
    width: 200,
    decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.03),
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
            color:
                isFocus ? const Color.fromRGBO(10, 132, 255, 1) : transparent,
            width: 2)),
    height: 47,
    child: CupertinoTextField(
      focusNode: focusNode,
      onTap: onTap,
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
            style: const TextStyle(
                color: Color.fromRGBO(0, 0, 0, 0.5),
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
                color: Color.fromRGBO(0, 0, 0, 0.5),
                fontFamily: myCustomFont,
                fontWeight: FontWeight.w700,
                height: 16.71 / 14,
                fontSize: 14)),
      ),
      placeholder: "Untitled",
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

Widget buildFileNameInput(
    BuildContext context, TextEditingController controller) {
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
        color: const Color.fromRGBO(0, 0, 0, 0.03),
        borderRadius: BorderRadius.circular(15.0),
      ),
      height: 47,
      child: CupertinoTextField(
        decoration: const BoxDecoration(),
        style: const TextStyle(color: colorBlue),
        controller: controller,
        prefix: Container(
          margin: const EdgeInsets.only(left: 15),
          child: Text("File name",
              style: buildTextStyleInputFileName(
                  const Color.fromRGBO(0, 0, 0, 0.4))),
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
