import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';

class BodyDialogCustom extends StatefulWidget {
  final Offset offset;
  final Widget dialogWidget;
  final Alignment scaleAlignment;
  final Function()? onTapBackground;
  const BodyDialogCustom(
      {super.key,
      required this.offset,
      required this.dialogWidget,
      this.scaleAlignment = Alignment.center,
      this.onTapBackground});

  @override
  State<BodyDialogCustom> createState() => _BodyDialogCustomState();
}

class _BodyDialogCustomState extends State<BodyDialogCustom>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.ease);
    controller.addListener(() {
      setState(() {});
    });
    controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Material(
      color: transparent,
      child: Stack(children: [
        Positioned.fill(
            child: GestureDetector(
          onTap: () {
            controller.reverse().then((_) {
              if (widget.onTapBackground != null) {
                widget.onTapBackground!();
              } else {
                popNavigator(context);
              }
            });
          },
          child: Container(color: const Color.fromRGBO(0, 0, 0, 0.03)),
        )),
        Positioned(
            bottom: size.height - widget.offset.dy,
            left: widget.offset.dx,
            child: ScaleTransition(
              scale: scaleAnimation,
              alignment: widget.scaleAlignment,
              child: Stack(
                children: [
                  ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: widget.dialogWidget,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 0,
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ]),
                        child: widget.dialogWidget),
                  ),
                ],
              ),
            ))
      ]),
    );
  }
}