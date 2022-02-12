import 'package:chatapp/widgets/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<void> submit() async {
    controller.clear();

    if (message.isNotEmpty) {
      try {
        _controller.clear();

        var reference = await FirebaseFirestore.instance
            .collection('chats')
            .doc(currentUid)
            .collection('people')
            .doc(widget.uid)
            .collection('messages')
            .add({
          "message": message,
          "time": Timestamp.now(),
          'userId': currentUid,
          'seenStatus': 'unseen'
        });
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(currentUid)
            .collection('people')
            .doc(widget.uid)
            .set({
          "time": Timestamp.now(),
        });
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.uid)
            .collection('people')
            .doc(currentUid)
            .collection('messages')
            .doc(reference.id)
            .set({
          "message": message,
          "time": Timestamp.now(),
          'userId': currentUid,
          'seenStatus': 'unseen',
        });
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.uid)
            .collection('people')
            .doc(currentUid)
            .set({
          "time": Timestamp.now(),
        });
      } catch (error) {
        print(error);
      }
    }
  }

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
    if (isInit == true) {
      seen();
    }
    isInit = false;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
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
              Text(widget.userName),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(widget.imageUrl),
                    ),
                  ),
                  height: MediaQuery.of(context).size.height * .82,
                  width: double.infinity,
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
                                );
                              });
                        } else {
                          return const Text('No text yet');
                        }
                      })),
            ),
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(5),
              height: MediaQuery.of(context).size.height * .08,
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
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(50)),
                        labelText: 'Message',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(const Size(30, 30)),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.only(left: 5),
                      ),
                      shape: MaterialStateProperty.all(
                        const CircleBorder(),
                      ),
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColor),
                    ),
                    onPressed: submit,
                    child: const Icon(Icons.send),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
