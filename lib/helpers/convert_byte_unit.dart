/// [Input] is KB , [Output] is KB or MB
String convertByteUnit(double input) {
  final kToM = input / 1024;
  if (kToM > 1) {
    return "${kToM.toStringAsFixed(2)} MB";
  } else {
    return "${input.toStringAsFixed(2)} KB";
  }
}
