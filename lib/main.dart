import 'package:flutter/material.dart';
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




// void main() {
//   runApp(const MaterialApp(
//     home: Scaffold(
//       body: Center(
//         child: TestDrag(),
//       ),
//     ),
//   ));
// }



