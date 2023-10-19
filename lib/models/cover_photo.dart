import 'dart:io';

class CoverPhoto {
  /// [frontPhoto] can be String, File to show Image
  dynamic frontPhoto;

  /// [backPhoto] can be String, File to show Image
  dynamic backPhoto;
  CoverPhoto({this.backPhoto, this.frontPhoto});

  CoverPhoto copyWith({dynamic frontPhoto, dynamic backPhoto}) {
    return CoverPhoto(
        frontPhoto: frontPhoto ?? this.frontPhoto,
        backPhoto: backPhoto ?? this.backPhoto);
  }

  Map<String, dynamic> toJson() {
    return {
      'frontPhoto': frontPhoto?.path,
      'backPhoto': backPhoto?.path,
    };
  }

  factory CoverPhoto.fromJson(Map<String, dynamic> json) {
    return CoverPhoto(
      frontPhoto: json['frontPhoto'] != null
          ? File(json['frontPhoto'])
          : json['frontPhoto'],
      backPhoto: json['backPhoto'] != null
          ? File(json['backPhoto'])
          : json['backPhoto'],
    );
  }

  String getInfor() {
    return ("frontPhoto: ${this.frontPhoto}, backPhoto: ${this.backPhoto}");
  }
}

