  /// Use for change list with [rootList], [listValue]
  /// 
  /// [operation]: 0 -> +
  ///
  /// [operation]: 1 -> -
  ///
  /// [operation]: 2 -> x
  ///
  /// [operation]: 3 -> /
  List<double> changeValueOfList(
      List<double> listRoot, List<double> listValue, int operation) {
    switch (operation) {
      case 0:
        return [
          listRoot[0] + listValue[0],
          listRoot[1] + listValue[1],
        ];
      case 1:
        return [
          listRoot[0] - listValue[0],
          listRoot[1] - listValue[1],
        ];
      case 2:
        return [
          listRoot[0] * listValue[0],
          listRoot[1] * listValue[1],
        ];
      case 3:
        return [
          listRoot[0] / listValue[0],
          listRoot[1] / listValue[1],
        ];
      default:
        return [listRoot[0], listRoot[1]];
    }
  }
