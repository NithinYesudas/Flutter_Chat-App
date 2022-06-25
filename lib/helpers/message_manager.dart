import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
}
