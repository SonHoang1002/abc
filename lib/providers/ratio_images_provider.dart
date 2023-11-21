import 'package:flutter_riverpod/flutter_riverpod.dart';

class RatioWHState {
  final List<double> listRatioWH;

  const RatioWHState({this.listRatioWH = const []});

  RatioWHState copyWith({List<double> listRatioWH = const []}) {
    return RatioWHState(listRatioWH: listRatioWH);
  }
}

final ratioWHImagesControllerProvider =
    StateNotifierProvider<RatioWHProvider, RatioWHState>((ref) {
  return RatioWHProvider();
});

class RatioWHProvider extends StateNotifier<RatioWHState> {
  RatioWHProvider() : super(const RatioWHState());

  setRatioWHImages(List<double> listRatioWH) {
    state = state.copyWith(listRatioWH: listRatioWH);
  }
}
