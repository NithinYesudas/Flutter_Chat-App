import 'package:chatapp/widgets/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Messages extends StatelessWidget {
  Messages(
      {Key? key,
      required this.uid,
      required this.userName,
      required this.imageUrl})
      : super(key: key);
  final String uid;
  final String userName;
  final String imageUrl;
  final _controller = TextEditingController();

  late String message = '';

  final controller = TextEditingController();
  final currentUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
              ),
              const SizedBox(
                width: 15,
              ),
              Text(userName),
            ],
          ),
        ),
        body: ListView(
          children: [
            Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(imageUrl),
                  ),
                ),
                height: MediaQuery.of(context).size.height * .82,
                width: double.infinity,
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(currentUid)
                        .collection(uid)
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
                            padding: EdgeInsets.all(10),
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
                        return Text('No text yet');
                      }
                    })),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 20, left: 10),
                  height: MediaQuery.of(context).size.height * .1,
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
                    backgroundColor:
                        MaterialStateProperty.all(Colors.redAccent),
                  ),
                  onPressed: () async {
                    controller.clear();
                    print('onpressed working..........');
                    if (message.isNotEmpty) {
                      try {
                        _controller.clear();

                        await FirebaseFirestore.instance
                            .collection('chats')
                            .doc(currentUid)
                            .collection(uid)
                            .add({
                          "message": message,
                          "time": Timestamp.now(),
                          'userId': currentUid,
                        });
                        await FirebaseFirestore.instance
                            .collection('chats')
                            .doc(uid)
                            .collection(currentUid)
                            .add({
                          "message": message,
                          "time": Timestamp.now(),
                          'userId': currentUid,
                        });
                      } catch (error) {
                        print(error);
                      }
                    }
                  },
                  child: const Icon(Icons.send),
                )
              ],
            )
          ],
        ));
  }
}
