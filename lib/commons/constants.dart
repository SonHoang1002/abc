import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/models/placement.dart';

const String PATH_PREFIX_ICON = "assets/icons/";
const String PATH_PREFIX_IMAGE = "assets/images/";
const String FONT_SFPRODISPLAY = "FontsFree-Net-SFProDisplay-Regular";
const String FONT_GOOGLESANS = "GoogleSans";
const String BLANK_PAGE = "${PATH_PREFIX_IMAGE}blank_page.png";
// ignore: non_constant_identifier_names
List<PaperAttribute> LIST_PAGE_SIZE = [
  PaperAttribute(title: "None", width: 8.5, height: 11.0, unit: INCH),
  PaperAttribute(title: "A3", width: 29.7, height: 42, unit: CENTIMET),
  PaperAttribute(title: "A4", width: 21.0, height: 29.7, unit: CENTIMET),
  PaperAttribute(title: "B5", width: 17.6, height: 25.0, unit: CENTIMET),
  PaperAttribute(title: "JIS B5", width: 18.2, height: 25.7, unit: CENTIMET),
  PaperAttribute(title: "Legal", width: 8.5, height: 14.0, unit: INCH),
  PaperAttribute(title: "Letter", width: 8.5, height: 11.0, unit: INCH),
  PaperAttribute(title: "Tabloid", width: 11.0, height: 17.0, unit: INCH),
  PaperAttribute(title: "Custom", width: 1.0, height: 1.0, unit: INCH),
];

// NUMBER OF TEMPLATE IMAGE IN ROW
// ignore: non_constant_identifier_names
List<List<int>> LIST_LAYOUT_SUGGESTION = [
  [1],
  [1, 1],
  [1, 2],
  [2, 1],
  [2, 2],
  [1, 2, 3]
];
// ignore: non_constant_identifier_names
List<AlignmentAttribute> LIST_ALIGNMENT = [
  AlignmentAttribute(
    title: "Top",
    alignmentMode: Alignment.topCenter,
    mediaSrc: "${PATH_PREFIX_ICON}icon_arrow_up.png",
  ),
  AlignmentAttribute(
    title: "Left",
    alignmentMode: Alignment.centerLeft,
    mediaSrc: "${PATH_PREFIX_ICON}icon_arrow_left.png",
  ),
  AlignmentAttribute(
    title: "Center",
    alignmentMode: Alignment.center,
    mediaSrc: "${PATH_PREFIX_ICON}icon_arrow_center.png",
  ),
  AlignmentAttribute(
    title: "Right",
    alignmentMode: Alignment.centerRight,
    mediaSrc: "${PATH_PREFIX_ICON}icon_arrow_right.png",
  ),
  AlignmentAttribute(
    title: "Down",
    alignmentMode: Alignment.bottomCenter,
    mediaSrc: "${PATH_PREFIX_ICON}icon_arrow_down.png",
  ),
];

// ignore: non_constant_identifier_names
List<ResizeAttribute> LIST_RESIZE_MODE = [
  ResizeAttribute(
    title: "Aspect Fit",
    mediaSrc: "${PATH_PREFIX_ICON}icon_aspect_fit.png",
  ),
  ResizeAttribute(
    title: "Aspect Fill",
    mediaSrc: "${PATH_PREFIX_ICON}icon_aspect_fill.png",
  ),
  ResizeAttribute(
    title: "Stretch",
    mediaSrc: "${PATH_PREFIX_ICON}icon_stretch.png",
  ),
];
// ignore: non_constant_identifier_names
PaddingAttribute PADDING_OPTIONS = PaddingAttribute(
    horizontalPadding: 1.0, verticalPadding: 1.0, unit: CENTIMET);
// ignore: non_constant_identifier_names
SpacingAttribute SPACING_OPTIONS = SpacingAttribute(
    horizontalSpacing: 1.0, verticalSpacing: 1.0, unit: CENTIMET);

// ignore: non_constant_identifier_names
final PLACEMENT_ATTRIBUTE = PlacementAttribute(
    top: 0.0, left: 0.0, right: 0.0, bottom: 0.0, unit: CENTIMET);
// ignore: non_constant_identifier_names
List<dynamic> LIST_ADD_COVER = [
  {
    "key": "change_photo",
    "mediaSrc": '${PATH_PREFIX_ICON}icon_change_photo.png',
    "title": "Change Photo"
  },
  {
    "key": "clear_photo",
    "mediaSrc": '${PATH_PREFIX_ICON}icon_clear_photo.png',
    "title": "Clear Photo"
  },
  {
    "key": "cancel",
    "mediaSrc": '${PATH_PREFIX_ICON}icon_cancel.png',
    "title": "Cancel"
  },
];

// ignore: constant_identifier_names
const String TITLE_PADDING = "Padding";
// ignore: constant_identifier_names
const String TITLE_SPACING = "Spacing";
// ignore: constant_identifier_names
const String TITLE_EDIT_PLACEMENT = "Editing Placement";

// ignore: non_constant_identifier_names
final Unit INCH = Unit(title: "inch", value: "”");
// ignore: non_constant_identifier_names
final Unit CENTIMET = Unit(title: "cm", value: "cm");
// ignore: non_constant_identifier_names
final Unit POINT = Unit(title: "pt", value: "pt");
// ignore: non_constant_identifier_names
final List<Unit> LIST_UNIT = [INCH, CENTIMET, POINT];

// TẤT CẢ CÁC TỈ LỆ NÀY ĐỀU ĐƯỢC SO SÁNH VỚI WIDTH CỦA MÀN HÌNH

/// Ratio of changeable placement board: width, height
// ignore: constant_identifier_names
const List<double> LIST_RATIO_PLACEMENT_BOARD = [0.7, 0.9];

/// Ratio of changeable project item: width, height
// ignore: constant_identifier_names
const List<double> LIST_RATIO_PROJECT_ITEM = [0.35, 0.45];

/// Ratio of changeable preview item: width, height
// ignore: constant_identifier_names
const List<double> LIST_RATIO_PREVIEW = [0.875, 1.125];

/// Ratio of changeable preview item: width, height
// ignore: constant_identifier_names
const List<double> LIST_RATIO_PDF = [1.4, 1.8];

const thumbColorSegments = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFFFFFFF),
  darkColor: Color.fromRGBO(255, 255, 255, 1),
);
// ignore: constant_identifier_names
const String LANDSCAPE = "landscape";
// ignore: constant_identifier_names
const String PORTRAIT = "portrait";
// ignore: constant_identifier_names
const String NATURAL = "natural";
// ignore: non_constant_identifier_names
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

// ignore: constant_identifier_names
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
// ignore: constant_identifier_names
const String SHARE_APP_LINK =
    "https://play.google.com/store/apps/details?id=com.tapuniverse.phototopdf&pli=1";
// ignore: constant_identifier_names
const double DOT_SIZE = 11;
// ignore: constant_identifier_names
const double MIN_PLACEMENT_SIZE = 7.2;

const String TITLE_LAYOUT_WARNING = "No Paper Size";
const String CONTENT_LAYOUT_WARNING =
    "Please select a paper size to use layout options";

const String F_JPEG = ".jpeg";
const String F_JPG = ".jpg";
const String F_PNG = ".png";
const String F_HEIC = ".heic";
const String F_WEBP = ".webp";

const List<String> IMAGE_FORMAT = [F_JPEG, F_JPG, F_PNG, F_HEIC, F_WEBP];

const double INFINITY_NUMBER = 1021029320900;

List<BoxShadow> SHADOWS = [
  BoxShadow(
    color: Colors.black.withOpacity(0.2),
    spreadRadius: -15,
    blurRadius: 10,
    offset: const Offset(0, 10),
  ),
];

final List<Color> COLOR_SLIDERS = [
  const HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 30.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 60.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 90.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 120.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 150.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 180.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 210.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 240.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 270.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 300.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 330.0, 1.0, 1.0).toColor(),
  const HSVColor.fromAHSV(1.0, 360.0, 1.0, 1.0).toColor(),
];


const String PREFERENCE_SAVED_COLOR_KEY = "saved_color";