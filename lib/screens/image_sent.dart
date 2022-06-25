import 'dart:io';

import 'package:chatapp/widgets/messages.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../helpers/message_manager.dart';

class ImageSent extends StatelessWidget {
  ImageSent(this.image, this.currentUid, this.messageUid, {Key? key})
      : super(key: key);
  final File image;
  final String currentUid;
  final String messageUid;
  final TextEditingController _controller = TextEditingController();
  String? message;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Container(
            height: mediaQuery.height * .85,
            width: double.infinity,
            decoration:
                BoxDecoration(image: DecorationImage(image: FileImage(image))),
          ),
          Container(
            height: mediaQuery.height * .084,
            padding:
                const EdgeInsets.only(top: 7, bottom: 5, left: 5, right: 5),
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
                        focusColor: Colors.black,
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(width: 0, color: Colors.white),
                            borderRadius: BorderRadius.circular(50)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50)),
                        hintText: 'Message'),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(const Size(50, 50)),
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

                    final imagerUrl = await MessageManager.imageSent(
                        image, currentUid, messageUid);

                    _controller.clear();
                    await MessageManager.submit(
                        message: message!,
                        currentUid: currentUid,
                        imageUrl: imagerUrl,
                        widgetUid: messageUid);

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
