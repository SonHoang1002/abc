import 'package:flutter/material.dart';
import 'package:photo_to_pdf/widgets/w_opaque_cupertino.dart';
import 'package:photo_to_pdf/widgets/w_opaque_material.dart';

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

pushAndReplaceToNextScreen(BuildContext context, Widget newScreen) {
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (_) => newScreen));
}

pushAndReplaceNamedToNextScreen(BuildContext context, String newRouteLink) {
  Navigator.of(context).pushReplacementNamed(newRouteLink);
}

popToPreviousScreen(BuildContext context) {
  Navigator.of(context).pop();
}

// pushCustomCupertinoPageRoute(
//   BuildContext context,
//   Widget newScreen, {
//   bool opaque = true,
//   String? title,
//   RouteSettings? settings,
//   bool maintainState = true,
//   bool fullscreenDialog = false,
//   bool allowSnapshotting = true,
// }) {
//   Navigator.push(
//       context,
//       CustomOpaqueCupertinoPageRoute(
//           builder: (context) => newScreen,
//           title: title,
//           settings: settings,
//           maintainState: maintainState,
//           fullscreenDialog: fullscreenDialog,
//           allowSnapshotting: allowSnapshotting));
// }

pushCustomMaterialPageRoute(
  BuildContext context,
  Widget newScreen, {
  RouteSettings? settings,
  bool maintainState = true,
  bool fullscreenDialog = false,
  bool allowSnapshotting = true,
}) {
  Navigator.push(
      context,
      CustomOpaqueCupertinoPageRoute(
          builder: (context) => newScreen,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          allowSnapshotting: allowSnapshotting));
}

