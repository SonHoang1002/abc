import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/models/project.dart';

///
/// Tạo ra bố cục cho ảnh khi [fit], [fill], [stretch] cho iem trong project
/// 
BoxFit? renderImageBoxfit(ResizeAttribute? resizeAttribute) {
  if (resizeAttribute?.title == LIST_RESIZE_MODE[0].title) {
    // fit
    return BoxFit.contain;
  } else if (resizeAttribute?.title == LIST_RESIZE_MODE[1].title) {
    // fill
    return BoxFit.cover;
  } else if (resizeAttribute?.title == LIST_RESIZE_MODE[2].title) {
    // stretch
    return BoxFit.fill;
  } else {
    return null;
  }
}
