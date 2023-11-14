  int? snapPosition(double x, List<double> list) {
    for (int i = 0; i < list.length; i++) {
      if ((x - list[i]).abs() < 5) {
        return i;
      }
    }
    return null;
  }