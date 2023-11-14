import 'package:flutter/services.dart';

class ShowPopupReview {
  static const MethodChannel _channel =
      MethodChannel('com.tapuniverse.phototopdf/popup_review_channel');
  static const String _method = "showPopupReview";

  static Future<void> showPopupReview() async {
    try {
       _channel.invokeMethod(_method);
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
    }
  }
}
