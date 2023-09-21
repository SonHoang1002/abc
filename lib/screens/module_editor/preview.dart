import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/screens/module_home/home.dart';
import 'package:photo_to_pdf/widgets/w_button.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class Preview extends StatefulWidget {
  const Preview({super.key});

  @override
  State<Preview> createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      // backgroundColor: Color.fromRGBO(0, 0, 0, 0.1),,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: const Color.fromRGBO(0, 0, 0, 0.1),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: WTextContent(
                      value: "Preview",
                      textSize: 16,
                      textLineHeight: 19.09,
                      textColor: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: size.height * (589 / 844),
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(250, 250, 250, 1),
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      CarouselSlider.builder(
                        itemBuilder: (context, currentIndex, afterIndex) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: size.height * 0.5,
                                  width: size.width * (281 / 390),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                          255, 255, 255, 1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius:
                                              0.5,
                                          blurRadius: 5,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]),
                                  child:
                                      Image.asset(testImageList[currentIndex]),
                                ),
                                WSpacer(
                                  width: 40,
                                ),
                                WTextContent(value: "Page ${currentIndex + 1}")
                              ],
                            ),
                          );
                        },
                        options: CarouselOptions(
                          height: size.height * 0.8,
                          aspectRatio: size.height / size.width + 1,
                          initialPage: 0,
                          scrollPhysics: const BouncingScrollPhysics(),
                          enableInfiniteScroll: false,
                          autoPlayCurve: Curves.fastOutSlowIn,
                          onPageChanged: (index, reason) {},
                          scrollDirection: Axis.horizontal,
                        ),
                        itemCount: testImageList.length,
                      ),
                    ],
                  ),
                  WButtonFilled(
                    message: "Close",
                    textColor: colorBlue,
                    height: 60,
                    width: size.width * (311 / 390),
                    backgroundColor: colorWhite,
                    onPressed: () {
                      popNavigator(context);
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
