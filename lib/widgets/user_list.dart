import 'package:chatapp/widgets/last_message.dart';
import 'package:chatapp/widgets/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserList extends StatelessWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fireStore = FirebaseFirestore.instance;
    final mediaQuery = MediaQuery.of(context).size;
    return StreamBuilder(
        stream: fireStore
            .collection('users')
            .where(FieldPath.documentId,
                isNotEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
                itemCount: snapshots.data!.docs.length,
                itemBuilder: (ctx, index) {
                  Map<String, dynamic> myData = snapshots.data!.docs[index]
                      .data() as Map<String, dynamic>;
                  return SizedBox(
                    height: mediaQuery.height * .12,
                    width: mediaQuery.width,
                    child: Column(
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
                          title: Text(myData['username']),
                          leading: CircleAvatar(
                            radius: mediaQuery.width * .08,
                            backgroundImage: NetworkImage(myData['userImage']),
                          ),
                          subtitle: LastMessage(myData['userid']),
                        ),
                        const Divider(
                          height: 0,
                          thickness: 1,
                        )
                      ],
                    ),
                  );
                });
          }
        });
  }
}
