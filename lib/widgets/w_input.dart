import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';

class WInput extends StatefulWidget {
  final double inputWidth;
  final double inputHeight;
  final bool isFocus;
  final TextEditingController controller;
  final Function() onTap;
  final Function(String)? onChanged;
  final String title;
  final String? placeholder;
  final String? suffixValue;
  const WInput(
      {super.key,
      required this.controller,
      required this.inputWidth,
      required this.inputHeight,
      required this.isFocus,
      required this.onTap,
      required this.title,
      this.suffixValue,
      this.placeholder,
      this.onChanged});

  @override
  State<WInput> createState() => _WInputState();
}

class _WInputState extends State<WInput> {
  late double inputTextWidth;
  double inputPadding = 16;
  late TextEditingController _controller;

  TextStyle textStyleInput = const TextStyle(
      color: colorBlue,
      height: 16.71 / 14,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      fontFamily: MY_CUSTOM_FONT);

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  @override
  void initState() {
    _controller.text = widget.controller.text;
    inputTextWidth = _textSize(
        widget.controller.text,
        const TextStyle(
          color: Color.fromRGBO(10, 132, 255, 1),
          fontSize: 14,
        )).width;
  }

  @override
  Widget build(BuildContext context) {
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
          widget.controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: widget.controller.text.trim().length);
          widget.onTap();
        },
        onChanged: widget.onChanged,
        decoration: const BoxDecoration(),
        style: textStyleInput,
        controller: _controller,
        keyboardType: TextInputType.number,
        prefix: Container(
          constraints: const BoxConstraints(minWidth: 47),
          margin: const EdgeInsets.only(left: 15),
          child: Text(widget.title,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                  fontWeight: FontWeight.w700,
                  height: 16.71 / 14,
                  fontSize: 14)),
        ),
        suffix: Container(
          alignment: Alignment.centerLeft,
          constraints: const BoxConstraints(minWidth: 50),
          margin: const EdgeInsets.only(right: 20),
          child: Text(widget.suffixValue ?? "",
              style: const TextStyle(
                  color: colorBlue,
                  fontWeight: FontWeight.w700,
                  height: 19.09 / 16,
                  fontSize: 16)),
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

// void main() => runApp(CounterApp());
// var suffixPadding = 16;

// class CounterApp extends StatefulWidget {
//   @override
//   State<CounterApp> createState() => _CounterAppState();
// }

// class _CounterAppState extends State<CounterApp> {
//   TextEditingController _textEditingController =
//       TextEditingController(text: "hello");
//   double inputTextWidth = 0.0;
  // @override
  // void initState() {
  //   super.initState();
  //   print("hello");
  //   _textEditingController.addListener(textChangeListener);
  //   inputTextWidth = _textSize(
  //       _textEditingController.text,
  //       const TextStyle(
  //         color: Color.fromRGBO(10, 132, 255, 1),
  //         fontSize: 14,
  //       )).width;
  // }

//   @override
//   void didUpdateWidget(covariant CounterApp oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     print("hello");
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _textEditingController.removeListener(textChangeListener);
//     _textEditingController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(useMaterial3: true),
//       home: MultiBlocProvider(
//         providers: [
//           BlocProvider<CounterCubit>(
//             create: (BuildContext context) => CounterCubit(),
//           ),
//         ],
//         child: Scaffold(
//           body: Center(
//             child: Container(
//               width: 300,
//               height: 70,
//               child: TextFormField(
//                   controller: _textEditingController,
//                   style: const TextStyle(
//                     color: Color.fromRGBO(10, 132, 255, 1),
//                     fontSize: 14,
//                   ),
//                   decoration: InputDecoration(
//                     border: const OutlineInputBorder(),
//                     suffix: Container(
//                       constraints: BoxConstraints(minWidth: _textSize("hello", TextStyle()).width+10),
//                       width: 300 - 16 - inputTextWidth - suffixPadding,
//                       color:Colors.red,
//                       child: Text("hello"),
//                     ),
//                   )),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

  // Size _textSize(String text, TextStyle style) {
  //   final TextPainter textPainter = TextPainter(
  //       text: TextSpan(text: text, style: style),
  //       maxLines: 1,
  //       textDirection: TextDirection.ltr)
  //     ..layout(minWidth: 0, maxWidth: double.infinity);
  //   return textPainter.size;
  // }

//   void textChangeListener() {
//     print("text change: ${_textEditingController.text}");
//     inputTextWidth = _textSize(
//         _textEditingController.text,
//         const TextStyle(
//           color: Color.fromRGBO(10, 132, 255, 1),
//           fontSize: 14,
//         )).width;
//     setState(() {});
//   }
// }
