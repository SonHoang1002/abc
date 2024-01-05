import 'package:android_id/android_id.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<DocumentReference<Map<String, dynamic>>> _getAndroidDocument(
    String? androidId) async {
  try {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference<Map<String, dynamic>> docRef =
        db.collection("users").doc(androidId);
    return docRef;
  } catch (e) {
    throw e;
  }
}

void sendFirebaseAndroidId() async {
  try {
    String? androidId = await _getAndroidId();
    var docRef = await _getAndroidDocument(androidId);
    var doc = await docRef.get();
    if (doc.data() == null || !doc.exists) {
      docRef
          .set({"id": androidId, "isRating": false})
          .then((void x) => print("Add id success"))
          .onError((Object? error, StackTrace stackTrace) =>
              print("Add id error: $error"));
    }
  } catch (e) {
    throw e;
  }
}

Future<String?> _getAndroidId() async {
  String? androidId = await const AndroidId().getId();
  return androidId;
}

Future<bool> checkRating() async {
  try {
    String? androidId = await _getAndroidId();
    var docRef = await _getAndroidDocument(androidId);
    var doc = await docRef.get();
    if (doc.exists && doc.data()?["isRating"] == true) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return true;
  }
}

Future updateRating() async {
  try {
    String? androidId = await _getAndroidId();
    var docRef = await _getAndroidDocument(androidId);
    var doc = await docRef.get();
    if (doc.data() != null && doc.exists) {
      docRef
          .update({"isRating": true, "id": androidId})
          .then((void x) => print(
              " ------------------------- Update rating status to true ------------------------- "))
          .onError((Object? error, StackTrace stackTrace) => print(
              " ------------------------- Update rating error: $error  ------------------------- "));
    } else {
      docRef
          .set({"isRating": true, "id": androidId})
          .then((void x) => print(
              " ------------------------- Update (with create when doc is null) rating status to true ------------------------- "))
          .onError((Object? error, StackTrace stackTrace) => print(
              " ------------------------- Update (with create when doc is null) rating error: $error  ------------------------- "));
    }
  } catch (e) {
    throw e;
  }
}

Future testDeleteRating() async {
  try {
    String? androidId = await _getAndroidId();
    var docRef = await _getAndroidDocument(androidId);
    var doc = await docRef.get();
    if (doc.data() != null && doc.exists) {
      docRef
          .delete()
          .then((void x) => print(
              " ------------------------- Delete succesfully ------------------------- "))
          .onError((Object? error, StackTrace stackTrace) => print(
              " ------------------------- Delete error: $error  ------------------------- "));
    }
  } catch (e) {
    print("testDeleteRating error: ${e}");
    throw e;
  }
}
