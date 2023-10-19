import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class WHPlacementBoardState {
  final List<double> listWHBoard;

  const WHPlacementBoardState({this.listWHBoard = const []});

  WHPlacementBoardState copyWith({List<double> listWHBoard = const []}) {
    return WHPlacementBoardState(listWHBoard: listWHBoard);
  }
}

// final placementBoardWHControllerProvider =
//     StateNotifierProvider<WHPlacementBoardProvider, WHPlacementBoardState>(
//         (ref) {
//   return WHPlacementBoardProvider();
// });

class WHPlacementBoardProvider extends StateNotifier<WHPlacementBoardState> {
  WHPlacementBoardProvider() : super(const WHPlacementBoardState());
  updateWHPlacementBoard(List<double> listWHBoard) {
    state = state.copyWith(listWHBoard: listWHBoard);
  }
}
