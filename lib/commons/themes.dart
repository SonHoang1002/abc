import 'package:photo_to_pdf/commons/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeManager with ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  getThemeInitial(value) {
    themeMode = value == 'dark'
        ? ThemeMode.dark
        : value == 'light'
            ? ThemeMode.light
            : ThemeMode.system;
    notifyListeners();
  }

  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      // ignore: deprecated_member_use
      final brightness = SchedulerBinding.instance.window.platformBrightness;
      return brightness == Brightness.dark;
    } else {
      return themeMode == ThemeMode.dark;
    }
  }

  void toggleTheme(type) {
    themeMode = type == 'dark'
        ? ThemeMode.dark
        : type == 'light'
            ? ThemeMode.light
            : ThemeMode.system;
    notifyListeners();
  }
}

class MyThemes {
  static final darkTheme = ThemeData(
      sliderTheme: const SliderThemeData(),
      scaffoldBackgroundColor: const Color.fromRGBO(34,34,34,1),
      // mau nen cac nut
      cardColor: const Color.fromRGBO(255, 255, 255, 0.1),
      // mau nen block navigator
      canvasColor: const Color.fromRGBO(0, 0, 0, 0.1),
      // canvasColor: Colors.red,
      primaryColor: Colors.grey.withOpacity(0.6),
      appBarTheme: AppBarTheme(backgroundColor: Colors.grey.shade900),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: colorWhite),
        bodySmall: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.4)),
        bodyLarge: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.4)),
        bodyMedium: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.5)),
        titleLarge: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)),
        titleMedium: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.5)),
      ),
      colorScheme:
          const ColorScheme.dark().copyWith(background: Colors.grey.shade800),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Color.fromRGBO(0, 0, 0, 0.1)),
      dialogBackgroundColor: const Color.fromRGBO(34, 34, 34, 0.8),
      // ignore: deprecated_member_use
      backgroundColor: Colors.white.withOpacity(0.1),
      tabBarTheme: const TabBarTheme(
        unselectedLabelColor: Color.fromRGBO(255, 255, 255, 0.04),
      ),
      dividerColor: const Color.fromRGBO(255, 255, 255, 0.1),
      inputDecorationTheme: const InputDecorationTheme(fillColor: Color.fromRGBO(0,0,0,1))
      );

  static final lightTheme = ThemeData(
      scaffoldBackgroundColor:const Color.fromRGBO(250,250,250,1),
      cardColor: const Color.fromRGBO(0, 0, 0, 0.03),
      canvasColor: const Color.fromRGBO(250, 250, 250, 1),
      primaryColor: colorWhite,
      appBarTheme: const AppBarTheme(backgroundColor: colorWhite),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.black),
        bodySmall: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.4)),
        bodyLarge: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.4)),
        bodyMedium: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),
        titleLarge: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.7)),
        titleMedium: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),
      ),
      colorScheme: const ColorScheme.light()
          .copyWith(background: const Color(0xfff1f2f5)),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Color.fromRGBO(0, 0, 0, 0.1)),
      dialogBackgroundColor: const Color.fromRGBO(255, 255, 255, 0.8),
      // ignore: deprecated_member_use
      backgroundColor: Colors.black.withOpacity(0.1),
      tabBarTheme: const TabBarTheme(
        unselectedLabelColor: Color.fromRGBO(0, 0, 0, 0.04),
      ),
      dividerColor: const Color.fromRGBO(0, 0, 0, 0.1),
      inputDecorationTheme: const InputDecorationTheme(fillColor: Color.fromRGBO(255,255,255,1))
      );
}
