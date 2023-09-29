import 'dart:math';

class Project {
  int id;
  final String title;
  final List<dynamic> listMedia;

  Project({required this.id, this.title = "Untitled", required this.listMedia});

  String getInfor() {
    return "id: ${this.id},title: ${this.title}, listMedia: ${this.listMedia}";
  }

  Project copyWith({String? title, List<dynamic>? listMedia}) {
    return Project(
        id: id,
        title: title ?? this.title,
        listMedia: listMedia ?? this.listMedia);
  }
}
