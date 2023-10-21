import 'dart:developer';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:i_spy/helper/helper.dart';

import '../screens/auth_screen.dart';

class FirebaseService {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  String get currentUserID => auth.currentUser!.uid.toString();

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return fireStore.collection("users").where("user_id", isNotEqualTo: currentUserID).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> connectUser({required String roomId}) {
    return fireStore.collection("i_spy").doc(roomId).collection("game_collection").orderBy("time",descending: true).snapshots();
  }

  Future sendImage({required String roomId, required String word, required String image,}) async {
    try {
      await fireStore.collection("i_spy").doc(roomId).collection("game_collection").add({
        "sender_id": currentUserID,
        "word": word,
        "image": image,
        "type": "gameImage",
        "time": DateTime
            .now()
            .millisecondsSinceEpoch,
      });
    } catch(e){
      showToast("Something went Wrong");
      throw Exception(e);
    }
  }

  Future sendMessage({required String roomId, required String word}) async {
    try {
      await fireStore.collection("i_spy").doc(roomId).collection("game_collection").add({
        "sender_id": currentUserID,
        "message": word,
        "type": "message",
        "time": DateTime
            .now()
            .millisecondsSinceEpoch,
      });
    } catch(e){
      showToast("Something went Wrong");
      throw Exception(e);
    }
  }

  Future<String> uploadGameImage(
      {required String gameId, required File file, required Function(double progress) progress}) async {
    try {
      final userProfileImageRef = storage.ref("games").child("$gameId/${DateTime.now().millisecondsSinceEpoch}");
      UploadTask task6 = userProfileImageRef.putFile(file);
      task6.asStream().listen((event) {
        progress(event.bytesTransferred / event.totalBytes);
      });
      return await (await task6).ref.getDownloadURL();
    } catch(e){
      throw Exception(e);
    }
  }

  createUniqueId({required String otherUserId}) {
    String myId = currentUserID;
    if (otherUserId.codeUnits.sum > myId.codeUnits.sum) {
      return "${myId}_$otherUserId";
    } else {
      return "${otherUserId}_$myId";
    }
  }

  // Update User Details to Display list
  Future updateUserInfo() async {
    String? fcmToken = await firebaseMessaging.getToken();
    String uid = auth.currentUser!.uid.toString();
    final userInfo = await fireStore.collection("users").doc(uid).get();
    if (userInfo.exists) {
      // If Fcm not found no need to update again for now.
      if (fcmToken == null) return;
      await fireStore.collection("users").doc(uid).update({
        "fcm_tokens": FieldValue.arrayUnion([fcmToken])
      });
    }
    await fireStore.collection("users").doc(uid).set({
      "user_name": auth.currentUser!.displayName ?? "Anonymous User ${auth.currentUser!.uid.toString()}",
      "fcm_tokens": fcmToken != null ? [fcmToken] : [],
      "user_id": auth.currentUser!.uid.toString(),
    });
  }

  Future signOutUser() async {
    String? fcmToken = await firebaseMessaging.getToken();
    String uid = auth.currentUser!.uid.toString();
    if (fcmToken == null) return;
    await fireStore.collection("users").doc(uid).update({
      "fcm_tokens": FieldValue.arrayRemove([fcmToken])
    });
    await auth.signOut();
    GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    Get.offAll(() => const AuthenticationScreen());
  }
}
