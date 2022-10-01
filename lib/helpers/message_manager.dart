import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class MessageManager {
  static Future<String?> imageSent(
      File image, String currentUid, String msgUid) async {
    final instance = FirebaseStorage.instance;
    String? imageUrl;
    try {
      final reference = instance
          .ref()
          .child('chat_images')
          .child(currentUid)
          .child(DateTime.now().millisecondsSinceEpoch.toString() + '.jpg');

      await reference.putFile(image).whenComplete(() async {
        imageUrl = await reference.getDownloadURL();
      });
    } catch (error) {
      print(error);
    }

    return imageUrl;
  }

  static Future<void> delete(
      String currentUid, String msgUid, String msgId, String msgOwner) async {
    final ownDelete = FirebaseFirestore.instance
        .collection('chats')
        .doc(currentUid)
        .collection('people')
        .doc(msgUid)
        .collection('messages')
        .doc(msgId);
    if (currentUid == msgOwner) {
      await ownDelete.delete();

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(msgUid)
          .collection('people')
          .doc(currentUid)
          .collection('messages')
          .doc(msgId)
          .delete();
    } else {
      await ownDelete.delete();
    }
  }

  static Future<void> seen(String currentUid, String msgUid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(msgUid)
        .collection('people')
        .doc(currentUid)
        .collection('messages')
        .where('seenStatus', isEqualTo: "unseen")
        .get();
    final changeLength = snapshot.docs.length;
    for (int i = 0; i < changeLength; i++) {
      final docId = snapshot.docs[i].id;
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(msgUid)
          .collection('people')
          .doc(currentUid)
          .collection('messages')
          .doc(docId)
          .update({"seenStatus": 'seen'});
    }
  }

  static Future<void> submit(
      {required String message,
      required String currentUid,
      required String widgetUid,
      String? imageUrl}) async {
    try {
      var reference = await FirebaseFirestore.instance
          .collection('chats')
          .doc(currentUid)
          .collection('people')
          .doc(widgetUid)
          .collection('messages')
          .add({
        "message": message,
        "time": Timestamp.now(),
        'userId': currentUid,
        'seenStatus': 'unseen',
        'imageUrl': imageUrl
      });
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(currentUid)
          .collection('people')
          .doc(widgetUid)
          .set({
        "time": Timestamp.now(),
      });
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widgetUid)
          .collection('people')
          .doc(currentUid)
          .collection('messages')
          .doc(reference.id)
          .set({
        "message": message,
        "time": Timestamp.now(),
        'userId': currentUid,
        'seenStatus': 'unseen',
        'imageUrl': imageUrl
      });
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widgetUid)
          .collection('people')
          .doc(currentUid)
          .set({
        "time": Timestamp.now(),
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> getMessages(String currentUid, String widgetUid) async {
    final ref = FirebaseFirestore.instance
        .collection('chats')
        .doc(currentUid)
        .collection('people')
        .snapshots();
  }
}
