import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:photo_to_pdf/helpers/random_number.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/models/placement.dart';

const String pathPrefixIcon = "assets/icons/";
const String pathPrefixImage = "assets/images/";
const String myCustomFont = "FontsFree-Net-SFProDisplay-Regular";

List<PaperAttribute> LIST_PAGE_SIZE = [
  PaperAttribute(title: "A3", width: 29.7, height: 42, unit: CENTIMET),
  PaperAttribute(title: "A4", width: 21.0, height: 29.7, unit: CENTIMET),
  PaperAttribute(title: "B5", width: 17.6, height: 25.0, unit: CENTIMET),
  PaperAttribute(title: "JIS B5", width: 18.2, height: 25.7, unit: CENTIMET),
  PaperAttribute(title: "Legal", width: 8.5, height: 14.0, unit: INCH),
  PaperAttribute(title: "Letter", width: 8.5, height: 11.0, unit: INCH),
  PaperAttribute(title: "Tabloid", width: 11.0, height: 17.0, unit: INCH),
  PaperAttribute(title: "Custom", width: 1.0, height: 1.0, unit: INCH),
];

// NUMBER OF ICON IN ROW
List<List<int>> LIST_LAYOUT_SUGGESTION = [
  [1],
  [1, 1],
  [1, 2],
  [2, 1],
  [1, 2, 3],
  [1, 2, 3, 4]
];

List<AlignmentAttribute> LIST_ALIGNMENT = [
  AlignmentAttribute(
    title: "Top",
    alignmentMode: Alignment.topCenter,
    mediaSrc: "${pathPrefixIcon}icon_arrow_up.png",
  ),
  AlignmentAttribute(
    title: "Left",
    alignmentMode: Alignment.centerLeft,
    mediaSrc: "${pathPrefixIcon}icon_arrow_left.png",
  ),
  AlignmentAttribute(
    title: "Center",
    alignmentMode: Alignment.center,
    mediaSrc: "${pathPrefixIcon}icon_arrow_center.png",
  ),
  AlignmentAttribute(
    title: "Right",
    alignmentMode: Alignment.centerRight,
    mediaSrc: "${pathPrefixIcon}icon_arrow_right.png",
  ),
  AlignmentAttribute(
    title: "Down",
    alignmentMode: Alignment.bottomCenter,
    mediaSrc: "${pathPrefixIcon}icon_arrow_down.png",
  ),
];

// ignore: non_constant_identifier_names
List<ResizeAttribute> LIST_RESIZE_MODE = [
  ResizeAttribute(
    title: "Aspect Fit",
    mediaSrc: "${pathPrefixIcon}icon_aspect_fit.png",
  ),
  ResizeAttribute(
    title: "Aspect Fill",
    mediaSrc: "${pathPrefixIcon}icon_aspect_fill.png",
  ),
  ResizeAttribute(
    title: "Stretch",
    mediaSrc: "${pathPrefixIcon}icon_stretch.png",
  ),
];

PaddingAttribute PADDING_OPTIONS = PaddingAttribute(
    horizontalPadding: 1.0, verticalPadding: 1.0, unit: CENTIMET);

SpacingAttribute SPACING_OPTIONS = SpacingAttribute(
    horizontalSpacing: 1.0, verticalSpacing: 1.0, unit: CENTIMET);

final PLACEMENT_ATTRIBUTE = PlacementAttribute(
    horizontal: 0.0,
    vertical: 0.0,
    top: 0.0,
    left: 0.0,
    right: 0.0,
    bottom: 0.0,
    unit: POINT);

List<dynamic> LIST_ADD_COVER = [
  {
    "key": "change_photo",
    "mediaSrc": '${pathPrefixIcon}icon_change_photo.png',
    "title": "Change Photo"
  },
  {
    "key": "clear_photo",
    "mediaSrc": '${pathPrefixIcon}icon_clear_photo.png',
    "title": "Clear Photo"
  },
  {
    "key": "cancel",
    "mediaSrc": '${pathPrefixIcon}icon_cancel.png',
    "title": "Cancel"
  },
];

const String TITLE_PADDING = "Padding";
const String TITLE_SPACING = "Spacing";
const String TITLE_EDIT_PLACEMENT = "Editing Placement";

final Unit INCH = Unit(title: "inch", value: "”");
final Unit CENTIMET = Unit(title: "cm", value: "cm");
final Unit POINT = Unit(title: "pt", value: "pt");
final List<Unit> LIST_UNIT = [INCH, CENTIMET, POINT];

// TẤT CẢ CÁC TỈ LỆ NÀY ĐỀU ĐƯỢC SO SÁNH VỚI WIDTH CỦA MÀN HÌNH

/// Ratio of changeable placement board: width, height
const List<double> LIST_RATIO_PLACEMENT_BOARD = [0.7, 0.9];

/// Ratio of changeable project item: width, height
const List<double> LIST_RATIO_PROJECT_ITEM = [0.35, 0.45];

/// Ratio of changeable preview item: width, height
const List<double> LIST_RATIO_PREVIEW = [0.875, 1.125];

/// Ratio of changeable preview item: width, height
const List<double> LIST_RATIO_PDF = [1.4, 1.8];

const thumbColorSegments = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFFFFFFF),
  darkColor: Color.fromRGBO(255, 255, 255, 1),
);

const String LANDSCAPE = "landscape";
const String PORTRAIT = "portrait";
const String NATURAL = "natural";

final PDF_PAGE_FORMAT = <String, Map<String, PdfPageFormat>>{
  "A3": {
    LANDSCAPE: PdfPageFormat.a3.landscape,
    PORTRAIT: PdfPageFormat.a3.portrait,
    NATURAL: PdfPageFormat.a3,
  },
  "A4": {
    LANDSCAPE: PdfPageFormat.a4.landscape,
    PORTRAIT: PdfPageFormat.a4.portrait,
    NATURAL: PdfPageFormat.a4,
  },
  "B5": {
    LANDSCAPE: PdfPageFormat.a5.landscape,
    PORTRAIT: PdfPageFormat.a5.portrait,
    NATURAL: PdfPageFormat.a5,
  },
  "Legal": {
    LANDSCAPE: PdfPageFormat.legal.landscape,
    PORTRAIT: PdfPageFormat.legal.portrait,
    NATURAL: PdfPageFormat.legal,
  },
  "Letter": {
    LANDSCAPE: PdfPageFormat.letter.landscape,
    PORTRAIT: PdfPageFormat.letter.portrait,
    'natural': PdfPageFormat.letter,
  },
};

const List<Color> ALL_COLORS = [
  Colors.amber,
  Colors.amberAccent,
  Colors.black,
  Colors.blue,
  Colors.blueAccent,
  Colors.blueGrey,
  Colors.brown,
  Colors.cyan,
  Colors.cyanAccent,
  Colors.deepOrange,
  Colors.deepOrangeAccent,
  Colors.deepPurple,
  Colors.deepPurpleAccent,
  Colors.green,
  Colors.greenAccent,
  Colors.grey,
  Colors.indigo,
  Colors.indigoAccent,
  Colors.lightBlue,
  Colors.lightBlueAccent,
  Colors.lightGreen,
  Colors.lightGreenAccent,
  Colors.lime,
  Colors.limeAccent,
  Colors.orange,
  Colors.orangeAccent,
  Colors.pink,
  Colors.pinkAccent,
  Colors.purple,
  Colors.purpleAccent,
  Colors.red,
  Colors.redAccent,
  Colors.teal,
  Colors.tealAccent,
  Colors.yellow,
  Colors.yellowAccent,
  Colors.white,
];

  const double point = 1.0;
  const double inch = 72.0;
  const double cm = inch / 2.54;
  const double mm = inch / 25.4;