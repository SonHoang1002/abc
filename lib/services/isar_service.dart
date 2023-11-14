import 'package:photo_to_pdf/models/isar/project_model.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  static Isar? _instance;
  static final List<CollectionSchema<dynamic>> _schemas = [
    ProjectIsarSchema
    ];

  static Future<Isar> get instance async {
    if (_instance == null || !_instance!.isOpen) {
      _instance = await _openDB();
    }
    return _instance!;
  }

  static Future<Isar> _openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    _instance ??= await Isar.open(
      _schemas,
      directory: dir.path,
      inspector: true,
    );
    return _instance!;
  }

  static Future<void> closeDB() async {
    if (_instance != null && _instance!.isOpen) {
      await _instance!.close();
      _instance = null;
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
