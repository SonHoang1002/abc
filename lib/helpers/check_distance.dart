  bool checkInsideDistance(
      double checkValue, double checkedValue, double addtionalValue) {
    final rightCheckValue = checkValue + addtionalValue;
    final leftCheckValue = checkValue - addtionalValue;
    if (leftCheckValue < checkedValue && checkedValue < rightCheckValue) {
      return true;
    } else {
      return false;
    }
  }