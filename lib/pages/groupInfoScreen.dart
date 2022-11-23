import 'package:chat_room/services/themeDataService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import '../components/groupUserTile.dart';

class GroupInfoScreen extends StatefulWidget {
  const GroupInfoScreen({Key? key}) : super(key: key);
  static String id = "groupInfo_screen";
  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final _fireStore = FirebaseFirestore.instance;
  Map dataPassed = {};
  String groupId = "";
  String imgPath = "";
  String groupName = "";
  memberList(){
    return StreamBuilder(
        stream:_fireStore.collection("groups").doc(groupId).snapshots(),
        builder: (context, AsyncSnapshot snapshot){
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data["members"].length,
              itemBuilder: (context,index){
                return GroupUserTile(userId:snapshot.data["members"][index].toString().split("_")[0]);
              },
            );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    dataPassed = dataPassed.isNotEmpty
        ? dataPassed
        : ModalRoute.of(context)?.settings.arguments as Map;
      groupId = dataPassed["groupId"];
      imgPath = dataPassed["groupImgPath"];
      groupName = dataPassed["groupName"];
    return Scaffold(
      appBar: AppBar(
        title: Text("About",style: GoogleFonts.poppins(),),
        backgroundColor: MainScreenTheme.mainScreenAppBarBg,
        elevation: 0,
      ),
      backgroundColor: MainScreenTheme.mainScreenBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10,),
            Center(
              child: CircleAvatar(
                radius: 70,
                backgroundImage: FileImage(File(imgPath)),
              ),
            ),
            const SizedBox(height: 20,),
            Container(
              width: MediaQuery.of(context).size.width*0.95,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(15)
              ),
                child: Column(
                  children: [
                    const SizedBox(height: 10,),
                    Text(groupName,style: GoogleFonts.poppins(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,),
                    const SizedBox(height: 20,),
                    Text("Add group about to display here",maxLines: 3,style: GoogleFonts.poppins(fontWeight: FontWeight.w400,color: Colors.white),textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,),
                    const SizedBox(height: 20,),
                  ],
                )
            ),
            const SizedBox(height: 10,),
            Divider(
              thickness: 2,
              indent: MediaQuery.of(context).size.width * 0.055,
              endIndent:
              MediaQuery.of(context).size.width * 0.055,
              height: 18,
              color: Colors.white12,
            ),
            const SizedBox(height: 10,),
            memberList(),
          ],
        ),
      ),
    );
  }
}
