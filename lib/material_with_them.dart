import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/themes.dart';
import 'package:photo_to_pdf/screens/module_home/home.dart';
import 'package:provider/provider.dart';

class MaterialWithTheme extends StatefulWidget {
  const MaterialWithTheme({super.key});

  @override
  State<MaterialWithTheme> createState() => _MaterialWithThemeState();
}

class _MaterialWithThemeState extends State<MaterialWithTheme> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      debugShowCheckedModeBanner: false,
      themeMode: theme.themeMode,
      home: const HomePage(),
    );
  }
}
//  _project = _project.copyWith(
//                 layoutIndex: _listLayoutStatus
//                     .indexWhere((element) => element['isFocus'] == true),
//                 resizeAttribute: _resizeModeSelectedValue,
//                 alignmentAttribute: _listAlignment
//                     .where((element) => element['isFocus'] == true)
//                     .toList()
//                     .first['alignment'],
//                 backgroundColor: _currentLayoutColor,
//                 paddingAttribute: _paddingOptions,
//                 spacingAttribute: _spacingOptions,
//                 placements: _listPlacement,
//                 useAvailableLayout: _segmentCurrentIndex == 0);
//             widget.onApply(_project, _segmentCurrentIndex);