import 'dart:io';

import 'package:chatapp/widgets/image_viewer.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble(
      {Key? key,
      required this.time,
      required this.image,
      required this.seenStatus,
      required this.message,
      required this.currentUserId,
      required this.msgSelected,
      required this.isSelected,
      required this.msgUid})
      : super(key: key);
  final String currentUserId;
  final String msgUid;
  final String message;
  final String seenStatus;
  final dynamic time;
  final String image;
  final bool isSelected;
  final Function(bool val, String? msgOwn) msgSelected;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool isCurrentUser() {
    return widget.currentUserId == widget.msgUid;
  }

  Color color = Colors.white.withOpacity(0);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return ColoredBox(
      color: widget.isSelected
          ? Colors.blue.withOpacity(.4)
          : Colors.white.withOpacity(0),
      child: Row(
        mainAxisAlignment:
            isCurrentUser() ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              widget.msgSelected(false, widget.msgUid);
            },
            onLongPress: () {
              widget.msgSelected(true, widget.msgUid);
            },
            child: Container(
              alignment: widget.currentUserId == widget.msgUid
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: isCurrentUser()
                      ? Theme.of(context).primaryColor
                      : Colors.white70,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  widget.image.isNotEmpty
                      ? InkWell(
                          child: SizedBox(
                            height: mediaQuery.height * .4,
                            width: mediaQuery.width * .6,
                            child: Hero(
                              tag: widget.image,
                              child: Image.network(
                                widget.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => ImageViewer(widget.image)));
                          },
                        )
                      : const SizedBox(
                          height: 0,
                        ),
                  widget.message.isNotEmpty
                      ? Text(
                          widget.message,
                          style: TextStyle(
                              fontSize: 20,
                              color: isCurrentUser()
                                  ? Colors.white
                                  : Colors.black),
                        )
                      : const SizedBox(
                          height: 0,
                        ),
                  widget.currentUserId != widget.msgUid
                      ? const SizedBox()
                      : Icon(
                          Icons.done_all_outlined,
                          color: widget.seenStatus == 'seen'
                              ? Colors.blue
                              : Colors.grey,
                        )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
