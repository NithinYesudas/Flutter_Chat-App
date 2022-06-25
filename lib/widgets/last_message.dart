import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LastMessage extends StatelessWidget {
  LastMessage(this.uid, {Key? key}) : super(key: key);
  final currentUid = FirebaseAuth.instance.currentUser!.uid;
  final String uid;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .doc(currentUid)
            .collection('people')
            .doc(uid)
            .collection('messages')
            .orderBy('time')
            .limitToLast(1)
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text(".....");
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            Map<String, dynamic> myData =
                snapshot.data!.docs[0].data() as Map<String, dynamic>;
            return Text(
              myData['message'],
            );
          } else {
            return const SizedBox();
          }
        });
  }
}
