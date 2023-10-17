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

List extractList1(List<int> layout, List list) {
  List result = [];
  List list_du_lieu_cho_moi_page = _du_lieu_cho_moi_page(layout, list);
  for (int i = 0; i < list_du_lieu_cho_moi_page.length; i++) {
    result
        .add(_phan_tac_du_lieu_tung_page(layout, list_du_lieu_cho_moi_page[i]));
  }
  return result;
}

List _du_lieu_cho_moi_page(List<int> layout, List list) {
  return extractList(layout.reduce((value, element) => value + element), list);
}

List _phan_tac_du_lieu_tung_page(List<int> layout, List list) {
  List<List<dynamic>> result = [];
  int currentIndex = 0;
  for (int i = 0; i < layout.length; i++) {
    List<dynamic> row = [];

    for (int j = 0; j < layout[i]; j++) {
      if (currentIndex < list.length) {
        row.add(list[currentIndex]);
        currentIndex++;
      }
    }
    result.add(row);
  }
  return result;
}

// list: [q,w,e,r,t,y,u,i,o,p,a,s,d,f]


// layout: [1] => [[[q]],[[w]],[[e]],[[r]],[[t]],[[y]],[[u]],[[i]],[[o]],[[p]],[[[a]]],[[s]],[[d]],[[f]]];

// layout: [1,2] => [
//   [[q],[w,e]],
//   [[r],[t,y]],
//   [[u],[i,o]],
//   [[p],[a,s]],
//   [[d],[f,null]],
//   ];

// layout: [1,2,3] => [
//   [[q],[w,e],[r,t,y]],
//   [[u],[i,o],[p,a,s]],
//   [[d],[f,null],[null,null,null]]]



