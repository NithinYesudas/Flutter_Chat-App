import 'package:chatapp/screens/contacts_screen.dart';
import 'package:chatapp/widgets/user_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<void> uploadImageUrl() async {
    print("image uploading");
    final imageUrl = await FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child(FirebaseAuth.instance.currentUser!.uid + '.jpg')
        .getDownloadURL();
    print(imageUrl);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({'userImage': imageUrl}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          "Chat app",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          DropdownButton(
            iconEnabledColor: Colors.white,
            icon: const Icon(Icons.more_vert),
            items: [
              DropdownMenuItem(
                  value: "logout",
                  child: Row(
                    children: const [
                      Icon(
                        Icons.exit_to_app,
                        color: Colors.black,
                      ),
                      Text('Logout')
                    ],
                  ))
            ],
            onChanged: (value) {
              if (value == 'logout') {
                FirebaseAuth.instance.signOut();
              }
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const ContactScreen()));
        },
        child: const Icon(
          Icons.message,
          color: Colors.white,
        ),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (ctx, data) {
          if (data.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            uploadImageUrl();
            return UserList();
          }
        },
      ),
    );
  }
}
