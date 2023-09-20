import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as flutter_riverpod;
import 'package:photo_to_pdf/commons/themes.dart';
import 'package:photo_to_pdf/material_with_them.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const flutter_riverpod.ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => ThemeManager()),
    ], child: const MaterialWithTheme());
  }
}






        // DropdownButtonHideUnderline(
        //   child: DropdownButton2<String>(
        //     onChanged: (value) {},
        //     hint: Row(children: [
        //       Container(
        //         constraints: const BoxConstraints(minWidth: 50, maxWidth: 70),
        //         padding: const EdgeInsets.only(left: 5),
        //         child: WTextContent(
        //           value: "Preset",
        //           textSize: 14,
        //           textLineHeight: 16.71,
        //           textColor: const Color.fromRGBO(0, 0, 0, 0.5),
        //           textFontWeight: FontWeight.w600,
        //         ),
        //       ),
        //       Expanded(
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             WTextContent(
        //               value: "Letter",
        //               textSize: 14,
        //               textLineHeight: 16.71,
        //               textColor: const Color.fromRGBO(10, 132, 255, 1),
        //             ),
        //             Container(
        //               margin: const EdgeInsets.only(bottom: 5),
        //               child: const Icon(
        //                 FontAwesomeIcons.sortDown,
        //                 color: Color.fromRGBO(10, 132, 255, 1),
        //                 size: 15,
        //               ),
        //             )
        //           ],
        //         ),
        //       )
        //     ]),
        //     items: PAGE_SIZES
        //         .map((dynamic item) => DropdownMenuItem<String>(
        //               value: item['title'],
        //               child: Text(
        //                 item['title'],
        //                 style: const TextStyle(
        //                   fontSize: 14,
        //                   fontWeight: FontWeight.bold,
        //                   color: Colors.white,
        //                 ),
        //                 overflow: TextOverflow.ellipsis,
        //               ),
        //             ))
        //         .toList(),
        //   ),
        // ),
      


// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:photo_to_pdf/widgets/w_text_content.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       title: 'DropdownButton2 Demo',
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final List<String> items = [
//     'Item1',
//     'Item2',
//     'Item3',
//     'Item4',
//     'Item5',
//     'Item6',
//     'Item7',
//     'Item8',
//   ];
//   String? selectedValue;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: DropdownButtonHideUnderline(
//           child: DropdownButton2<String>(
//             isExpanded: true,
//             hint: const Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     'Select Item',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.yellow,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
            // items: items
            //     .map((String item) => DropdownMenuItem<String>(
            //           value: item,
            //           child: Text(
            //             item,
            //             style: const TextStyle(
            //               fontSize: 14,
            //               fontWeight: FontWeight.bold,
            //               color: Colors.white,
            //             ),
            //             overflow: TextOverflow.ellipsis,
            //           ),
            //         ))
            //     .toList(),
//             value: selectedValue,
//             onChanged: (String? value) {
//               setState(() {
//                 selectedValue = value;
//               });
//             },
//             buttonStyleData: ButtonStyleData(
//               height: 50,
//               width: 200,
//               padding: const EdgeInsets.only(left: 14, right: 14),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(14),
                
//               ),
//               elevation: 2,
//             ),
//             iconStyleData: const IconStyleData(
//               icon: Icon(
//                 FontAwesomeIcons.sortDown,
//                 color: Color.fromRGBO(10, 132, 255, 1),
//                 size: 15,
//               ),
//               iconSize: 14,
//               iconEnabledColor: Colors.yellow,
//               iconDisabledColor: Colors.grey,
//             ),
//             dropdownStyleData: DropdownStyleData(
//               maxHeight: 300,
//               width: 150,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(14),
//                   color: const Color.fromRGBO(0, 0, 0, 0.03)),
                  
//             ),
//             menuItemStyleData: const MenuItemStyleData(
//               height: 40,
//               padding: EdgeInsets.only(left: 14, right: 14),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

