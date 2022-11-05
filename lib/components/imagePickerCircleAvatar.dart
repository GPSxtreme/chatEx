import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:ionicons/ionicons.dart';

class ImagePickerCircleAvatar extends StatefulWidget {
  const ImagePickerCircleAvatar({Key? key, required this.imageUrl}) : super(key: key);
  static dynamic image;
  final String imageUrl;
  @override
  State<ImagePickerCircleAvatar> createState() => _ImagePickerCircleAvatar();
}

class  _ImagePickerCircleAvatar extends State<ImagePickerCircleAvatar> {
  Map data = {};
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    ImagePickerCircleAvatar.image = null;
  }
  void pickUploadImage() async{
    final imgPath = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50
    );
    setState(() {
      ImagePickerCircleAvatar.image = imgPath;
    });
  }
  @override
  Widget build(BuildContext context) {
    ImageProvider img ;
    if(ImagePickerCircleAvatar.image == null){
      img = NetworkImage(widget.imageUrl);
    }else{
      img = FileImage(File(ImagePickerCircleAvatar.image.path));
    }
    return GestureDetector(
        onTap: pickUploadImage,
        child:CircleAvatar(
          radius: 90,
          backgroundColor: Colors.white,
          backgroundImage: img,
          child:  Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(90),
              color: Colors.white.withOpacity(0.4)
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Ionicons.camera_outline,size: 60,color: Colors.black,),
                  Text("Edit",style:GoogleFonts.poppins(color: Colors.black,fontSize:18),)
                ],
              ),
            ),
          ),
        )
    );
  }
}