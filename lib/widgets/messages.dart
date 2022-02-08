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
            .collection(widget.uid)
            .add({
          "message": message,
          "time": Timestamp.now(),
          'userId': currentUid,
          'seenStatus': 'seen'
        });

        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.uid)
            .collection(currentUid)
            .doc(reference.id)
            .set({
          "message": message,
          "time": Timestamp.now(),
          'userId': currentUid,
          'seenStatus': 'unseen',
        });
      } catch (error) {
        print(error);
      }
    }
  }

  Future<void> seen() async {
    print("seen function calling");
    final snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(currentUid)
        .collection(widget.uid)
        .where('seenStatus', isEqualTo: "unseen")
        .get();
    final changeLength = snapshot.docs.length;
    for (int i = 0; i < changeLength; i++) {
      final docId = snapshot.docs[i].id;

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(currentUid)
          .collection(widget.uid)
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
    if (isInit = true) {
      seen();
    }
    isInit = false;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
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
        body: ListView(
          children: [
            Container(
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
                        .collection(widget.uid)
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
                              Map<String, dynamic> myData =
                                  snapshots.data!.docs[index].data()
                                      as Map<String, dynamic>;

                              return MessageBubble(
                                  message: myData['message'],
                                  currentUserId: currentUid,
                                  msgUid: myData['userId']);
                            });
                      } else {
                        return const Text('No text yet');
                      }
                    })),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 20, left: 10),
                  height: MediaQuery.of(context).size.height * .085,
                  width: MediaQuery.of(context).size.width * .8,
                  child: TextField(
                    controller: _controller,
                    onChanged: (value) {
                      message = value;
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(20)),
                        labelText: 'Message',
                        hintText: 'Message'),
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
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor),
                  ),
                  onPressed: submit,
                  child: const Icon(Icons.send),
                )
              ],
            )
          ],
        ));
  }
}
