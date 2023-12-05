import 'dart:convert';
import 'package:photo_to_pdf/models/isar/project_model.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/services/isar_service.dart';
import 'package:isar/isar.dart';

class IsarProjectService {
  Future<int> sizeOfIsarsProject() async {
    final instance = await IsarService.instance;
    final allIsarCollections = await instance.projectIsars.where().findAll();
    if (allIsarCollections.isNotEmpty) {
      final List<Project> abc = allIsarCollections.map((element) {
        return Project.fromJson(jsonDecode(element.projectData!));
      }).toList();
      return abc.length;
    } else {
      return 0;
    }
  }

  // reorder
  Future<void> reOrderList(Project project, int index) async {
    // danh sách hiển thị ngược so với danh sách được lưu trong isar
    final instance = await IsarService.instance;
    List<ProjectIsar> listIsarProject =
        await instance.projectIsars.where().findAll();
    List<Project> listProject = listIsarProject
        .map((e) => Project.fromJson(jsonDecode(e.projectData!)))
        .toList()
        .reversed
        .toList();
    final indexOfDeleteProject =
        listProject.map((e) => e.id).toList().indexOf(project.id);
    listProject.removeAt(indexOfDeleteProject);
    listProject.insert(index, project);
    final listResult = List.from(listProject.reversed.toList());
    await resetProject();
    for (var element in listResult) {
      await addProject(element);
    }
  }

  //add
  Future<void> addProject(Project project) async {
    final instance = await IsarService.instance;
    if (instance.isOpen == true) {
      await instance.writeTxn(() async {
        await instance.projectIsars.put(ProjectIsar()
          ..projectData = jsonEncode(project.toJson())
          ..projectId = project.id.toString());
      });
    }
  }

  // update
  Future<void> updateProject(Project project) async {
    final instance = await IsarService.instance;
    final all = await instance.projectIsars.where().findAll();
    final _project = await instance.projectIsars
        .filter()
        .projectIdEqualTo(project.id.toString())
        .findFirst();
    if (_project != null) {
      int index = all.map((e) => e.id).toList().indexOf(_project.id);
      List<ProjectIsar> newListData = [
        ...all.sublist(0, index),
        ProjectIsar()
          ..id = _project.id
          ..projectData = jsonEncode(project.toJson())
          ..projectId = project.id.toString(),
        ...all.sublist(index + 1, all.length)
      ];
      await instance.writeTxn(() async {
        newListData.forEach((element) async {
          await instance.projectIsars.put(element);
        });
      });
    }
  }

  //reset db
  Future<void> resetProject() async {
    final instance = await IsarService.instance;
    if (instance.isOpen == true) {
      List<ProjectIsar> isarPostList =
          await instance.projectIsars.where().findAll();
      await instance.writeTxn(() async {
        for (var post in isarPostList) {
          await instance.projectIsars.delete(post.id);
        }
      });
    }
  }

  // get
  Future<List<Project>> getProjects() async {
    final instance = await IsarService.instance;
    final allIsarCollections = await instance.projectIsars.where().findAll();
    final List<Project> results = allIsarCollections.map((element) {
      return Project.fromJson(jsonDecode(element.projectData!));
    }).toList();
    return results;
  }

  Future deletePostIsar(Project project) async {
    final instance = await IsarService.instance;
    if (instance.isOpen == true) {
      await instance.writeTxn(() async {
        await instance.projectIsars
            .filter()
            .projectIdEqualTo(project.id.toString())
            .deleteAll();
      });
    }
  }
}
