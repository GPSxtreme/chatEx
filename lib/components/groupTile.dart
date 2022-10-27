import 'package:chat_room/pages/chatScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupTile extends StatefulWidget {
  const GroupTile({Key? key,required this.groupId}) : super(key: key);
  final String groupId;
  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  late final grpDetails;
  String name = "";
  String by = "";
  String grpIcon = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGroupDetails();
  }
  void getGroupDetails()async{
    final _fireStore = FirebaseFirestore.instance;
    final grpDetails = await _fireStore.collection("groups").doc(widget.groupId).get();
    setState(() {
      name = grpDetails["name"];
      by = grpDetails["createdBy"];
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding:const EdgeInsets.symmetric(vertical: 20),
      child: GestureDetector(
        onTap: (){
          Navigator.pushNamed(context, chatScreen.id,arguments: {"groupId":widget.groupId,"groupName":name,"createdBy":by});
        },
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Text(name.substring(0,1).toUpperCase()),
          ),
          title:Text(name,style: GoogleFonts.poppins(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
          subtitle:Text("Admin: $by",style: GoogleFonts.poppins(color: Colors.white,fontSize: 15),),
        ),
      )
    );
  }
}