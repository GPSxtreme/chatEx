import 'package:chat_room/pages/groupInfoScreen.dart';
import 'package:chat_room/pages/profileUserShow.dart';
import 'package:chat_room/services/databaseService.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../services/themeDataService.dart';

class GroupUserTile extends StatefulWidget {
  const GroupUserTile({Key? key, required this.userId, required this.groupId}) : super(key: key);
  final String userId;
  final String groupId;
  @override
  State<GroupUserTile> createState() => _GroupUserTileState();
}

class _GroupUserTileState extends State<GroupUserTile> {
  String userUid = "";
  String userName = "";
  String userImgUrl = "";
  String userImgPath = "";
  final _fireStore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    userUid = widget.userId.split("_")[0];
    return StreamBuilder(
        stream: _fireStore.collection("users").doc(userUid).snapshots(),
        builder: (context,AsyncSnapshot snapshot){
          String userNameFetched = "";
          String userImgUrlFetched = "";
          if(snapshot.hasData){
              userNameFetched = snapshot.data["userName"];
              userImgUrlFetched = snapshot.data["profileImgLink"];
            return GestureDetector(
              onTap: () {
                //push to user details screen
                Navigator.pushReplacementNamed(
                    context, profileUserShow.id,
                    arguments: {
                      "senderUid": userUid,
                      "isMe": false
                    });
              },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                  visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
                  leading: (userImgUrlFetched.trim().isNotEmpty)
                      ? CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      backgroundImage: CachedNetworkImageProvider(userImgUrlFetched)
                  )
                      :CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,color: MainScreenTheme.mainScreenBg,size: 35,),
                  ),
                  title: Text(
                    userNameFetched,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  trailing: GroupInfoScreen.isInEditMode ? IconButton(
                    onPressed: ()async{
                      await DatabaseService.kickGroupUser(widget.groupId,widget.userId);
                    },
                    icon: const Icon(Icons.remove_circle_outline,color: Colors.red,),
                  ):null,
                ),
            );
          }else{
            return Container();
          }
        }
    );
  }
}
