import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/commons/themes.dart';
import 'package:photo_to_pdf/helpers/convert.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:provider/provider.dart';

class WInputPaper extends StatefulWidget {
  final double inputWidth;
  final double inputHeight;
  final bool isFocus;
  final dynamic paperConfig;
  final TextEditingController controller;
  final Function() onTap;
  final String title;
  final Function(String)? onChanged;
  final String? placeholder;
  final String? suffixValue;
  final bool? isVerticalOrientation;
  const WInputPaper(
      {super.key,
      required this.controller,
      required this.inputWidth,
      required this.inputHeight,
      required this.isFocus,
      required this.onTap,
      required this.title,
      required this.paperConfig,
      this.suffixValue,
      this.placeholder,
      this.onChanged,
      this.isVerticalOrientation});

  @override
  State<WInputPaper> createState() => _WInputPaperState();
}

class _WInputPaperState extends State<WInputPaper> {
  late double widthContentInput;
  double inputPadding = 16;
  double marginPreffix = 15;
  late dynamic _paperConfig;
  bool? _isVerticalOrientation;
  late TextEditingController _controller;
  final GlobalKey _preffixKey = GlobalKey();
  Size _preffixContainerSize = const Size(30, 30);

  TextStyle textStyleInput = const TextStyle(
    color: colorBlue,
    height: 16.71 / 14,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    fontFamily: FONT_GOOGLESANS,
  );
  TextStyle suffixTextStyle = const TextStyle(
      color: colorBlue,
      fontWeight: FontWeight.w700,
      height: 19.09 / 16,
      fontSize: 16);

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  void textChangeListener() {
    widthContentInput = _textSize(
        _controller.text,
        const TextStyle(
          color: Color.fromRGBO(10, 132, 255, 1),
          fontSize: 14,
        )).width;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(textChangeListener);
    _controller.dispose();
  }

  @override
  void initState() {
    _controller = TextEditingController(text: widget.controller.text);
    _paperConfig = {
      "mediaSrc": widget.paperConfig['mediaSrc'],
      "title": widget.paperConfig['title'],
      "content": widget.paperConfig['content'] ?? LIST_PAGE_SIZE[0]
    };
    _controller.addListener(textChangeListener);
    widthContentInput = _textSize(_controller.text, textStyleInput).width;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final renderBox =
          _preffixKey.currentContext?.findRenderObject() as RenderBox;
      _preffixContainerSize = renderBox.size;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle preffixTextStyle = TextStyle(
        color: Theme.of(context).textTheme.bodyMedium!.color,
        fontWeight: FontWeight.w700,
        height: 16.71 / 14,
        fontSize: 14);
    // goi khi thay doi preset
    if (_paperConfig['content'].title != widget.paperConfig['content'].title) {
      _controller.text = widget.controller.text;
      _paperConfig['content'] = widget.paperConfig['content'];
    }
    // goi khi thay doi preset, unit selection
    if (_paperConfig['content'].unit.title !=
        widget.paperConfig['content'].unit.title) {
      _controller.text = convertUnit(
              _paperConfig['content'].unit,
              widget.paperConfig['content'].unit,
              double.parse(_controller.text))
          .toStringAsFixed(2);
      _paperConfig['content'] = widget.paperConfig['content'];
    }
    // goi khi thay doi orientation
    if (_isVerticalOrientation != widget.isVerticalOrientation) {
      _controller.text = widget.controller.text;
      _isVerticalOrientation = widget.isVerticalOrientation;
    }
    return Container(
      width: widget.inputWidth,
      height: widget.inputHeight,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
              color: widget.isFocus
                  ? const Color.fromRGBO(10, 132, 255, 1)
                  : transparent,
              width: 2)),
      child: CupertinoTextField(
        onTap: () {
          setState(() {
            _controller.selection = TextSelection(
                baseOffset: 0, extentOffset: _controller.text.trim().length);
          });
          widget.onTap();
        },
        onChanged: widget.onChanged,
        decoration: const BoxDecoration(),
        style: textStyleInput,
        controller: _controller,
        keyboardType: TextInputType.number,
        prefix: Container(
          key: _preffixKey,
          constraints: const BoxConstraints(minWidth: 47),
          margin: EdgeInsets.only(left: marginPreffix),
          child: Text(widget.title, style: preffixTextStyle),
        ),
        suffix: Container(
          constraints: BoxConstraints(
              minWidth:
                  _textSize(widget.suffixValue ?? "", suffixTextStyle).width +
                      inputPadding),
          width: widget.inputWidth -
              10 -
              inputPadding -
              widthContentInput -
              _preffixContainerSize.width -
              marginPreffix,
          alignment: Alignment.centerLeft,
          child: Text(widget.suffixValue ?? "", style: suffixTextStyle),
        ),
        placeholder: widget.placeholder ?? "Untitled",
        placeholderStyle: const TextStyle(
            color: colorBlue,
            fontWeight: FontWeight.w700,
            height: 19.09 / 16,
            fontSize: 16),
      ),
    );
  }
}

class WInputLayout extends StatefulWidget {
  final TextEditingController controller;
  final Unit unit;
  final Function(String) onChanged;
  final double width;
  final bool isFocus;
  final Function() onSubmitted;
  final String suffixValue;
  final Function()? onTap;
  final bool? autoFocus;
  final bool? isHaveSuffix;
  const WInputLayout(
      {super.key,
      required this.controller,
      required this.unit,
      required this.width,
      required this.onChanged,
      required this.isFocus,
      required this.suffixValue,
      required this.onSubmitted,
      this.onTap,
      this.autoFocus = false,
      this.isHaveSuffix});

  @override
  State<WInputLayout> createState() => _WInputLayoutState();
}

class _WInputLayoutState extends State<WInputLayout> {
  late TextEditingController _controller;
  final double inputPadding = 16;
  late double widthContentInput;
  late Unit _unit;

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  void textChangeListener() {
    widthContentInput = _textSize(
        _controller.text,
        const TextStyle(
          color: Color.fromRGBO(10, 132, 255, 1),
          fontSize: 14,
        )).width;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.controller.text);
    _unit = widget.unit;
    _controller.addListener(textChangeListener);
    widthContentInput = _textSize(
        _controller.text,
        const TextStyle(
          color: Color.fromRGBO(10, 132, 255, 1),
          fontSize: 14,
        )).width;
    if (widget.autoFocus!) {
      _controller.selection =
          TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(textChangeListener);
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle suffixTextStyle = TextStyle(
        color: Theme.of(context).textTheme.bodyMedium!.color,
        fontFamily: FONT_GOOGLESANS,
        fontWeight: FontWeight.w700,
        height: 16.71 / 14,
        fontSize: 14);
    // change unit -> change value input
    if (_unit.title != widget.unit.title) {
      _controller.text =
          convertUnit(_unit, widget.unit, double.parse(_controller.text.trim()))
              .toStringAsFixed(2);
      _unit = widget.unit;
    }

    return SizedBox(
        height: 35,
        width: widget.width,
        child: CupertinoTextField(
          onTap: () {
            widget.onTap != null ? widget.onTap!() : null;
            setState(() {
              _controller.selection = TextSelection(
                  baseOffset: 0, extentOffset: _controller.value.text.length);
            });
          },
          onSubmitted: (value) {
            widget.onSubmitted();
          },
          onChanged: widget.onChanged,
          autofocus: widget.autoFocus!,
          textAlign: TextAlign.end,
          keyboardType: TextInputType.number,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Provider.of<ThemeManager>(context).isDarkMode
                  ? colorBlack
                  : Theme.of(context).scaffoldBackgroundColor,
              border: Border.all(
                  color: widget.isFocus
                      ? const Color.fromRGBO(98, 161, 255, 1)
                      : transparent,
                  width: 2)),
          suffix: widget.isHaveSuffix == true
              ? Container(
                  constraints: BoxConstraints(
                      minWidth:
                          _textSize(widget.suffixValue, suffixTextStyle).width +
                              inputPadding,
                      maxWidth: widget.width / 2 - inputPadding + 5),
                  width:
                      widget.width / 2 - widthContentInput + inputPadding / 2,
                  child: Text(widget.suffixValue, style: suffixTextStyle),
                )
              : const SizedBox(),
          style: const TextStyle(
            color: colorBlue,
            height: 16.71 / 14,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: FONT_GOOGLESANS,
          ),
          controller: _controller,
        ));
  }
}
