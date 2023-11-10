  // Widget _buildCustomArea() {
  //   return GestureDetector(
  //     key: _testKey,
  //     onTapUp: (details) {
  //       _onFocusRectangle1(details.globalPosition);
  //     },
  //     onTapDown: (details) {
  //       int? index = _checkInsideRectangle(details.globalPosition);
  //     },
  //     onTap: () {
  //       print("ok");
  //     },
  //     onPanUpdate: (details) {
  //       if (_isInside && _indexOfFocusRect != null) {
  //         if (_selectedRectangle1 != null) {
  //           Rectangle1 newRectangle1;
  //           double x1 = _selectedRectangle1!.x + _selectedRectangle1!.width;
  //           double y1 = _selectedRectangle1!.y + _selectedRectangle1!.height;
  //           double y = _selectedRectangle1!.y;
  //           double x = _selectedRectangle1!.x;

  //           // translation
  //           Offset deltaGlobalPosition = details.globalPosition - _startOffset;
  //           final renderBox = _listGlobalKey[_indexOfFocusRect!]
  //               .currentContext
  //               ?.findRenderObject() as RenderBox;
  //           Offset positionRectangle =
  //               renderBox.localToGlobal(const Offset(0, 0));
  //           final renderBox1 =
  //               _testKey.currentContext?.findRenderObject() as RenderBox;
  //           final positionRectangle1 =
  //               renderBox1.localToGlobal(const Offset(0, 0));
  //           // ratio: [0.459, 0.7696]

  //           List<List<double>> newListOverride = [[], []];
  //           if (_kiem_tra_xem_dang_o_canh_nao.isNotEmpty) {
  //             if (_kiem_tra_xem_dang_o_canh_nao.contains("top")) {
  //               y += deltaGlobalPosition.dy;
  //               int? index = _snap(positionRectangle.dy, _listVerticalPosition);
  //               print(
  //                   "1: ${positionRectangle.dy}, 2: ${_listVerticalPosition}");
  //               if (index != null) {
  //                 newListOverride[1].add(_listVerticalPosition[index]);
  //                 final newPoint = Offset(0, _listVerticalPosition[index]);
  //                 final a = renderBox1.globalToLocal(newPoint);
                  
  //               }
  //             }
  //             if (_kiem_tra_xem_dang_o_canh_nao.contains("left")) {
  //               x += deltaGlobalPosition.dx;
  //             }
  //             if (_kiem_tra_xem_dang_o_canh_nao.contains("right")) {
  //               x1 += deltaGlobalPosition.dx;
  //             }
  //             if (_kiem_tra_xem_dang_o_canh_nao.contains("bottom")) {
  //               y1 += deltaGlobalPosition.dy;
  //             }
  //             x = min(_maxWidth, max(0, x));
  //             x1 = min(_maxWidth, max(0, x1));
  //             y = min(_maxHeight, max(0, y));
  //             y1 = min(_maxHeight, max(0, y1));
  //           } else {
  //             var dx = deltaGlobalPosition.dx;
  //             dx = max(-x, min(dx, _maxWidth - x1));
  //             var dy = deltaGlobalPosition.dy;
  //             dy = max(-y, min(dy, _maxHeight - y1));
  //             x += dx;
  //             y += dy;
  //             x1 += dx;
  //             y1 += dy;
  //           }
  //           _listOverride = newListOverride;
  //           newRectangle1 = Rectangle1(
  //               id: _selectedRectangle1!.id,
  //               x: x,
  //               y: y,
  //               width: x1 - x,
  //               height: y1 - y);

  //           //gan
  //           _listRectangle1[_indexOfFocusRect!] = newRectangle1;
  //           setState(() {});
  //           widget.rerenderFunction();
  //         }
  //       }
  //     },
  //     onPanStart: (details) {
  //       if (_indexOfFocusRect != null) {
  //         _selectedRectangle1 = _listRectangle1[_indexOfFocusRect!];
  //         _isInside = _checkInsideCurrentRectangle(details.globalPosition,
  //             checkEdge: true);
  //         _listVerticalPosition.clear();
  //         _listHorizontalPosition.clear();
  //         if (_listRectangle1.isNotEmpty) {
  //           List<GlobalKey> listGlobalKeyWithoutCurrent =
  //               List.from(_listGlobalKey);
  //           listGlobalKeyWithoutCurrent.removeAt(_indexOfFocusRect!);
  //           _listVerticalPosition =
  //               convertNestedListToList(listGlobalKeyWithoutCurrent.map((e) {
  //             int index = listGlobalKeyWithoutCurrent.indexOf(e);
  //             List<Offset> listEdges = _getGlobalEdgePosition(index);
  //             return [listEdges[1].dy, listEdges[2].dy];
  //           }).toList());

  //           _listHorizontalPosition =
  //               convertNestedListToList(listGlobalKeyWithoutCurrent.map((e) {
  //             int index = listGlobalKeyWithoutCurrent.indexOf(e);
  //             List<Offset> listEdges = _getGlobalEdgePosition(index);
  //             return [listEdges[0].dx, listEdges[3].dx];
  //           }).toList());
  //         }
  //       }
  //       _startOffset = details.globalPosition;
  //       setState(() {});
  //       widget.rerenderFunction();
  //     },
  //     child: Stack(alignment: Alignment.center, children: [
  //       // view trang (shadow + thut vao trong)
  //       Container(
  //         alignment: Alignment.center,
  //         padding: const EdgeInsets.symmetric(vertical: 5),
  //         child: Container(
  //           key: _drawAreaKey,
  //           width: _maxWidth,
  //           height: _maxHeight,
  //           decoration:
  //               BoxDecoration(color: widget.backgroundColor, boxShadow: [
  //             BoxShadow(
  //               color: Colors.black.withOpacity(0.2),
  //               spreadRadius: 0.5,
  //               blurRadius: 5,
  //               offset: const Offset(0, 1),
  //             ),
  //           ]),
  //         ),
  //       ),
  //       // rect without selected rect
  //       Container(
  //         alignment: Alignment.center,
  //         width: _maxWidth + 15,
  //         height: _maxHeight + 15,
  //         child: Stack(
  //           children: [
  //             Stack(
  //               children: _listRectangle1
  //                   .where((element) => element.id != _selectedRectangle1?.id)
  //                   .toList()
  //                   .map<Widget>(
  //                 (e) {
  //                   return _buildRectangle1(e);
  //                 },
  //               ).toList(),
  //             ),
  //           ],
  //         ),
  //       ),
  //       //  duong do
  //       SizedBox(
  //         width: _maxWidth,
  //         height: _maxHeight,
  //         child: Stack(children: [
  //           ..._listOverride[0]
  //               .map<Widget>((e) => Positioned(
  //                   left: e,
  //                   child: Container(
  //                     height: _maxHeight,
  //                     margin: const EdgeInsets.only(left: 7),
  //                     width: 1,
  //                     color: colorRed,
  //                   )))
  //               .toList(),
  //           ..._listOverride[1]
  //               .map<Widget>((e) => Positioned(
  //                   top: e,
  //                   child: Container(
  //                     height: 1,
  //                     margin: const EdgeInsets.only(top: 7),
  //                     width: _maxWidth,
  //                     color: colorRed,
  //                   )))
  //               .toList(),
  //         ]),
  //       ),
  //       // selected rect
  //       Container(
  //         alignment: Alignment.center,
  //         width: _maxWidth + 15,
  //         height: _maxHeight + 15,
  //         child: Stack(
  //           children: [
  //             if (_selectedRectangle1 != null)
  //               _buildRectangle1(_selectedRectangle1!),
  //           ],
  //         ),
  //       ),
  //     ]),
  //   );
  //   // gesture
  //   //  view trang (shadow- thut vao trong)
  //   //   rect( duong xanh bao quanh+ hinh tron + so)
  //   //  view( dung global )
  //   //   duong do
  //   //  rect( current )
  // }

  // Widget _buildDotDrag(double size, {EdgeInsets? margin}) {
  //   return Container(
  //     height: size,
  //     width: size,
  //     margin: margin,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(size / 2),
  //       border: Border.all(color: Colors.blue, width: 2),
  //     ),
  //   );
  // }


  // Widget _buildPanGestureWidget(int index) {
  //   return Stack(
  //     children: [
  //       Positioned.fill(
  //           child: Container(
  //         margin: const EdgeInsets.all(6),
  //         decoration:
  //             BoxDecoration(border: Border.all(color: colorBlue, width: 1.5)),
  //       )),
  //       Column(
  //         mainAxisSize: MainAxisSize.max,
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               // dot top left
  //               _buildDotDrag(
  //                 13,
  //                 margin: const EdgeInsets.only(bottom: 7, top: 1, left: 1),
  //               ),
  //               // dot top center
  //               _buildDotDrag(
  //                 9,
  //                 margin: const EdgeInsets.only(bottom: 6),
  //               ),
  //               // dot top right
  //               _buildDotDrag(
  //                 13,
  //                 margin: const EdgeInsets.only(bottom: 6),
  //               )
  //             ],
  //           ),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               //dot center left
  //               _buildDotDrag(
  //                 9,
  //                 margin: const EdgeInsets.only(left: 3),
  //               ),
  //               // dot center right
  //               _buildDotDrag(
  //                 9,
  //                 margin: const EdgeInsets.only(right: 2),
  //               )
  //             ],
  //           ),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               // dot bottom left
  //               _buildDotDrag(
  //                 13,
  //                 margin: const EdgeInsets.only(top: 11, left: 0.5),
  //               ),
  //               // dot bottom center
  //               _buildDotDrag(
  //                 9,
  //                 margin: const EdgeInsets.only(top: 12, bottom: 0.5),
  //               ),
  //               // dot bottom right
  //               _buildDotDrag(
  //                 13,
  //                 margin: const EdgeInsets.only(top: 11),
  //               )
  //             ],
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }
