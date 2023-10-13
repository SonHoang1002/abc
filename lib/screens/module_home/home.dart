import 'dart:io';
import 'package:photo_to_pdf/services/isar_project_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as flutter_riverpod;
import 'package:image_picker/image_picker.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/extract_list.dart';
import 'package:photo_to_pdf/helpers/pick_media.dart';
import 'package:photo_to_pdf/helpers/random_number.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/providers/project_provider.dart';
import 'package:photo_to_pdf/screens/module_editor/editor.dart';
import 'package:photo_to_pdf/screens/module_setting/setting.dart';
import 'package:photo_to_pdf/widgets/project_items/w_project_item_home.dart';
import 'package:photo_to_pdf/widgets/w_button.dart';
import 'package:photo_to_pdf/widgets/project_items/w_project_item_bottom.dart';
import 'package:photo_to_pdf/widgets/w_spacer.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class HomePage extends flutter_riverpod.ConsumerStatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  flutter_riverpod.ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends flutter_riverpod.ConsumerState<HomePage> {
  final String PHOTO_TO_PDF = "Photo to PDF";
  final String CONTENT_PHOTO_TO_PDF =
      "Easily create PDF documents from your photos";
  int _naviSelected = 0;
  late bool _isFocusProjectList;
  late bool _isFocusProjectListBottom;
  late List<Project> _listProject;
  late Project _currentProject;

  @override
  void dispose() {
    _listProject = [];
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final List<Project> listProject =
          await IsarProjectService().getProjects();
      ref.read(projectControllerProvider.notifier).setProject(listProject);
    });
    _isFocusProjectList = false;
    _isFocusProjectListBottom = true;
  }

  int getLayoutImageNumber(
    Project project,
  ) {
    if (project.useAvailableLayout) {
      if (project.layoutIndex == 0) {
        return 1;
      } else if (project.layoutIndex == 1) {
        return 2;
      } else {
        return 3;
      }
    } else {
      return (project.placements?.length) ?? 0;
    }
  }

  List<double> _getRatioProject(Project project, List<double> oldRatioTarget) {
    if (project.paper?.width != null &&
        project.paper?.width != 0 &&
        project.paper?.height != null &&
        project.paper?.height != 0) {
      final heightForWidth = (project.paper!.height / project.paper!.width);

      final result = [oldRatioTarget[0], oldRatioTarget[0] * heightForWidth];
      return result;
    }
    return oldRatioTarget;
  }

  @override
  Widget build(BuildContext context) {
    _listProject = ref.watch(projectControllerProvider).listProject;
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _listProject.isNotEmpty && _naviSelected == 0
            ? AppBar(
                centerTitle: true,
                title: WTextContent(
                  value: "All Files",
                  textSize: 15,
                  textLineHeight: 17.9,
                  textColor: Theme.of(context).textTheme.titleLarge!.color,
                ),
                shadowColor: transparent,
                actions: [
                  _isFocusProjectList
                      ? Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(right: 10),
                          child: WTextContent(
                              value: "Done",
                              textColor: colorBlue,
                              textSize: 15,
                              textLineHeight: 17.9,
                              onTap: () {
                                setState(
                                  () {
                                    _isFocusProjectList = false;
                                  },
                                );
                              }),
                        )
                      : const SizedBox()
                ],
                backgroundColor: Theme.of(context).canvasColor)
            : null,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                  child: Container(
                      alignment: Alignment.center, child: _buildBody())),
              _buildBottomNavigatorButtons()
            ],
          ),
        ));
  }

  Widget _buildBody() {
    if (_naviSelected == 0) {
      if (_listProject.isEmpty) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            WTextContent(
                value: PHOTO_TO_PDF,
                textAlign: TextAlign.center,
                textSize: 32,
                textColor: Theme.of(context).textTheme.displayLarge!.color,
                textLineHeight: 38.19),
            WSpacer(height: 10),
            WTextContent(
                value: CONTENT_PHOTO_TO_PDF,
                textAlign: TextAlign.center,
                textSize: 14,
                textFontWeight: FontWeight.w500,
                textColor: Theme.of(context).textTheme.displayLarge!.color,
                textLineHeight: 16.71),
            WSpacer(height: 20),
            WButtonElevated(
              message: "Select Photos",
              height: 60,
              width: 255,
              backgroundColor: colorBlue,
              textColor: colorWhite,
              elevation: 10,
              shadowColor: Colors.blue,
              onPressed: () {
                setState(() {
                  _currentProject =
                      Project(id: getRandomNumber(), listMedia: []);
                });
                _buildBottomSheetCreatePdf();
              },
            )
          ],
        );
      } else {
        return ReorderableGridView.count(
          padding: const EdgeInsets.only(
            top: 10,
            bottom: 120,
          ),
          shrinkWrap: true,
          crossAxisSpacing: 5,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              final tempListProject = _listProject;
              final element = tempListProject.removeAt(oldIndex);
              tempListProject.insert(newIndex, element);
              ref
                  .read(projectControllerProvider.notifier)
                  .setProject(tempListProject);
            });
          },
          onDragStart: (dragIndex) {
            setState(() {
              _isFocusProjectList = true;
            });
          },
          children: _listProject.map((e) {
            final index = _listProject.indexOf(e);
            return Container(
              key: ValueKey(_listProject[index]),
              child: WProjectItemHome(
                key: ValueKey(_listProject[index]),
                project: _listProject[index],
                isFocusByLongPress: _isFocusProjectList,
                index: index,
                layoutExtractList: _listProject[index].useAvailableLayout &&
                            _listProject[index].layoutIndex == 0 ||
                        (_listProject[index].layoutIndex != 0 &&
                            _listProject[index].listMedia.isEmpty)
                    ? null
                    : extractList(getLayoutImageNumber(_listProject[index]),
                        _listProject[index].listMedia)[0],
                onTap: () {
                  pushCustomMaterialPageRoute(
                      context, Editor(project: _listProject[index]));
                },
                ratioTarget: _getRatioProject(
                    _listProject[index], LIST_RATIO_PROJECT_ITEM),
              ),
            );
          }).toList(),
        );
      }
    } else if (_naviSelected == 2) {
      return const Setting();
    }
    return const SizedBox();
  }

  Widget _buildBottomNavigatorButtons() {
    return Container(
      color: Theme.of(context).canvasColor,
      height: 112,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonNavi(
              iconValue: "${pathPrefixIcon}icon_union_files.png",
              name: "All Files",
              isSelected: _naviSelected == 0,
              onTap: () {
                setState(() {
                  _naviSelected = 0;
                });
              }),
          _buildButtonNaviPlus(),
          _buildButtonNavi(
              iconValue: "${pathPrefixIcon}icon_setting.png",
              name: "Settings",
              isSelected: _naviSelected == 2,
              onTap: () {
                setState(() {
                  _naviSelected = 2;
                });
              }),
        ],
      ),
    );
  }

  Widget _buildButtonNavi(
      {String? iconValue,
      String? name,
      bool? isSelected = false,
      Function()? onTap}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 50, maxHeight: 65),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            iconValue != null
                ? Image.asset(
                    iconValue,
                    color: isSelected == true
                        ? colorBlue
                        : Theme.of(context).textTheme.titleMedium!.color,
                    height: 32.76,
                    width: 26.63,
                  )
                : const SizedBox(),
            name != null
                ? WTextContent(
                    value: name,
                    textSize: 13,
                    textColor: isSelected == true
                        ? colorBlue
                        : Theme.of(context).textTheme.titleMedium!.color,
                    textLineHeight: 15.51,
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  Widget _buildButtonNaviPlus() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _currentProject = Project(id: getRandomNumber(), listMedia: []);
        });
        _buildBottomSheetCreatePdf();
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        elevation: 10,
        shadowColor: const Color(0xFFB250FF),
      ),
      child: Container(
        width: 50.0,
        height: 50.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Color(0xFF4378FF),
              Color(0xFFB250FF),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.only(top: 7),
          child: Image.asset(
            "${pathPrefixIcon}icon_plus.png",
            scale: 4,
          ),
        ),
      ),
    );
  }

  _buildBottomSheetCreatePdf() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStatefull) {
            return Container(
                height: MediaQuery.sizeOf(context).height * 0.95,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(bottom: 7),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              child: WTextContent(
                                value: "Create PDF",
                                textSize: 14,
                                textLineHeight: 16.71,
                                textColor: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .color,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(),
                                GestureDetector(
                                  onTap: () {
                                    popNavigator(context);
                                  },
                                  child: Container(
                                      height: 30,
                                      width: 30,
                                      margin: const EdgeInsets.only(
                                          right: 10, top: 10),
                                      child: Image.asset(
                                        "${pathPrefixIcon}icon_close.png",
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color,
                                      )),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // show available project list
                    Expanded(
                      child: Container(
                        color: colorGrey.withOpacity(0.1),
                        child: ReorderableGridView.count(
                          padding: const EdgeInsets.only(
                              top: 10, left: 10, right: 10),
                          shrinkWrap: true,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                          crossAxisCount: 3,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              final tempListMedia = _currentProject.listMedia;
                              final element = tempListMedia.removeAt(oldIndex);
                              tempListMedia.insert(newIndex, element);
                              _currentProject = Project(
                                  id: _currentProject.id,
                                  listMedia: tempListMedia);
                            });
                            setStatefull(() {});
                          },
                          onDragStart: (dragIndex) {
                            setStatefull(() {
                              _isFocusProjectListBottom = true;
                            });
                          },
                          children: _currentProject.listMedia.map((e) {
                            final index = _currentProject.listMedia.indexOf(e);
                            return WProjectItemHomeBottom(
                              key: ValueKey(_currentProject.listMedia[index]),
                              project: _currentProject,
                              isFocusByLongPress: _isFocusProjectListBottom,
                              index: index,
                              onRemove: (srcMedia) {
                                setState(() {
                                  _currentProject = _currentProject.copyWith(
                                      listMedia: _currentProject.listMedia
                                          .where(
                                              (element) => element != srcMedia)
                                          .toList());
                                });
                                setStatefull(() {});
                                ref
                                    .read(projectControllerProvider.notifier)
                                    .updateProject(_currentProject);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    // buttons
                    Container(
                      height: 200,
                      padding: const EdgeInsets.only(top: 10),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WSpacer(
                                width: 10,
                              ),
                              Flexible(
                                child: WButtonFilled(
                                  message: "Import Photos",
                                  height: 60,
                                  mediaSize: 20,
                                  textColor: colorRed,
                                  mediaColor: colorRed,
                                  mediaValue:
                                      "${pathPrefixIcon}icon_photos.png",
                                  backgroundColor:
                                      const Color.fromRGBO(255, 63, 51, 0.1),
                                  onPressed: () async {
                                    final result = await pickImage(
                                        ImageSource.gallery, true);
                                    if (result.isNotEmpty) {
                                      _currentProject = _currentProject
                                          .copyWith(listMedia: [
                                        ..._currentProject.listMedia,
                                        ...result
                                      ]);
                                    }
                                    setStatefull(() {});
                                  },
                                ),
                              ),
                              WSpacer(
                                width: 10,
                              ),
                              Flexible(
                                child: WButtonFilled(
                                  message: "Import Files",
                                  height: 60,
                                  mediaSize: 20,
                                  textColor: colorBlue,
                                  mediaColor: colorBlue,
                                  backgroundColor:
                                      const Color.fromRGBO(22, 115, 255, 0.08),
                                  mediaValue: "${pathPrefixIcon}icon_files.png",
                                  onPressed: () async {
                                    List<File> result = await pickFiles();
                                    if (result.isNotEmpty) {
                                      _currentProject = _currentProject
                                          .copyWith(listMedia: [
                                        ..._currentProject.listMedia,
                                        ...result
                                      ]);
                                    }
                                    setStatefull(() {});
                                  },
                                ),
                              ),
                              WSpacer(
                                width: 10,
                              )
                            ],
                          ),
                          WSpacer(
                            height: 20,
                          ),
                          WButtonElevated(
                            message: "Continue",
                            height: 60,
                            width: MediaQuery.sizeOf(context).width * 0.85,
                            backgroundColor: colorBlue,
                            textColor: colorWhite,
                            onPressed: () {
                              ref
                                  .read(projectControllerProvider.notifier)
                                  .addProject(_currentProject);
                              // data on database
                              IsarProjectService().addProject(_currentProject);
                              popNavigator(context);
                              pushNavigator(
                                  context, Editor(project: _currentProject));
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ));
          });
        },
        isScrollControlled: true,
        // enableDrag: false,
        backgroundColor: transparent);
  }
}
