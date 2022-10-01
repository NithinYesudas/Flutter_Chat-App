import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../helpers/message_manager.dart';
import 'message_bubble.dart';

class MessageList extends StatelessWidget {
  MessageList(
      {required this.currentUid,
      required this.msgUid,
      required this.msgSelected,
      Key? key})
      : super(key: key);
  final String currentUid;
  final String msgUid;
  final Function(bool val, String msgId, String msgOwn) msgSelected;
  String? msgId;

  final ValueNotifier<bool> _notifier = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .doc(currentUid)
            .collection("people")
            .doc(msgUid)
            .collection('messages')
            .orderBy('time')
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshots) {
          MessageManager.seen(currentUid, msgUid);

          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshots.data!.docs.isNotEmpty) {
            return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: snapshots.data!.docs.length,
                itemBuilder: (ctx, index) {
                  Map<String, dynamic> myData = snapshots.data!.docs[index]
                      .data() as Map<String, dynamic>;

                  return ValueListenableBuilder(
                      valueListenable: _notifier,
                      builder: (context, bool value, child) {
                        return MessageBubble(
                          seenStatus: myData['seenStatus'],
                          time: myData['time'],
                          message: myData['message'],
                          currentUserId: currentUid,
                          msgUid: myData['userId'],
                          image: myData['imageUrl'] ?? "",
                          isSelected: msgId == snapshots.data!.docs[index].id
                              ? value
                              : false,
                          msgSelected: (bool val, String? msgOwn) {
                            _notifier.value = val;
                            msgId = snapshots.data!.docs[index].id;
                            msgSelected(val, msgId!, msgOwn!);
                          },
                        );
                      });
                });
          } else {
            return const SizedBox();
          }
        });
  }
}
