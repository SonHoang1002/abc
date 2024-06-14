import 'package:android_id/android_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import 'package:share_plus/share_plus.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  void _onFeedback() async {
    var id = await const AndroidId().getId();
    final Email email = Email( 
      subject: 'PhptoToPdf Android Feedback: $id',
      // receiver
      recipients: ['tapuniverse@gmail.com'], 
      isHTML: false,
    );
    await FlutterEmailSender.send(email);
  }

  void _onShare() async {
    await Share.shareUri(Uri.parse(SHARE_APP_LINK));
  }

  void _onAccessSetting() async {
    await openAppSettings();
  }

  void _saveAssetFile(BuildContext context, String path) async {
    // ByteData data = await rootBundle.load(path);
    // Uint8List bytes = data.buffer.asUint8List();
    // final result = await ImageGallerySaver.saveImage(Uint8List.fromList(bytes));
    // if (result['isSuccess']) {
    //   // ignore: use_build_context_synchronously
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //     content: Text('Image saved to gallery successfully!'),
    //   ));
    // } else {
    //   // ignore: use_build_context_synchronously
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //     content: Text('Failed to save image to gallery.'),
    //   ));
    // }
  }

  void _saveInternetLink(String link) async {
    // final result = await GallerySaver.saveImage(link);
    // print("result save Inter Link: $result");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        Container(
          margin: const EdgeInsets.only(top: 50),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              WTextContent(
                value: "Settings",
                textSize: 32,
                textLineHeight: 38,
                textColor: Theme.of(context).textTheme.displayLarge!.color,
                textAlign: TextAlign.start,
              ),
              const SizedBox()

              // GestureDetector(
              //     onTap: () async {
              //       bool isDarkMode =
              //           Provider.of<ThemeManager>(context, listen: false)
              //               .isDarkMode;
              //       if (isDarkMode) {
              //         Provider.of<ThemeManager>(context, listen: false)
              //             .toggleTheme("light");
              //       } else {
              //         Provider.of<ThemeManager>(context, listen: false)
              //             .toggleTheme("dark");
              //       }
              //       // _saveInternetLink("https://www.vietnamfineart.com.vn/wp-content/uploads/2023/03/45e189c91326557552f165eb6cd4f43c.jpg");
              //       // _saveAssetFile(context, "${PATH_PREFIX_IMAGE}abc.jpg");
              //     },
              //     child: Container(
              //         height: 30,
              //         width: 30,
              //         decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(15),
              //             color: Theme.of(context).canvasColor),
              //         child: Icon(
              //             Provider.of<ThemeManager>(context).isDarkMode
              //                 ? FontAwesomeIcons.sun
              //                 : FontAwesomeIcons.moon,
              //             size: 15,
              //             color: Theme.of(context)
              //                 .textTheme
              //                 .displayLarge!
              //                 .color))),
            ],
          ),
        ),
        WSpacer(
          height: 30,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(
                width: 1, color: const Color.fromRGBO(0, 0, 0, 0.05)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                  color: Color.fromRGBO(20, 20, 20, 0.05),
                  spreadRadius: 5,
                  offset: Offset(0, 10),
                  blurRadius: 40)
            ],
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: _onFeedback,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)),
                  ),
                  child: _buildSettingItem(
                    context: context,
                    prefixMediaSrc: "${PATH_PREFIX_ICON}icon_feedback.png",
                    title: "Write a feedback",
                  ),
                ),
              ),
              GestureDetector(
                onTap: _onShare,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12)),
                  ),
                  child: Container(
                    child: _buildSettingItem(
                      context: context,
                      prefixMediaSrc: "${PATH_PREFIX_ICON}icon_share.png",
                      title: "Share this app",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        WSpacer(
          height: 30,
        ),
        GestureDetector(
          onTap: _onAccessSetting,
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
              child: _buildSettingItem(
                context: context,
                prefixMediaSrc: "${PATH_PREFIX_ICON}icon_access_setting.png",
                title: "Photo Access Settings",
              )),
        ),
      ]),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required String prefixMediaSrc,
    required String title,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              prefixMediaSrc,
              height: 20,
              width: 20,
              color: Theme.of(context).textTheme.displayLarge!.color,
            ),
            WSpacer(
              width: 10,
            ),
            WTextContent(
              value: title,
              textSize: 15,
              textLineHeight: 20,
              textFontWeight: FontWeight.w500,
              textColor: Theme.of(context).textTheme.displayLarge!.color,
            ),
          ],
        ),
        Icon(
          FontAwesomeIcons.chevronRight,
          size: 20,
          color: Theme.of(context).textTheme.displayLarge!.color,
        )
      ],
    );
  }
}
