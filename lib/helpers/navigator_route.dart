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

// pushCustomMaterialPageRoute(
//   BuildContext context,
//   Widget newScreen, {
//   RouteSettings? settings,
//   bool maintainState = true,
//   bool fullscreenDialog = false,
//   bool allowSnapshotting = true,
// }) {
//   Navigator.push(
//       context,
//       CustomOpaqueCupertinoPageRoute(
//           builder: (context) => newScreen,
//           settings: settings,
//           maintainState: maintainState,
//           fullscreenDialog: fullscreenDialog,
//           allowSnapshotting: allowSnapshotting));
// }

/// drive from bottom to top screen
pushCustomVerticalMaterialPageRoute(BuildContext context, Widget newScreen,
    {bool opaque = true}) {
  Navigator.push(
    context,
    MaterialPageRouteBuilder(
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) => newScreen,
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.5)
    ),
  );
}

abstract class PageRoute<T> extends ModalRoute<T> {
  PageRoute({
    super.settings,
    this.fullscreenDialog = false,
    this.allowSnapshotting = true,
  });
  final bool fullscreenDialog;

  @override
  final bool allowSnapshotting;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) =>
      nextRoute is PageRoute;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) =>
      previousRoute is PageRoute;
}

Widget _defaultTransitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return child;
}

class MaterialPageRouteBuilder<T> extends PageRoute<T> {
  MaterialPageRouteBuilder({
    super.settings,
    required this.pageBuilder,
    this.transitionsBuilder = _defaultTransitionsBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    this.opaque = true,
    this.barrierDismissible = false,
    this.barrierColor,
    this.barrierLabel,
    this.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
  });

  final RoutePageBuilder pageBuilder;
  final RouteTransitionsBuilder transitionsBuilder;

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  @override
  final bool opaque;

  @override
  final bool barrierDismissible;

  @override
  final Color? barrierColor;

  @override
  final String? barrierLabel;

  @override
  final bool maintainState;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return pageBuilder(context, animation, secondaryAnimation);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return transitionsBuilder(context, animation, secondaryAnimation, child);
  }
}
