import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class ProjectState {
  final List listProject;

  const ProjectState({this.listProject = const []});

  ProjectState copyWith({List listProject = const []}) {
    return ProjectState(listProject: listProject);
  }
}

final projectControllerProvider =
    StateNotifierProvider<ProjectProvider, ProjectState>((ref) {
  return ProjectProvider();
});

class ProjectProvider extends StateNotifier<ProjectState> {
  ProjectProvider() : super(const ProjectState());

  setProject(List listProject) {
    state = state.copyWith(listProject: listProject);
  }

  reset() {
    state = const ProjectState();
  }
}
