import 'dart:io';
import 'package:chatapp/helpers/message_manager.dart';
import 'package:chatapp/screens/image_sent.dart';
import 'package:chatapp/widgets/message_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
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

  bool isInit = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    Hive.box("messages").close();
    super.dispose();
  }

  bool _isLoading = false;
  bool isMsgSelected = false;
  String? msgIds;
  final ValueNotifier<bool> _notifier = ValueNotifier(false);
  String? msgOwner;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          actions: [
            ValueListenableBuilder(
                valueListenable: _notifier,
                builder: (ctx, bool val, child) {
                  return val
                      ? IconButton(
                          onPressed: () {
                            MessageManager.delete(
                                currentUid, widget.uid, msgIds!, msgOwner!);
                            _notifier.value = false;
                          },
                          icon: const Icon(Icons.delete_outline_outlined))
                      : DropdownButton(
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
                              QuerySnapshot snapshot = await FirebaseFirestore
                                  .instance
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
                          });
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
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
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
                        child: MessageList(
                      currentUid: currentUid,
                      msgUid: widget.uid,
                      msgSelected: (bool value, msgId, msgOwn) {
                        _notifier.value = value;
                        msgOwner = msgOwn;
                        msgIds = msgId;
                      },
                    ))),
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
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        XFile? file = await ImagePicker()
                                            .pickImage(
                                                source: ImageSource.camera,
                                                imageQuality: 75);
                                        if (file?.path != null) {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (ctx) => ImageSent(
                                                      File(file!.path),
                                                      currentUid,
                                                      widget.uid)));
                                        }

                                        setState(() {
                                          _isLoading = false;
                                        });
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
