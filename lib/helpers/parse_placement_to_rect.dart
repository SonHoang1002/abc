import 'package:photo_to_pdf/models/placement.dart';

Rectangle1? placementToRectangle(Placement? pl, List<double> ratios) {
  if(pl==null ) return null;
  return Rectangle1(
      id: pl.id,
      x: pl.ratioOffset[0] * ratios[0],
      y: pl.ratioOffset[1] * ratios[1],
      width: pl.ratioWidth * ratios[0],
      height: pl.ratioHeight * ratios[1]);
}
