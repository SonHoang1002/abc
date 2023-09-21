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

dynamic PADDING_OPTIONS = {
  "values": ["0", "0"],
  "unit": CENTIMET
};

// Map<String, dynamic> PAGE_SIZE = {
//   "A3": {"title": "A3", "width": 29.7, "height": 42, "unit": CENTIMET},
//   "A4": {"title": "A4", "width": 21.0, "height": 29.7, "unit": CENTIMET},
//   "B5": {"title": "B5", "width": 17.6, "height": 25.0, "unit": CENTIMET},
//   "JIS B5": {
//     "title": "JIS B5",
//     "width": 18.2,
//     "height": 25.7,
//     "unit": CENTIMET
//   },
//   "Legal": {"title": "Legal", "width": 8.5, "height": 14.0, "unit": INCH},
//   "Letter": {"title": "Letter", "width": 8.5, "height": 11.0, "unit": INCH},
//   "Tabloid": {"title": "Tabloid", "width": 11.0, "height": 17.0, "unit": INCH},
//   "Custom": {"title": "Custom", "width": 1.0, "height": 1.0, "unit": INCH},
// };

const String INCH = "”";
const String CENTIMET = "cm";
const String POINT = "pt";
