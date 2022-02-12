import 'dart:core';
import 'package:chatapp/widgets/last_message.dart';
import 'package:chatapp/widgets/messages.dart';
import 'package:chatapp/widgets/unread_messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserList extends StatelessWidget {
  final fireStore = FirebaseFirestore.instance;
  UserList({Key? key}) : super(key: key);
  final currentUid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;

    return StreamBuilder(
        stream: fireStore
            .collection('chats')
            .doc(currentUid)
            .collection('people')
            .orderBy('time')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshots.hasData && snapshots.data!.docs.isNotEmpty) {
            return ListView.builder(
                itemCount: snapshots.data!.docs.length,
                itemBuilder: (ctx, index) {
                  String docId =
                      snapshots.data!.docs.reversed.toList()[index].id;
                  return FutureBuilder(
                      future: fireStore.collection('users').doc(docId).get(),
                      builder:
                          (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox();
                        } else if (snapshot.hasData == false) {
                          return const Center(
                            child: Text("No chats yet"),
                          );
                        }
                        Map<String, dynamic> myData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        return Column(
                          children: [
                            ListTile(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => Messages(
                                          uid: myData['userid'],
                                          userName: myData['username'],
                                          imageUrl: myData['userImage'],
                                        )));
                              },
                              contentPadding: const EdgeInsets.all(5),
                              trailing: UnreadMessages(myData['userid']),
                              title: Text(
                                myData['username'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 20),
                              ),
                              leading: CircleAvatar(
                                radius: mediaQuery.width * .08,
                                backgroundImage:
                                    NetworkImage(myData['userImage']),
                              ),
                              subtitle: LastMessage(myData['userid']),
                              // trailing: const UnreadMessages(),
                            ),
                            const Divider(
                              height: 0,
                              thickness: 1,
                            )
                          ],
                        );
                      });
                });
          } else {
            return const Center(
              child: Text("No messages yet"),
            );
          }
        });
  }
}
