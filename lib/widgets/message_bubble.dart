import 'package:flutter/material.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble(
      {Key? key,
      required this.message,
      required this.currentUserId,
      required this.msgUid})
      : super(key: key);
  final String currentUserId;
  final String msgUid;
  final String message;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool isCurrentUser() {
    if (widget.currentUserId == widget.msgUid) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('currentUid' + widget.currentUserId);
    print("msguid" + widget.msgUid);
    return Row(
      mainAxisAlignment:
          isCurrentUser() ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          alignment: widget.currentUserId == widget.msgUid
              ? Alignment.centerRight
              : Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: isCurrentUser() ? Colors.redAccent : Colors.white70,
              borderRadius: isCurrentUser()
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    )
                  : const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    )),
          child: Text(
            widget.message,
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
