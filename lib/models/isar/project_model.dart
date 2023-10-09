import 'package:isar/isar.dart';

part 'project_model.g.dart';

@collection
@Name("ProjectSchema")
class ProjectIsar {
  Id id = Isar.autoIncrement;
  String? projectId;
  String? projectData;
}
