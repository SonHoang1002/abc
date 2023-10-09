import 'package:isar/isar.dart';

part 'test_model.g.dart';

@collection
@Name("TestModelSchema")
class TestModel {
  Id id = Isar.autoIncrement;

  String? objectPost;

  String? postId;
}