import 'package:chatapp/widgets/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  late String message = '';

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('time')
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            'https://wallpapers.com/images/high/eiffel-tower-portrait-n5lx5ag2y09fsnvu.jpg'),
                      ),
                    ),
                    height: MediaQuery.of(context).size.height * .82,
                    width: double.infinity,
                    child: ListView.builder(
                        itemCount: snapshots.data!.docs.length,
                        itemBuilder: (ctx, index) {
                          Map<String, dynamic> myData =
                              snapshots.data!.docs[index].data()
                                  as Map<String, dynamic>;

                          return MessageBubble(myData['chats'],
                              myData['userId'].toString(),myData['userImage'].toString(), ValueKey(index));
                        }),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .08,
                    color: Colors.white70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 5),
                          width: MediaQuery.of(context).size.width * .818,
                          height: MediaQuery.of(context).size.height * .07,
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: 'Message',
                              hintText: 'Message',
                              alignLabelWithHint: true,
                              //isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              focusColor: Colors.redAccent,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 4, color: Colors.black),
                              ),
                            ),
                            keyboardType: TextInputType.multiline,
                            onChanged: (value) {
                              message = value;
                            },
                          ),
                        ),
                        ElevatedButton(
                            style: ButtonStyle(
                             // fixedSize: MaterialStateProperty.all(const Size(30,30)),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.only(
                                    left: 25, right: 22, top: 11, bottom: 11),
                              ),
                              shape: MaterialStateProperty.all(
                                const CircleBorder(),
                              ),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.redAccent),
                            ),
                            onPressed: () async {
                              if (message.isNotEmpty) {
                                try {
                                  controller.clear();

                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  final imageUrl = await FirebaseStorage.instance.ref().child('user_images').child(user!.uid+'.jpg').getDownloadURL();
                                  print(imageUrl + "----------------------------------------");
                                  await FirebaseFirestore.instance
                                      .collection('chats')
                                      .add({
                                    "chats": message,
                                    "time": Timestamp.now(),
                                    'userId': user.uid,
                                    'userImage': imageUrl

                                  });
                                } catch (error) {
                                  print(error);
                                }
                              }
                            },
                            child: const Icon(Icons.send))
                      ],
                    ),
                  )
                ],
              ),
            );
          }
        });
  }
}
