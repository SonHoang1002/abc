import 'dart:math';

const String pathPrefixIcon = "assets/icons/";
const String pathPrefixImage = "assets/images/";
const String myCustomFont = "FontsFree-Net-SFProDisplay-Regular";

List<dynamic> LIST_PAGE_SIZE = [
  {"title": "A3", "width": 29.7, "height": 42, "unit": CENTIMET},
  {"title": "A4", "width": 21.0, "height": 29.7, "unit": CENTIMET},
  {"title": "B5", "width": 17.6, "height": 25.0, "unit": CENTIMET},
  {"title": "JIS B5", "width": 18.2, "height": 25.7, "unit": CENTIMET},
  {"title": "Legal", "width": 8.5, "height": 14.0, "unit": INCH},
  {"title": "Letter", "width": 8.5, "height": 11.0, "unit": INCH},
  {"title": "Tabloid", "width": 11.0, "height": 17.0, "unit": INCH},
  {"title": "Custom", "width": 1.0, "height": 1.0, "unit": INCH},
];

List<dynamic> LIST_LAYOUT = [
  "${pathPrefixIcon}icon_layout_1.png",
  "${pathPrefixIcon}icon_layout_2.png",
  "${pathPrefixIcon}icon_layout_3.png",
  "${pathPrefixIcon}icon_layout_4.png"
];

List<dynamic> LIST_ALIGNMENT = [
  {
    "title": "Top",
    "mediaSrc": "${pathPrefixIcon}icon_arrow_up.png",
  },
  {
    "title": "Left",
    "mediaSrc": "${pathPrefixIcon}icon_arrow_left.png",
  },
  {
    "title": "Center",
    "mediaSrc": "${pathPrefixIcon}icon_arrow_center.png",
  },
  {
    "title": "Right",
    "mediaSrc": "${pathPrefixIcon}icon_arrow_right.png",
  },
  {
    "title": "Down",
    "mediaSrc": "${pathPrefixIcon}icon_arrow_down.png",
  },
];

List<dynamic> LIST_RESIZE_MODE = [
  {
    "title": "Aspect Fit",
    "mediaSrc": "${pathPrefixIcon}icon_aspect_fit.png",
  },
  {
    "title": "Aspect Fill",
    "mediaSrc": "${pathPrefixIcon}icon_aspect_fill.png",
  },
  {
    "title": "Stretch",
    "mediaSrc": "${pathPrefixIcon}icon_stretch.png",
  },
];

dynamic PADDING_OPTIONS = {
  "values": ["10.0", "10.0"],
  "unit": CENTIMET
};

dynamic SPACING_OPTIONS = {
  "values": ["10.0", "10.0"],
  "unit": POINT
};

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

const String INCH = "”";
const String CENTIMET = "cm";
const String POINT = "pt";

const String LANDSCAPE = "landscape";
const String PORTRAIT = "portrait";
