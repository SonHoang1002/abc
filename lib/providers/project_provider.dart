import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_to_pdf/models/project.dart';

@immutable
class ProjectState {
  final List<Project> listProject;

  const ProjectState({this.listProject = const []});

  ProjectState copyWith({List<Project> listProject = const []}) {
    return ProjectState(listProject: listProject);
  }
}

final projectControllerProvider =
    StateNotifierProvider<ProjectProvider, ProjectState>((ref) {
  return ProjectProvider();
});

class ProjectProvider extends StateNotifier<ProjectState> {
  ProjectProvider() : super(const ProjectState());

  setProject(List<Project> listProject) {
    state = state.copyWith(listProject: listProject);
  }

  reset() {
    state = const ProjectState();
  }

  updateProject(Project newProject) {
    final List<Project> _listProject = state.listProject;
    final int index =
        _listProject.indexWhere((element) => element.id == newProject.id);
    if (index != -1) {
      state = state.copyWith(listProject: [
        ..._listProject.sublist(0, index),
        newProject,
        ..._listProject.sublist(index + 1, _listProject.length)
      ]);
    }
  }

  addProject(Project project) {
    state = state.copyWith(listProject: [project, ...state.listProject]);
  }
}
