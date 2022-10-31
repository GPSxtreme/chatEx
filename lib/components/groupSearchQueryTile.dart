import 'package:chat_room/databaseService.dart';
import 'package:chat_room/pages/chatScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupSearchQueryTile extends StatefulWidget {
  const GroupSearchQueryTile({Key? key,required this.groupId}) : super(key: key);
  final String groupId;
  @override
  State<GroupSearchQueryTile> createState() => _GroupSearchQueryTileState();
}

class _GroupSearchQueryTileState extends State<GroupSearchQueryTile> {
  late final grpDetails;
  String name = "";
  String by = "";
  String grpIcon = "";
  bool isJoined = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGroupDetails();
  }
  void getGroupDetails()async{
    final _fireStore = FirebaseFirestore.instance;
    final grpDetails = await _fireStore.collection("groups").doc(widget.groupId).get();
    bool getIsJoined = await DatabaseService.isUserAlreadyInGrp(widget.groupId);
    if(mounted){
      setState(() {
        name = grpDetails["name"];
        by = grpDetails["createdBy"];
        grpIcon = grpDetails["groupIcon"];
        isJoined = getIsJoined;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        padding:const EdgeInsets.symmetric(vertical: 10),
        child: GestureDetector(
          onTap: (){
            if(isJoined){
              Navigator.pushNamed(context, chatScreen.id,arguments: {"groupId":widget.groupId,"groupName":name,"createdBy":by});
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
            child: Row(
              children: [
                grpIcon != "" ?
                  CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(grpIcon)
                  ) :
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: CircularProgressIndicator(color: Colors.blue,strokeWidth: 15,),),
                const SizedBox(width: 20,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,style: GoogleFonts.poppins(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
                    const SizedBox(height: 5,),
                    Text("Created by: $by",style: GoogleFonts.poppins(color: Colors.white,fontSize: 12),),
                  ],
                ),
                const Spacer(),
                isJoined ?
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                        child: Text("Joined",style: GoogleFonts.poppins(color: Colors.white),),
                      ),
                    ):
                ElevatedButton(onPressed: (){
                    DatabaseService.addUserToGroup(widget.groupId);
                    setState(() {
                      isJoined = true;
                    });
                }, child: Text("join",style: GoogleFonts.poppins(color: Colors.white,fontWeight: FontWeight.bold),)),
                const SizedBox(width: 10,),
              ]
            ),
          ),
        )
    );
  }
}