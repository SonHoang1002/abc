  import 'package:flutter/material.dart';

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
    bool containOffset(
      Offset checkOffset, Offset startOffset, Offset endOffset) {
    return (startOffset.dx <= checkOffset.dx &&
            checkOffset.dx <= endOffset.dx) &&
        (startOffset.dy <= checkOffset.dy && checkOffset.dy <= endOffset.dy);
  }