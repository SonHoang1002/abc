import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/commons/themes.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import 'package:provider/provider.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return SafeArea(
      child: Column(children: [
        // Container(
        //   alignment: Alignment.centerLeft,
        //   margin: const EdgeInsets.only(left: 20, top: 50),
        //   child: WTextContent(
        //     value: "Settings",
        //     textSize: 32,
        //     textLineHeight: 38,
        //     textColor: Theme.of(context).textTheme.bodyLarge!.color,
        //     textAlign: TextAlign.start,
        //   ),
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            WTextContent(
              value: "Settings",
              textSize: 32,
              textLineHeight: 38,
              textColor: Theme.of(context).textTheme.displayLarge!.color,
              textAlign: TextAlign.start,
            ),
            GestureDetector(
              onTap: () {
                bool isDarkMode =
                    Provider.of<ThemeManager>(context, listen: false)
                        .isDarkMode;
                if (isDarkMode) {
                  Provider.of<ThemeManager>(context, listen: false)
                      .toggleTheme("light");
                } else {
                  Provider.of<ThemeManager>(context, listen: false)
                      .toggleTheme("dark");
                }
              },
              child: WTextContent(
                value: Provider.of<ThemeManager>(context).isDarkMode
                    ? "Dark"
                    : "Light",
                textSize: 32,
                textLineHeight: 38,
                textColor: Theme.of(context).textTheme.displayLarge!.color,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
        WSpacer(
          height: 30,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                    color: Color.fromRGBO(20, 20, 20, 0.05),
                    spreadRadius: 5,
                    offset: Offset(0, 10),
                    blurRadius: 40)
              ],
              color: Theme.of(context).canvasColor,
              border: Border.all(
                  width: 1, color: const Color.fromRGBO(0, 0, 0, 0.05))),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "${pathPrefixIcon}icon_feedback.png",
                      height: 20,
                      width: 20,
                      color:  Theme.of(context).textTheme.displayLarge!.color,
                    ),
                    WSpacer(
                      width: 10,
                    ),
                    WTextContent(
                      value: "Write a feedback",
                      textSize: 15,
                      textLineHeight: 20,
                      textFontWeight: FontWeight.w500,
                      textColor:
                          Theme.of(context).textTheme.displayLarge!.color,
                    ),
                  ],
                ),
                const Icon(
                  FontAwesomeIcons.chevronRight,
                  size: 20,
                )
              ],
            ),
            WSpacer(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "${pathPrefixIcon}icon_share.png",
                      height: 20,
                      width: 20,
                      color: Theme.of(context).textTheme.displayLarge!.color,
                    ),
                    WSpacer(
                      width: 10,
                    ),
                    WTextContent(
                      value: "Share this app",
                      textSize: 15,
                      textLineHeight: 20,
                      textFontWeight: FontWeight.w500,
                      textColor:
                          Theme.of(context).textTheme.displayLarge!.color,
                    ),
                  ],
                ),
                const Icon(
                  FontAwesomeIcons.chevronRight,
                  size: 20,
                )
              ],
            )
          ]),
        ),
        WSpacer(
          height: 30,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(20, 20, 20, 0.05),
                spreadRadius: 5,
                blurRadius: 40,
                offset: Offset(0, 10),
              ),
            ],
            color: Theme.of(context).canvasColor,
            border: Border.all(
              width: 1,
              color: const Color.fromRGBO(0, 0, 0, 0.05),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "${pathPrefixIcon}icon_access_setting.png",
                    height: 20,
                    width: 20,
                    color: Theme.of(context).textTheme.displayLarge!.color,
                  ),
                  WSpacer(
                    width: 10,
                  ),
                  WTextContent(
                    value: "Photo Access Settings",
                    textSize: 15,
                    textLineHeight: 20,
                    textFontWeight: FontWeight.w500,
                    textColor: Theme.of(context).textTheme.displayLarge!.color,
                  ),
                ],
              ),
              const Icon(
                FontAwesomeIcons.chevronRight,
                size: 20,
              )
            ],
          ),
        )
      ]),
    );
  }
}
