import 'dart:io';
import 'dart:ui' as ui;
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:photo_to_pdf/helpers/scan_document.dart';
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
import 'package:photo_to_pdf/widgets/project_items/w_project_item_main.dart';
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

  void _disableReOrderFocus() {
    setState(
      () {
        _isFocusProjectList = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // bool isDarkMode = Provider.of<ThemeManager>(context).isDarkMode;
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
                                _disableReOrderFocus();
                              }),
                        )
                      : const SizedBox()
                ],
                backgroundColor: Theme.of(context).canvasColor)
            : null,
        body: Column(
          children: [
            Expanded(child: Container(child: _buildBody())),
            _buildBottomNavigatorButtons()
          ],
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
                textColor: Theme.of(context).textTheme.titleLarge!.color,
                textLineHeight: 16.71),
            WSpacer(height: 20),
            WButtonFilled(
              message: "Select Photos",
              height: 60,
              width: MediaQuery.sizeOf(context).width * 0.6,
              backgroundColor: colorBlue,
              textColor: colorWhite,
              boxShadow: const [
                BoxShadow(
                    color: Color.fromRGBO(28, 91, 255, 0.3),
                    spreadRadius: 5,
                    offset: Offset(0, 8),
                    blurRadius: 40)
              ],
              shadowColor: const Color.fromRGBO(28, 91, 255, 0.3),
              elevation: 10,
              borderRadius: 25,
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
        return GestureDetector(
          onTap: () {
            _disableReOrderFocus();
          },
          child: ReorderableGridView.count(
            padding: const EdgeInsets.only(left: 7, right: 7),
            shrinkWrap: true,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            crossAxisCount: 2,
            childAspectRatio: 9/ 10,
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
            dragWidgetBuilderV2: DragWidgetBuilderV2.createByOldBuilder9(
                (index, child) => _buildProjectItemHome(index)),
            children: _listProject.map((e) {
              final index = _listProject.indexOf(e);
              return _buildProjectItemHome(index);
            }).toList(),
          ),
        );
      }
    } else if (_naviSelected == 2) {
      return const Setting();
    }
    return const SizedBox();
  }

  List? _getEtractList(int index) {
    var result;
    if (_listProject[index].listMedia.isEmpty) return result;
    if (_listProject[index].paper?.title == LIST_PAGE_SIZE[0].title) {
      result = extractList1(
          LIST_LAYOUT_SUGGESTION[0], _listProject[index].listMedia);
    }
    if (_listProject[index].useAvailableLayout) {
      result = extractList1(
          LIST_LAYOUT_SUGGESTION[_listProject[index].layoutIndex],
          _listProject[index].listMedia)[0];
    } else {
      if (_listProject[index].placements != null) {
        result = extractList(_listProject[index].placements!.length,
            _listProject[index].listMedia)[0];
      }
    }
    return result;
  }

  Widget _buildProjectItemHome(int indexOfProject) {
    return WProjectItemEditor(
      key: ValueKey(_listProject[indexOfProject]),
      project: _listProject[indexOfProject],
      isFocusByLongPress: _isFocusProjectList,
      indexImage: indexOfProject,
      layoutExtractList: _getEtractList(indexOfProject),
      title: _listProject[indexOfProject].title,
      useCoverPhoto: true,
      onTap: () {
        pushNavigator(context, Editor(project: _listProject[indexOfProject]));
      },
      onRemove: () async {
        final listProject = ref.watch(projectControllerProvider).listProject;
        final deleteItem = listProject[indexOfProject];
        listProject.removeAt(indexOfProject);
        ref.read(projectControllerProvider.notifier).setProject(listProject);
        await IsarProjectService().deletePostIsar(deleteItem);
      },
      ratioTarget: _getRatioProject(
          _listProject[indexOfProject], LIST_RATIO_PROJECT_ITEM),
    );
  }

  Widget _buildBottomNavigatorButtons() {
    return Container(
      color: Theme.of(context).canvasColor,
      height: 112 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonNavi(
              iconValue: "${PATH_PREFIX_ICON}icon_union_files.png",
              iconValueSelected:
                  "${PATH_PREFIX_ICON}icon_union_files_selected.png",
              name: "All Files",
              isSelected: _naviSelected == 0,
              onTap: () {
                setState(() {
                  _naviSelected = 0;
                });
              }),
          _buildButtonNaviPlus(),
          _buildButtonNavi(
              iconValue: "${PATH_PREFIX_ICON}icon_setting.png",
              iconValueSelected: "${PATH_PREFIX_ICON}icon_setting_selected.png",
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
      {required String iconValue,
      String? name,
      bool? isSelected = false,
      required String iconValueSelected,
      Function()? onTap}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 50, maxHeight: 65),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset(isSelected == true ? iconValueSelected : iconValue,
                height: 32.76,
                width: 26.63,
                color: isSelected != true
                    ? Theme.of(context).textTheme.bodyMedium!.color
                    : null),
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
          _isFocusProjectList = false;
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
            boxShadow: [
              BoxShadow(
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: Offset(0, 8),
                  color: Color.fromRGBO(160, 85, 255, 0.4))
            ]),
        child: Container(
          padding: const EdgeInsets.only(top: 7),
          child: Image.asset(
            "${PATH_PREFIX_ICON}icon_plus.png",
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
                                        "${PATH_PREFIX_ICON}icon_close.png",
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
                          dragWidgetBuilderV2:
                              DragWidgetBuilderV2.createByOldBuilder9(
                                  (index, child) =>
                                      _buildProjectBottomItem(index, () {
                                        setStatefull(() {});
                                      })),
                          children: _currentProject.listMedia.map((e) {
                            final index = _currentProject.listMedia.indexOf(e);
                            return _buildProjectBottomItem(index, () {
                              setStatefull(() {});
                            });
                          }).toList(),
                        ),
                      ),
                    ),
                    // buttons
                    Container(
                      height: 250,
                      padding: const EdgeInsets.only(top: 15),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              //fake shadow
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildFakeShadow(
                                      const Color.fromRGBO(85, 238, 32, 0.05)),
                                  _buildFakeShadow(
                                    colorLightBlue.withOpacity(0.03),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  WButtonFilled(
                                    message: "Photos",
                                    height: 76,
                                    padding: const EdgeInsets.only(top: 2),
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.45,
                                    mediaSize: 25,
                                    textColor:
                                        const Color.fromRGBO(68, 178, 30, 1),
                                    mediaColor:
                                        const Color.fromRGBO(68, 178, 30, 1),
                                    mediaValue:
                                        "${PATH_PREFIX_ICON}icon_photos.png",
                                    backgroundColor:
                                        const Color.fromRGBO(85, 238, 32, 0.15),
                                    onPressed: () async {
                                      final result = await pickImage(
                                          ImageSource.gallery, true);
                                      if (result.isNotEmpty) {
                                        _currentProject = _currentProject
                                            .copyWith(listMedia: [
                                          ..._currentProject.listMedia,
                                          ...result.reversed
                                        ]);
                                      }
                                      setState(() {});
                                      setStatefull(() {});
                                    },
                                  ),
                                  WButtonFilled(
                                      message: "Scan",
                                      height: 76,
                                      width: MediaQuery.sizeOf(context).width *
                                          0.45,
                                      mediaSize: 25,
                                      padding: const EdgeInsets.only(top: 2),
                                      textColor: colorBlue,
                                      mediaColor: colorBlue,
                                      mediaValue:
                                          "${PATH_PREFIX_ICON}icon_scan.png",
                                      backgroundColor:
                                          colorBlue.withOpacity(0.15),
                                      onPressed: () async {
                                        List<String>? imagePaths =
                                            await scanDocument();
                                        //convert path image to pdf -> note.txt
                                        if (imagePaths != null &&
                                            imagePaths.isNotEmpty) {
                                          final List<File> files = imagePaths
                                              .map((e) => File(e))
                                              .toList();
                                          _currentProject = _currentProject
                                              .copyWith(listMedia: [
                                            ..._currentProject.listMedia,
                                            ...files.reversed
                                          ]);
                                        }
                                        setState(() {});
                                        setStatefull(() {});
                                        // use document_scanner_flutter to capture image and parse origin image to binary image
                                        // File? scannedDoc = await DocumentScannerFlutter.launch(context);
                                      }),
                                ],
                              ),
                            ],
                          ),
                          WSpacer(
                            height: 20,
                          ),
                          WButtonFilled(
                            message: "Continue",
                            height: 60,
                            width: MediaQuery.sizeOf(context).width * 0.85,
                            backgroundColor: colorBlue,
                            textColor: colorWhite,
                            onPressed: () async {
                              _currentProject = _currentProject.copyWith(
                                paper: LIST_PAGE_SIZE[0],
                                paddingAttribute: PADDING_OPTIONS,
                                spacingAttribute: SPACING_OPTIONS,
                              );
                              ref
                                  .read(projectControllerProvider.notifier)
                                  .addProject(_currentProject);
                              // data on database
                              popNavigator(context);
                              pushNavigator(
                                  context, Editor(project: _currentProject));
                              await IsarProjectService()
                                  .addProject(_currentProject);
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
        backgroundColor: transparent);
  }

  Widget _buildProjectBottomItem(int index, Function reRenderFunction) {
    return WProjectItemHomeBottom(
      key: ValueKey(getRandomNumber()),
      project: _currentProject,
      isFocusByLongPress: _isFocusProjectListBottom,
      index: index,
      onRemove: (srcMedia) {
        setState(() {
          _currentProject = _currentProject.copyWith(
              listMedia: _currentProject.listMedia
                  .where((element) => element != srcMedia)
                  .toList());
        });
        reRenderFunction();
        // ref
        //     .read(projectControllerProvider.notifier)
        //     .updateProject(_currentProject);
      },
    );
  }

  Widget _buildFakeShadow(Color color) {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        height: 76,
        width: MediaQuery.sizeOf(context).width * 0.45,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(25),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ));
  }
}
