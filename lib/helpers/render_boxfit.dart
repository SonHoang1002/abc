import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:pdf/widgets.dart' as pw;

///
/// Tạo ra bố cục cho ảnh khi [fit], [fill], [stretch] cho item trong project
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

///
/// Tạo ra bố cục cho ảnh khi [fit], [fill], [stretch] cho item trong project ( su dung trong pdf )
///
pw.BoxFit renderPdfWidgetImageBoxfit(ResizeAttribute? resizeAttribute) {
  var result = pw.BoxFit.contain;
  if (resizeAttribute?.title == LIST_RESIZE_MODE[0].title) {
    // fit
    result = pw.BoxFit.contain;
  } else if (resizeAttribute?.title == LIST_RESIZE_MODE[1].title) {
    // fill
    result = pw.BoxFit.cover;
  } else if (resizeAttribute?.title == LIST_RESIZE_MODE[2].title) {
    // stretch
    result = pw.BoxFit.fill;
  }
  return result;
}
