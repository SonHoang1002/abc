import 'package:flutter/material.dart';

popNavigator(BuildContext context) {
  Navigator.pop(context);
}

pushNavigator(BuildContext context, Widget newScreen) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => newScreen));
}

pushAndRemoveUntilNavigator(BuildContext context, Widget newScreen) {
  Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (context) => newScreen), (route) => false);
}
