// if (_kiem_tra_xem_dang_o_canh_nao.isNotEmpty) {
//             // x1 x2
//             // y1 y2

//             // for selected canh
//             // top: y1 = ...
//             // left: x1 = ..
//             // right: x2 = ..
//             // bottom: y2 = ...

//             // snap
//             // for canh doc
//             //    gan x1: x1 = ..; x2 co the can di chuyen theo x1
//             //    gan x2: x2 = ..; x1 co the can di chuyen theo x2
//             // for canh ngang
//             //    gan y1: y1 = ..; y2 co the can di chuyen theo y1
//             //    gan y2: y2 = ..; y1 co the can di chuyen theo y2

//             for (var ele in _kiem_tra_xem_dang_o_canh_nao) {
//               switch (ele) {
//                 case "top":
//                   final newRatioOffset1 = _selectedPlacement!.ratioOffset[1] +
//                       deltaGlobalPosition.dy / _maxHeight;
//                   if (newRatioOffset1 > 0) {
//                     newPlacement = selectedPlacement.copyWith(
//                         ratioHeight: _selectedPlacement!.ratioHeight -
//                             deltaGlobalPosition.dy / _maxHeight,
//                         ratioOffset: [
//                           newPlacement.ratioOffset[0],
//                           newRatioOffset1
//                         ]);
//                     for (int i = 0; i < _listVerticalPosition.length; i++) {
//                       if (checkInsideDistance(
//                           _listVerticalPosition[i],
//                           newDetailsLocalPosition.dy -
//                               _listPositionOfPointer[1],
//                           5)) {
//                         print("drag top inside");
//                         // cong them doan delta ( chua dung duoc gan gia tri cua _listVerticalPosition[i])
//                         final deltaSnap = (_listVerticalPosition[i] -
//                                 (newDetailsLocalPosition.dy -
//                                     _listPositionOfPointer[1])) /
//                             _maxHeight /
//                             ratio[1];
//                         newPlacement.ratioOffset[1] += deltaSnap;
//                         newPlacement.ratioHeight -= deltaSnap;
//                         newListOverride[1].add(newPlacement.ratioOffset[1]);
//                       }
//                     }
//                   }
//                 case "bottom":
//                   final newRatioHeight = _selectedPlacement!.ratioHeight +
//                       deltaGlobalPosition.dy / _maxHeight;
//                   if (newRatioHeight + newPlacement.ratioOffset[1] < 1) {
//                     newPlacement.ratioHeight = newRatioHeight;
//                     // for (int i = 0; i < _listVerticalPosition.length; i++) {
//                     //   if (checkInsideDistance(
//                     //       _listVerticalPosition[i],
//                     //       newDetailsLocalPosition.dy +
//                     //           _listPositionOfPointer[3],
//                     //       5)) {
//                     //     print("bottom inside");
//                     //     final deltaSnap = (_listVerticalPosition[i] -
//                     //             (newDetailsLocalPosition.dy +
//                     //                 _listPositionOfPointer[3])) /
//                     //         _maxHeight /
//                     //         ratio[0];
//                     //     newPlacement.ratioHeight += deltaSnap;
//                     //     newListOverride[1].add(newPlacement.ratioOffset[1] +
//                     //         newPlacement.ratioHeight);
//                     //   }
//                     // }
//                   }
//                 case "left":
//                   final newRatioOffset0 = _selectedPlacement!.ratioOffset[0] +
//                       deltaGlobalPosition.dx / _maxWidth;
//                   if (newRatioOffset0 > 0) {
//                     newPlacement = selectedPlacement.copyWith(
//                         ratioWidth: _selectedPlacement!.ratioWidth -
//                             deltaGlobalPosition.dx / _maxWidth,
//                         ratioHeight: newPlacement.ratioHeight,
//                         ratioOffset: [
//                           newRatioOffset0,
//                           newPlacement.ratioOffset[1]
//                         ]);
//                     for (int i = 0; i < _listHorizontalPosition.length; i++) {
//                       if (checkInsideDistance(
//                           _listHorizontalPosition[i],
//                           newDetailsLocalPosition.dx -
//                               _listPositionOfPointer[0],
//                           5)) {
//                         print("left inside");
//                         final deltaSnap = (_listHorizontalPosition[i] -
//                                 (newDetailsLocalPosition.dx -
//                                     _listPositionOfPointer[0])) /
//                             _maxWidth /
//                             ratio[0];
//                         newPlacement.ratioOffset[0] += deltaSnap;
//                         newPlacement.ratioWidth -= deltaSnap;
//                         newListOverride[0].add(newPlacement.ratioOffset[0]);
//                       }
//                     }
//                   }
//                 case "right":
//                   final newRatioHeight = _selectedPlacement!.ratioWidth +
//                       deltaGlobalPosition.dx / _maxWidth;
//                   if (newRatioHeight + newPlacement.ratioOffset[0] < 1) {
//                     newPlacement.ratioWidth = _selectedPlacement!.ratioWidth +
//                         deltaGlobalPosition.dx / _maxWidth;
//                     for (int i = 0; i < _listHorizontalPosition.length; i++) {
//                       if (checkInsideDistance(
//                           _listHorizontalPosition[i],
//                           newDetailsLocalPosition.dx +
//                               _listPositionOfPointer[2],
//                           5)) {
//                         print("right inside");
//                         final deltaSnap = (_listHorizontalPosition[i] -
//                                 (newDetailsLocalPosition.dx +
//                                     _listPositionOfPointer[2])) /
//                             _maxWidth /
//                             ratio[0];
//                         newPlacement.ratioWidth += deltaSnap;
//                         newListOverride[0].add(newPlacement.ratioOffset[0] +
//                             newPlacement.ratioWidth);
//                       }
//                     }
//                   }
//                 default:
//                   break;
//               }
//             }
//           } else {
//             newPlacement = selectedPlacement.copyWith(ratioOffset: [
//               _selectedPlacement!.ratioOffset[0] +
//                   deltaGlobalPosition.dx / _maxWidth,
//               _selectedPlacement!.ratioOffset[1] +
//                   deltaGlobalPosition.dy / _maxHeight
//             ]);
//             // check snap thay doi vi tri
//             for (int i = 0; i < _listVerticalPosition.length; i++) {
//               if (checkInsideDistance(_listVerticalPosition[i],
//                   newDetailsLocalPosition.dy - _listPositionOfPointer[1], 2)) {
//                 print("top inside");
//                 // cong them doan delta ( chua dung duoc gan gia tri cua _listVerticalPosition[i])
//                 final deltaSnap = (_listVerticalPosition[i] -
//                         (newDetailsLocalPosition.dy -
//                             _listPositionOfPointer[1])) /
//                     _maxHeight /
//                     ratio[1];
//                 newPlacement.ratioOffset[1] += deltaSnap;
//                 newListOverride[1].add(newPlacement.ratioOffset[1]);
//               }
//               if (checkInsideDistance(_listVerticalPosition[i],
//                   newDetailsLocalPosition.dy + _listPositionOfPointer[3], 2)) {
//                 print("bottom inside");
//                 final deltaSnap = (_listVerticalPosition[i] -
//                         (newDetailsLocalPosition.dy +
//                             _listPositionOfPointer[3])) /
//                     _maxHeight /
//                     ratio[0];
//                 newPlacement.ratioOffset[1] += deltaSnap;
//                 final result =
//                     newPlacement.ratioOffset[1] + newPlacement.ratioHeight;
//                 print('result ${result}');
//                 newListOverride[1].add(
//                     newPlacement.ratioOffset[1] + newPlacement.ratioHeight);
//               }
//             }
//             for (int i = 0; i < _listHorizontalPosition.length; i++) {
//               if (checkInsideDistance(_listHorizontalPosition[i],
//                   newDetailsLocalPosition.dx - _listPositionOfPointer[0], 2)) {
//                 print("left inside");
//                 final deltaSnap = (_listHorizontalPosition[i] -
//                         (newDetailsLocalPosition.dx -
//                             _listPositionOfPointer[0])) /
//                     _maxWidth /
//                     ratio[0];
//                 newPlacement.ratioOffset[0] += deltaSnap;
//                 newListOverride[0].add(newPlacement.ratioOffset[0]);
//               }
//               if (checkInsideDistance(_listHorizontalPosition[i],
//                   newDetailsLocalPosition.dx + _listPositionOfPointer[2], 2)) {
//                 print("right inside");
//                 final deltaSnap = (_listHorizontalPosition[i] -
//                         (newDetailsLocalPosition.dx +
//                             _listPositionOfPointer[2])) /
//                     _maxWidth /
//                     ratio[0];
//                 newPlacement.ratioOffset[0] += deltaSnap;
//                 newListOverride[0]
//                     .add(newPlacement.ratioOffset[0] + newPlacement.ratioWidth);
//               }
//             }
//           }















  // Placement abc({
  //   required Placement newPlacement,
  //   required Offset newDetailsLocalPosition,
  //   required List<double> ratio,
  //   required bool isTapEdge,
  // }) {
  //   List<List<double>> newListOverride = [[], []];
  //   Placement _newPlacement = newPlacement.copyWith();
  //   for (int i = 0; i < _listVerticalPosition.length; i++) {
  //     if (checkInsideDistance(_listVerticalPosition[i],
  //         newDetailsLocalPosition.dy - _listPositionOfPointer[1], 5)) {
  //       print("top inside");
  //       // cong them doan delta ( chua dung duoc gan gia tri cua _listVerticalPosition[i])
  //       final deltaSnap = (_listVerticalPosition[i] -
  //               (newDetailsLocalPosition.dy - _listPositionOfPointer[1])) /
  //           _maxHeight /
  //           ratio[1];
  //       _newPlacement.ratioOffset[1] += deltaSnap;
  //       if (isTapEdge) {
  //         _newPlacement.ratioHeight -= deltaSnap;
  //       }
  //       newListOverride[1].add(_newPlacement.ratioOffset[1]);
  //     }
  //     if (checkInsideDistance(_listVerticalPosition[i],
  //         newDetailsLocalPosition.dy + _listPositionOfPointer[3], 5)) {
  //       print("bottom inside");
  //       final deltaSnap = (_listVerticalPosition[i] -
  //               (newDetailsLocalPosition.dy + _listPositionOfPointer[3])) /
  //           _maxHeight /
  //           ratio[0];
  //       _newPlacement.ratioOffset[1] += deltaSnap;
  //       // if (isTapEdge) {
  //       //   newPlacement.ratioOffset[1] += deltaSnap;x
  //       // }
  //       newListOverride[1]
  //           .add(_newPlacement.ratioOffset[1] + _newPlacement.ratioHeight);
  //     }
  //   }
  //   for (int i = 0; i < _listHorizontalPosition.length; i++) {
  //     if (checkInsideDistance(_listHorizontalPosition[i],
  //         newDetailsLocalPosition.dx - _listPositionOfPointer[0], 5)) {
  //       print("left inside");
  //       final deltaSnap = (_listHorizontalPosition[i] -
  //               (newDetailsLocalPosition.dx - _listPositionOfPointer[0])) /
  //           _maxWidth /
  //           ratio[0];
  //       _newPlacement.ratioOffset[0] += deltaSnap;
  //       if (isTapEdge) {
  //         _newPlacement.ratioWidth -= deltaSnap;
  //       }
  //       newListOverride[0].add(_newPlacement.ratioOffset[0]);
  //     }
  //     if (checkInsideDistance(_listHorizontalPosition[i],
  //         newDetailsLocalPosition.dx + _listPositionOfPointer[2], 5)) {
  //       print("right inside");
  //       final deltaSnap = (_listHorizontalPosition[i] -
  //               (newDetailsLocalPosition.dx + _listPositionOfPointer[2])) /
  //           _maxWidth /
  //           ratio[0];
  //       _newPlacement.ratioOffset[0] += deltaSnap;
  //       newListOverride[0]
  //           .add(_newPlacement.ratioOffset[0] + _newPlacement.ratioWidth);
  //     }
  //   }
  //   _listOverride = newListOverride;
  //   return _newPlacement;
  // }
