import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UnreadMessages extends StatelessWidget {
  final currentUid = FirebaseAuth.instance.currentUser?.uid;

  UnreadMessages(this.messageUid, {Key? key}) : super(key: key);
  final String messageUid;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      width: 25,
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .doc(currentUid)
              .collection(messageUid)
              .where('seenStatus', isEqualTo: "unseen")
              .snapshots(),
          builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshots) {
            if (snapshots.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              );
            } else if (snapshots.data!.docs.isEmpty) {
              return const SizedBox();
            } else {
              return CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                radius: 8,
                child: Text(
                  snapshots.data!.docs.length.toString(),
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              );
            }
          }),
    );
  }
}
