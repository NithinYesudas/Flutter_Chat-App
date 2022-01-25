import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageBubble extends StatefulWidget {
  MessageBubble(this.message, this.uid,this.imageUrl, this.myKey, {Key? key})
      : super(key: myKey);

  final String message;
  final String imageUrl;
  final String uid;
  final Key myKey;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final firebase = FirebaseFirestore.instance.collection('users');

  dynamic data;

  bool isLoading = true;

  void fetch() async {
    data = await firebase
        .doc(widget.uid)
        .get()
        .then((value) => value.data()!['username']);
    setState(() {});
  }

  @override
  void initState() {
    fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;
    final mediaquery = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: user!.uid == widget.uid
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Container(
            constraints: BoxConstraints(maxWidth: mediaquery.width * .7),
            padding: EdgeInsets.symmetric(
                horizontal: mediaquery.width * .05, vertical: 10),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: widget.uid == user.uid
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(15))
                    : const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(10)),
                color: widget.uid == user.uid
                    ? Colors.redAccent
                    : Colors.grey[300]),
            child: Column(
              crossAxisAlignment: widget.uid == user.uid
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: mediaquery.width*.25,
                  height: mediaquery.height*.03,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(radius: 15,backgroundImage: NetworkImage(widget.imageUrl),),
                      Text(
                        data.toString(),
                        style: TextStyle(
                            color:
                                widget.uid == user.uid ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 20.5),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: mediaquery.height*.01,),
                Text(
                  widget.message,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color:
                          widget.uid == user.uid ? Colors.white : Colors.black,
                      fontSize: 18),
                ),
              ],
            )),
      ],
    );
  }
}
