import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness; 
    print("theme brightness: ${brightness}"); 
    return MaterialApp(
      title: 'Photo to PDF',
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      debugShowCheckedModeBanner: false,
      themeMode: theme.themeMode,
      home: const HomePage(),
    );
  }
}
