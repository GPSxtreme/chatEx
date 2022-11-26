import 'package:chat_room/pages/profileUserShow.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
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
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _fireStore.collection("users").doc(widget.userId).snapshots(),
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
                  //Intended for personal chats.I don't have that much time 🥲
                  // trailing: IconButton(
                  //   onPressed: (){},
                  //   icon: const Icon(Icons.message,color: Colors.white,),
                  // ),
                ),
            );
          }else{
            return Container();
          }
        }
    );
  }
}
