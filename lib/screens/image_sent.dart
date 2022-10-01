import 'dart:io';

import 'package:flutter/material.dart';

import '../helpers/message_manager.dart';

class ImageSent extends StatefulWidget {
  ImageSent(this.image, this.currentUid, this.messageUid, {Key? key})
      : super(key: key);
  final File image;
  final String currentUid;
  final String messageUid;

  @override
  State<ImageSent> createState() => _ImageSentState();
}

class _ImageSentState extends State<ImageSent> {
  final TextEditingController _controller = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    Expanded(
                      child: Container(
                        height: mediaQuery.height * .85,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: FileImage(widget.image))),
                      ),
                    ),
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
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  focusColor: Colors.black,
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 1, color: Colors.black26),
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
                            onPressed: () async {
                              print("image sent running");
                              setState(() {
                                _isLoading = true;
                              });

                              final imagerUrl = await MessageManager.imageSent(
                                  widget.image,
                                  widget.currentUid,
                                  widget.messageUid);

                              await MessageManager.submit(
                                  message: _controller.text,
                                  currentUid: widget.currentUid,
                                  imageUrl: imagerUrl,
                                  widgetUid: widget.messageUid);
                              _controller.clear();

                              Navigator.of(context).pop();
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
                )),
    );
  }
}
