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
    List<double> listRoot, List<double> listValue, String operation) {
  switch (operation) {
    case "+":
      return [
        listRoot[0] + listValue[0],
        listRoot[1] + listValue[1],
      ];
    case "-":
      return [
        listRoot[0] - listValue[0],
        listRoot[1] - listValue[1],
      ];
    case "*":
      return [
        listRoot[0] * listValue[0],
        listRoot[1] * listValue[1],
      ];
    case "/":
      return [
        listRoot[0] / listValue[0],
        listRoot[1] / listValue[1],
      ];
    default:
      return [listRoot[0], listRoot[1]];
  }
}

abstract class T {}

List<T> reverseObjectToEndList(T obj, List<T> list) {
  List<T> newList = List<T>.from(list);
  int index = list.indexOf(obj);
  if (index == -1) {
    return newList;
  }
  newList.removeAt(index);
  newList.add(obj);
  return newList;
}
