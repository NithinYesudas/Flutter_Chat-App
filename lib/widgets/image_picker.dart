import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {

  final Function imageGetter;
  UserImagePicker(this.imageGetter, {Key? key}) : super(key: key);

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  XFile? image;

  ImageProvider get myImage {
    if (image == null) {
      return const NetworkImage(
          'https://miro.medium.com/max/1080/1*jWx9suY2k3Ifq4B8A_vz9g.jpeg');
    } else {
      return FileImage(File(image!.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 40,
      backgroundImage: myImage,
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          Positioned(
            top: 35,
            left: 30,
            child: ElevatedButton(
              onPressed: () async {
                final imagePicker = ImagePicker();
                image = await imagePicker.pickImage(source: ImageSource.gallery,imageQuality: 50);
                widget.imageGetter(File(image!.path));
                setState(() {});
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green[700]),
                  shape: MaterialStateProperty.all(const CircleBorder())),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
