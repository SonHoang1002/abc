
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
      'frontPhoto': frontPhoto,
      'backPhoto': backPhoto,
    };
  }

  factory CoverPhoto.fromJson(Map<String, dynamic> json) {
    return CoverPhoto(
      frontPhoto: json['frontPhoto'],
      backPhoto: json['backPhoto'],
    );
  }

  void getInfor() {
    print("frontPhoto: ${this.frontPhoto}, backPhoto: ${this.backPhoto}");
  }
}


// class CoverPhoto {
//   /// [frontPhoto] can be String, File to show Image
//   dynamic frontPhoto;

//   /// [backPhoto] can be String, File to show Image
//   dynamic backPhoto;
//   CoverPhoto({this.backPhoto, this.frontPhoto});

//   CoverPhoto copyWith({dynamic frontPhoto, dynamic backPhoto}) {
//     return CoverPhoto(
//         frontPhoto: frontPhoto ?? this.frontPhoto,
//         backPhoto: backPhoto ?? this.backPhoto);
//   }

//   void getInfor() {
//     print("frontPhoto: ${this.frontPhoto}, backPhoto: ${this.backPhoto}");
//   }
// }
