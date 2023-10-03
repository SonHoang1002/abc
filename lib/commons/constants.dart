import 'dart:math';
import 'package:flutter/material.dart';
import 'package:photo_to_pdf/models/placement.dart';
import 'package:photo_to_pdf/models/project.dart';

const String pathPrefixIcon = "assets/icons/";
const String pathPrefixImage = "assets/images/";
const String myCustomFont = "FontsFree-Net-SFProDisplay-Regular";

// List<dynamic> LIST_PAGE_SIZE = [
//   {"title": "A3", "width": 29.7, "height": 42, "unit": CENTIMET},
//   {"title": "A4", "width": 21.0, "height": 29.7, "unit": CENTIMET},
//   {"title": "B5", "width": 17.6, "height": 25.0, "unit": CENTIMET},
//   {"title": "JIS B5", "width": 18.2, "height": 25.7, "unit": CENTIMET},
//   {"title": "Legal", "width": 8.5, "height": 14.0, "unit": INCH},
//   {"title": "Letter", "width": 8.5, "height": 11.0, "unit": INCH},
//   {"title": "Tabloid", "width": 11.0, "height": 17.0, "unit": INCH},
//   {"title": "Custom", "width": 1.0, "height": 1.0, "unit": INCH},
// ];

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

List<dynamic> LIST_LAYOUT = [
  "${pathPrefixIcon}icon_layout_1.png",
  "${pathPrefixIcon}icon_layout_2.png",
  "${pathPrefixIcon}icon_layout_3.png",
  "${pathPrefixIcon}icon_layout_4.png"
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

final  PLACEMENT_OPTIONS = PlacementAttribute(
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
final Unit CENTIMET = Unit(title: "centimet", value: "cm");
final Unit POINT = Unit(title: "point", value: "point");
final List<Unit> LIST_UNIT = [INCH, CENTIMET, POINT];

const String LANDSCAPE = "landscape";
const String PORTRAIT = "portrait";
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
