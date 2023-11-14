import 'package:android_id/android_id.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void sendFirebaseAndroidId() async {
  String? androidId = await _getAndroidId();
  FirebaseFirestore db = FirebaseFirestore.instance;
  DocumentSnapshot<Map<String, dynamic>> doc =
      await db.collection("users").doc(androidId).get();
  if (doc.data() == null || !doc.exists) {
    db
        .collection("users")
        .doc(androidId)
        .set({"id": androidId})
        .then((void x) => print("Add id success"))
        .onError((Object? error, StackTrace stackTrace) =>
            print("Add id error: $error"));
  }
}

Future<String?> _getAndroidId() async {
  String? androidId = await const AndroidId().getId();
  return androidId;
}

Future<bool> checkRating() async {
  String? androidId = await _getAndroidId();
  FirebaseFirestore db = FirebaseFirestore.instance;
  DocumentSnapshot<Map<String, dynamic>> isRating =
      await db.collection("users").doc(androidId).get();
  print("isRating ${isRating.data()}");
  if (isRating.data() != null && isRating.data()?["isRating"] == true) {
    return true;
  } else {
    return false;
  }
}

Future updateRating() async {
  print("call updateRating");
  String? androidId = await _getAndroidId();
  FirebaseFirestore db = FirebaseFirestore.instance;
  DocumentSnapshot<Map<String, dynamic>> doc =
      await db.collection("users").doc(androidId).get();
  print("doc data: ${doc.data()}");
  if (doc.data() != null || doc.exists) {
    print("0000");
    db
        .collection("users")
        .doc(androidId)
        .update({"isRating": true, "id": androidId})
        // .set({"isRating": true, "id": androidId}, SetOptions(merge: true))
        .then((void x) => print(
            " ------------------------- Update rating status to true ------------------------- "))
        .onError((Object? error, StackTrace stackTrace) => print(
            " ------------------------- Update rating error: $error  ------------------------- "));
  }
}
