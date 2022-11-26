import 'package:chat_room/consts.dart';
import 'package:chat_room/pages/chatScreen.dart';
import 'package:chat_room/services/cloudStorageService.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class GroupTile extends StatefulWidget {
  const GroupTile({Key? key, required this.groupId}) : super(key: key);
  final String groupId;
  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  late final grpDetails;
  String name = "";
  String groupImgPath = "";
  final _fireStore = FirebaseFirestore.instance;
  @override
  initState() {
    // TODO: implement initState
    super.initState();
    startRoutine();
  }
  startRoutine()async{
    await getGroupDetails();
    await checkLocalGroupIcon();
  }
  Future getGroupDetails() async {
    final _fireStore = FirebaseFirestore.instance;
    final groupDetails = await _fireStore.collection("groups").doc(widget.groupId).get();
    if(groupDetails.exists){
      name = groupDetails["name"];
    }else{
      super.dispose();
    }
  }
  Future checkLocalGroupIcon()async{
    bool isDirExist = await HelperFunctions.checkIfLocalDirExistsInStorage("groupProfilePictures");
    if(!isDirExist){
     await HelperFunctions.createLocalDirInStorage("groupProfilePictures");
    }
    final appDocDir = await getExternalStorageDirectory();
    String imgName = "${widget.groupId}_$name.jpg";
    String filePath = "${appDocDir?.path}/groupProfilePictures/$imgName";
    final file = File(filePath);
    bool doesFileExist = await file.exists();
    if(!doesFileExist){
      String result = await CloudStorageService.downloadLocalImg(imgName,filePath,"groupProfilePictures");
      if(result != "error"){
        if(mounted){
          setState(() {
            groupImgPath = result;
          });
        }
      }
    }else{
      if(mounted){
        setState(() {
          groupImgPath = filePath;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _fireStore.collection("groups").doc(widget.groupId).snapshots(),
        builder: (context,AsyncSnapshot snapshot){
          ImageProvider<Object>? logo(){
          if(groupImgPath != ""){
            return  FileImage(File(groupImgPath));
          }else if (snapshot.data["groupIcon"] != ""){
            return NetworkImage(snapshot.data["groupIcon"]);
          }
          return null;
        }
        if(snapshot.hasData){
          String groupName = "";
          try{
              groupName = snapshot.data["newName"];
          }catch(e){
            groupName = snapshot.data["name"];
          }
          return Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, chatScreen.id, arguments: {
                    "groupId": widget.groupId,
                    "groupName": groupName,
                    "createdBy": snapshot.data["createdBy"],
                    "groupImgPath":groupImgPath
                  });
                },
                child: ListTile(
                  visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
                  leading: (groupImgPath != "" && snapshot.data["groupIcon"] != "")
                      ? CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      backgroundImage: logo()
                  )
                      : const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                      strokeWidth: 16,
                    ),
                  ),
                  title: Text(
                    groupName,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Created by: ${snapshot.data["createdBy"]}",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                  ),
                ),
              )
          );
        }else{
          return Container();
        }
      }
    );
  }
}
