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
        stream: fireStore.collection('users').where(FieldPath.documentId, isNotEqualTo: FirebaseAuth.instance.currentUser?.uid).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
                itemCount: snapshots.data!.docs.length,
                itemBuilder: (ctx, index) {
                  Map<String, dynamic> myData = snapshots.data!.docs[index]
                      .data() as Map<String, dynamic>;
                  return ListTile(
                    contentPadding:const EdgeInsets.all(10),
                    title: Text(myData['username']),
                    leading: CircleAvatar(radius: mediaQuery.width*.08, backgroundImage: NetworkImage(myData['userImage']),),
                  );
                });
          }
        });
  }
}
