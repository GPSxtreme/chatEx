import 'package:chat_room/services/databaseService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import  'package:chat_room/consts.dart';
import 'package:chat_room/services/cloudStorageService.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:io';

import '../services/themeDataService.dart';

//Group create pop up
class GroupCreatePopUp extends StatefulWidget {
  const GroupCreatePopUp({Key? key, required this.userName, required this.userUid}) : super(key: key);
  final String userName;
  final String userUid;
  static dynamic image;
  @override
  State<GroupCreatePopUp> createState() => _GroupCreatePopUpState();
}

class _GroupCreatePopUpState extends State<GroupCreatePopUp> {
  bool isGrpCreateLoading = false;
  String groupName = "";
  final groupNameTextController = TextEditingController();
  String title = "Create a group";
  MainScreenTheme themeData = MainScreenTheme();

  @override
  void initState() {
    super.initState();
    themeData.addListener(themeListener);
  }

  @override
  void dispose() {
    super.dispose();
    themeData.removeListener(themeListener);
  }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }


  createGroup()async{
    setState(() {
      isGrpCreateLoading = true;
      title = "Creating...";
    });
    final grpId = await DatabaseService.addNewGroup(groupName,widget.userName,widget.userUid);
    final url = await CloudStorageService.addGrpImageGetLink("groupProfilePictures/${grpId}_$groupName.jpg",GroupCreatePopUp.image!.path);
    await DatabaseService.updateGroupDetails(grpId, "groupIcon", url);
    setState(() {
      isGrpCreateLoading = false;
      title = "Create a group";
      GroupCreatePopUp.image = null;
      groupName = "";
    });
    Navigator.of(context).pop();
    groupNameTextController.clear();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: MainScreenTheme.mainScreenBg == Colors.black ? HexColor("111111"):MainScreenTheme.mainScreenBg,
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(color: Colors.white),
      ),
      content: isGrpCreateLoading ? Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
         SpinKitWave(color: Colors.white,),
        ],
      ) :SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                const PickDpCircularAvatar(),
                const SizedBox(height: 20,),
                TextField(
                  keyboardType: TextInputType.text,
                  controller: groupNameTextController,
                  cursorColor: Colors.white,
                  onChanged: (val){
                    setState(() {
                      groupName = val;
                    });
                  },
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "group name",
                      hintStyle: GoogleFonts.poppins(color: Colors.white12),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(6),
                      )
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: (){
                if(!isGrpCreateLoading){
                  groupNameTextController.clear();
                  setState(() {
                    GroupCreatePopUp.image = null;
                    groupName = "";
                  });
                  Navigator.of(context).pop();
                }
                else{
                  showSnackBar(context, "Group creation under progress cannot cancel!", 1300);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black
              ),
              child: Text("Cancel",style: GoogleFonts.poppins(color: Colors.white),),
            ),
            const SizedBox(width: 20,),
            ElevatedButton(onPressed: ()async{
              if(groupName.isNotEmpty && GroupCreatePopUp.image != null){
                if(isGrpCreateLoading){
                  showSnackBar(context, "Group creation under progress!", 1300);
                }
                else{
                  createGroup();
                }
              }
              else{
                showSnackBar(context,"please provide all fields.",2000);
              }
            },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black
              ),
              child: Text("Create",style: GoogleFonts.poppins(color: Colors.white),),
            ),
          ],
        )
      ],
    );
  }
}
//Group Dp picker
class PickDpCircularAvatar extends StatefulWidget {
  const PickDpCircularAvatar({Key? key}) : super(key: key);

  @override
  State<PickDpCircularAvatar> createState() => _PickDpCircularAvatarState();
}

class _PickDpCircularAvatarState extends State<PickDpCircularAvatar> {
  void pickUploadImage() async{
    final imgPath = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80
    );
    setState(() {
      GroupCreatePopUp.image = imgPath;
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: pickUploadImage,
        child: GroupCreatePopUp.image == null ? CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Ionicons.camera_outline,size: 40,color: Colors.black,),
              Text("choose",style:GoogleFonts.poppins(color: Colors.black,fontSize:12),)
            ],
          ),
        ) : CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          backgroundImage: FileImage(File(GroupCreatePopUp.image.path)),
        )
    );
  }
}

