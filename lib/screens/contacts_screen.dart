import 'package:chatapp/screens/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId,
                isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (ctx, index) {
                  Map<String, dynamic> myData =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  return ListTile(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => Messages(
                              uid: myData['userid'],
                              userName: myData['username'],
                              imageUrl: myData['userImage'])));
                    },
                    contentPadding: EdgeInsets.all(mediaQuery.width * .02),
                    title: Text(myData['username']),
                    leading: CircleAvatar(
                      radius: mediaQuery.width * .07,
                      backgroundColor: Theme.of(context).primaryColor,
                      backgroundImage: NetworkImage(myData['userImage']),
                    ),
                  );
                });
          } else {
            return const Center(
              child: Text("No contacts"),
            );
          }
        },
      ),
    );
  }
}
