///
/// [number] : số phần tử trong mỗi item của kết quả trả ra
///
/// [list] : danh sách đầu vào
///
/// Ví dụ:
///
///  {number:3,list:[1,2,3,4,5,6,7,8,9]} => [[1,2,3],[4,5,6],[7,8,9]]
///
///  {number:4,list:[1,2,3,4,5,6,7,8,9]} => [[1,2,3,4],[5,6,7,8],[9,null,null,null]]
List extractList(int number, List list) {
  List result = [];

  for (int i = 0; i < list.length; i += number) {
    List sublist = [];
    for (int j = 0; j < number; j++) {
      if (i + j < list.length) {
        sublist.add(list[i + j]);
      } else {
        sublist.add(null);
      }
    }
    result.add(sublist);
  }
  return result;
}
