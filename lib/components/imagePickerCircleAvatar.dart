import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:ionicons/ionicons.dart';

class ImagePickerCircleAvatar extends StatefulWidget {
  const ImagePickerCircleAvatar({Key? key, required this.userDpPath})
      : super(key: key);
  static dynamic image;
  final String userDpPath;
  @override
  State<ImagePickerCircleAvatar> createState() => _ImagePickerCircleAvatar();
}

class _ImagePickerCircleAvatar extends State<ImagePickerCircleAvatar> {

  void pickUploadImage() async {
    final imgPath = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    setState(() {
      ImagePickerCircleAvatar.image = imgPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: pickUploadImage,
        child: CircleAvatar(
          radius: 90,
          backgroundColor: Colors.white12,
          backgroundImage: ImagePickerCircleAvatar.image == null
              ? FileImage(File(widget.userDpPath))
              : FileImage(File(ImagePickerCircleAvatar.image.path))
                  as ImageProvider,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(90),
                color: Colors.white.withOpacity(0.4)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Ionicons.camera_outline,
                    size: 60,
                    color: Colors.black,
                  ),
                  Text(
                    "Edit",
                    style:
                        GoogleFonts.poppins(color: Colors.black, fontSize: 18),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
