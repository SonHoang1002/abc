import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as flutter_riverpod;
import 'package:photo_to_pdf/commons/themes.dart';
import 'package:photo_to_pdf/material_with_them.dart';
import 'package:photo_to_pdf/services/isar_project_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const flutter_riverpod.ProviderScope(child: MyApp()));
  final result = await IsarProjectService().sizeOfIsarsProject();
  print("sizeOfIsarsProject ${result}");
  Brightness themeMode =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;
  bool darkMode = themeMode == Brightness.dark;
  redoSystemStyle(darkMode);
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

Future<void> redoSystemStyle(bool darkMode) async {
  if (Platform.isAndroid) {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    final bool edgeToEdge = androidInfo.version.sdkInt >= 29;

    // The commented out check below isn't required anymore since https://github.com/flutter/engine/pull/28616 is merged
    // if (edgeToEdge)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // Not relevant to this issue
      statusBarBrightness: darkMode ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: edgeToEdge
          ? Colors.transparent
          : darkMode
              ? Colors.black
              : Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemNavigationBarIconBrightness:
          darkMode ? Brightness.light : Brightness.dark,
    ));
  } else {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Not relevant to this issue
    ));
  }
}


// void main() {
//   runApp(const MaterialApp(
//     home: Scaffold(
//       body: Center(
//         child: TestDrag(),
//       ),
//     ),
//   ));
// }



