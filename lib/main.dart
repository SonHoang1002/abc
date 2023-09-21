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



