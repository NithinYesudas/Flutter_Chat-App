import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  const ImageViewer(this.imageUrl, {Key? key}) : super(key: key);
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black26,
      ),
      body: GestureDetector(
        onVerticalDragDown: (d) {
          Navigator.of(context).pop();
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .8,
          child: Hero(tag: imageUrl, child: Image.network(imageUrl)),
        ),
      ),
    );
  }
}
