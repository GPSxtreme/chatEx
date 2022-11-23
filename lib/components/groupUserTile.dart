import 'package:chat_room/consts.dart';
import 'package:chat_room/pages/chatScreen.dart';
import 'package:chat_room/pages/profileUserShow.dart';
import 'package:chat_room/services/cloudStorageService.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

class GroupUserTile extends StatefulWidget {
  const GroupUserTile({Key? key, required this.userId}) : super(key: key);
  final String userId;
  @override
  State<GroupUserTile> createState() => _GroupUserTileState();
}

class _GroupUserTileState extends State<GroupUserTile> {
  String userName = "";
  String userImgUrl = "";
  String userImgPath = "";
  final _fireStore = FirebaseFirestore.instance;
  @override
  initState() {
    // TODO: implement initState
    super.initState();
    // startRoutine();
  }
  startRoutine()async{
    await getUserDetails();
    await checkLocalGroupIcon();
  }
  Future getUserDetails() async {
    final _fireStore = FirebaseFirestore.instance;
    final userDetails = await _fireStore.collection("users").doc(widget.userId).get();
    if(userDetails.exists){
      userName = userDetails["userName"];
      userImgUrl = userDetails["profileImgLink"];
    }else{
      super.dispose();
    }
  }
  Future checkLocalGroupIcon()async{
    bool isDirExist = await HelperFunctions.checkIfLocalDirExistsInApp("groupUserProfilePictures");
    if(!isDirExist){
      await HelperFunctions.createLocalDirInApp("groupUserProfilePictures");
    }
    final appDocDir = await getExternalStorageDirectory();
    String imgName = "${widget.userId}_$userName.jpg";
    String filePath = "${appDocDir?.path}/groupUserProfilePictures/$imgName";
    final file = File(filePath);
    bool doesFileExist = await file.exists();
    if(!doesFileExist){
      String result = await CloudStorageService.downloadLocalImg(imgName,filePath,"userProfilePictures");
      if(result != "error"){
        if(mounted){
          setState(() {
            userImgPath = result;
          });
        }
      }
    }else{
      if(mounted){
        setState(() {
         userImgPath = filePath;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _fireStore.collection("users").doc(widget.userId).snapshots(),
        builder: (context,AsyncSnapshot snapshot){
          String userNameFetched = "";
          String userImgUrlFetched = "";
          ImageProvider<Object>? logo(){
            if(userImgPath != ""){
              return  FileImage(File(userImgPath));
            }else if (snapshot.data["profileImgLink"] != ""){
              return NetworkImage(snapshot.data["groupIcon"]);
            }
            return null;
          }
          if(snapshot.hasData){
              userNameFetched = snapshot.data["userName"];
              userImgUrlFetched = snapshot.data["profileImgLink"];
            return GestureDetector(
              onTap: () {
                //push to user details screen
                Navigator.pushReplacementNamed(
                    context, profileUserShow.id,
                    arguments: {
                      "senderUid": widget.userId,
                      "isMe": false
                    });
              },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                  visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
                  leading: (userImgUrlFetched.isNotEmpty)
                      ? CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      backgroundImage: CachedNetworkImageProvider(userImgUrlFetched)
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
                    userNameFetched,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  trailing: IconButton(
                    onPressed: (){},
                    icon: const Icon(Icons.message,color: Colors.white,),
                  ),
                ),
            );
          }else{
            return Container();
          }
        }
    );
  }
}
