import 'dart:io';

import 'package:chatapp/helpers/message_manager.dart';
import 'package:chatapp/screens/image_sent.dart';
import 'package:chatapp/widgets/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class Messages extends StatefulWidget {
  const Messages(
      {Key? key,
      required this.uid,
      required this.userName,
      required this.imageUrl})
      : super(key: key);
  final String uid;
  final String userName;
  final String imageUrl;

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final _controller = TextEditingController();

  late String message = '';

  final controller = TextEditingController();

  final currentUid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> seen() async {
    print("seen fn running");
    final snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.uid)
        .collection('people')
        .doc(currentUid)
        .collection('messages')
        .where('seenStatus', isEqualTo: "unseen")
        .get();
    final changeLength = snapshot.docs.length;
    for (int i = 0; i < changeLength; i++) {
      final docId = snapshot.docs[i].id;
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.uid)
          .collection('people')
          .doc(currentUid)
          .collection('messages')
          .doc(docId)
          .update({"seenStatus": 'seen'});
    }
  }

  bool isInit = false;

  @override
  void initState() {
    isInit = true;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    if (isInit == true) {
      seen();
    }
    isInit = false;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          actions: [
            DropdownButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
                items: const [
                  DropdownMenuItem(
                    child: Text("Clear chat"),
                    value: 1,
                  )
                ],
                onChanged: (value) async {
                  if (value == 1) {
                    QuerySnapshot snapshot = await FirebaseFirestore.instance
                        .collection('chats')
                        .doc(currentUid)
                        .collection('people')
                        .doc(widget.uid)
                        .collection('messages')
                        .get();
                    for (var doc in snapshot.docs) {
                      await doc.reference.delete();
                    }
                  }
                })
          ],
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.imageUrl),
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                widget.userName,
              ),
            ],
          ),
        ),
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(widget.imageUrl),
              ),
            ),
            width: double.infinity,
            height: mediaQuery.height,
            child: Column(
              children: [
                (Expanded(
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('chats')
                          .doc(currentUid)
                          .collection("people")
                          .doc(widget.uid)
                          .collection('messages')
                          .orderBy('time')
                          .snapshots(),
                      builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshots) {
                        if (snapshots.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshots.data!.docs.isNotEmpty) {
                          return ListView.builder(
                              padding: const EdgeInsets.all(10),
                              itemCount: snapshots.data!.docs.length,
                              itemBuilder: (ctx, index) {
                                print('message list running');
                                Map<String, dynamic> myData =
                                    snapshots.data!.docs[index].data()
                                        as Map<String, dynamic>;

                                return MessageBubble(
                                  seenStatus: myData['seenStatus'],
                                  time: myData['time'],
                                  message: myData['message'],
                                  currentUserId: currentUid,
                                  msgUid: myData['userId'],
                                  image: myData['imageUrl'] ?? "",
                                );
                              });
                        } else {
                          return SizedBox();
                        }
                      }),
                )),
                Container(
                  height: mediaQuery.height * .084,
                  padding: const EdgeInsets.only(
                      top: 7, bottom: 5, left: 5, right: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onChanged: (value) {
                            message = value;
                          },
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 32,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () async {
                                    XFile? file = await ImagePicker()
                                        .pickImage(source: ImageSource.camera);
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (ctx) => ImageSent(
                                                File(file!.path),
                                                currentUid,
                                                widget.uid)));
                                  },
                                ),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              focusColor: Colors.black,
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      width: 0, color: Colors.white),
                                  borderRadius: BorderRadius.circular(50)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50)),
                              hintText: 'Message'),
                        ),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          fixedSize:
                              MaterialStateProperty.all(const Size(50, 50)),
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.only(left: 5),
                          ),
                          shape: MaterialStateProperty.all(
                            const CircleBorder(),
                          ),
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor),
                        ),
                        onPressed: () {
                          if (message.isNotEmpty) {
                            _controller.clear();
                            MessageManager.submit(
                                message: message,
                                currentUid: currentUid,
                                widgetUid: widget.uid);
                          }
                        },
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )));
  }
}
