import 'package:chat_room/services/authService.dart';
import 'package:chat_room/services/themeDataService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import '../components/groupUserTile.dart';
import '../consts.dart';
import '../services/databaseService.dart';

class GroupInfoScreen extends StatefulWidget {
  const GroupInfoScreen({Key? key}) : super(key: key);
  static String id = "groupInfo_screen";
  static bool isInEditMode = false;
  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final _fireStore = FirebaseFirestore.instance;
  Map dataPassed = {};
  String groupId = "";
  String imgPath = "";
  String groupName = "";
  bool isAdmin = false;
  String newGroupName = "";
  String groupAbout = "";
  String newGroupAbout = "";

  @override
  void initState() {
    super.initState();
    GroupInfoScreen.isInEditMode = false;
  }

  memberList(){
    return StreamBuilder(
        stream:_fireStore.collection("groups").doc(groupId).snapshots(),
        builder: (context, AsyncSnapshot snapshot){
          if(snapshot.hasData){
            if(snapshot.data["about"] != null){
                groupAbout = snapshot.data["about"];
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data["members"].length,
              itemBuilder: (context,index){
                return GroupUserTile(userId:snapshot.data["members"][index],groupId: groupId,);
              },
            );
          }
          else{
            return const CircularProgressIndicator(
              color: Colors.white,
            );
          }

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
      isAdmin = dataPassed["isAdmin"] ? true:false;
      //page functions
    popOfPage(){
      HelperFunctions.popOfPage(context);
    }
    popOutOfContext(){
      HelperFunctions.popOutOfContext(context);
    }
    superUserDelAllMsg(){
      DatabaseService.superUserDelAllMsg(context,groupId);
      popOfPage();
    }
    superDeleteGroup()async{
      try{
        popOutOfContext();
        popOfPage();
        await DatabaseService.superDeleteGroup(groupId,groupName);
      }catch(e){
        print("error deleting group:$e");
      }
      finally{
        AuthService.pushMainScreenRoutine(context);
      }
    }
    leaveGroup(){
      DatabaseService.leaveGroup(groupId);
      AuthService.pushMainScreenRoutine(context);
    }
    Future onRefresh()async{
      HelperFunctions.clearImageCache();
      setState(() {
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("About",style: GoogleFonts.poppins(),),
        backgroundColor: MainScreenTheme.mainScreenAppBarBg,
        elevation: 0,
        actions: !isAdmin ? null: [
          if(!GroupInfoScreen.isInEditMode)
          IconButton(
              tooltip: "Edit",
              onPressed: (){
            setState(() {
              newGroupAbout = "";
              newGroupName = "";
              GroupInfoScreen.isInEditMode = true;
            });
          }, icon: const Icon(Icons.edit,color: Colors.white,)
          ),
          if(GroupInfoScreen.isInEditMode) ...[
            IconButton(
                tooltip: "Go back",
                onPressed: (){
                  setState(() {
                    GroupInfoScreen.isInEditMode = false;
                  });
                }, icon: const Icon(Icons.undo,color: Colors.white,)
            )
          ]
        ],
      ),
      backgroundColor: MainScreenTheme.mainScreenBg,
      body: RefreshIndicator(
        color: MainScreenTheme.mainScreenBg,
        onRefresh: onRefresh,
        child : Stack(
          children: [
            ScrollConfiguration(
              behavior: const ScrollBehavior(),
              child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                color: MainScreenTheme.mainScreenBg,
                child: ListView(
                    children: [
                      StreamBuilder(
                          stream: _fireStore.collection("groups").doc(groupId).snapshots(),
                          builder: (context,AsyncSnapshot snapshot){
                            if(snapshot.hasData){
                                groupAbout = snapshot.data["about"];
                              try{
                                if(snapshot.data["newName"].toString().isNotEmpty){
                                  groupName = snapshot.data["newName"];
                                }
                              }catch(e){
                                print("no new group name:$e");
                              }
                            }
                              return Column(
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
                                          if(!GroupInfoScreen.isInEditMode)
                                            Text(groupName,style: GoogleFonts.poppins(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,),
                                          if(GroupInfoScreen.isInEditMode)
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 7),
                                              child: TextFormField(
                                                cursorColor: Colors.white,
                                                initialValue: groupName,
                                                // controller: userNameController,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                textAlign: TextAlign.center,
                                                keyboardType:
                                                TextInputType.emailAddress,
                                                onChanged: (value) {
                                                  newGroupName = value;
                                                },
                                                decoration:
                                                kMsgInputContainerDecoration.copyWith(
                                                    fillColor: Colors.white12,
                                                    prefixIcon: const Icon(
                                                      Icons.abc,
                                                      color: Colors.white,
                                                      size: 30,
                                                    ),
                                                    suffixIcon: IconButton(
                                                        tooltip: "Apply",
                                                        onPressed: ()async{
                                                      if(newGroupName.isEmpty){
                                                        newGroupName = groupName;
                                                      }
                                                      if(groupName != newGroupName){
                                                        setState(() {
                                                          groupName = newGroupName;
                                                        });
                                                        await DatabaseService.updateGroupDetails(groupId,"newName",groupName);
                                                        showSnackBar(context, "Group name has been changed to,\n$groupName", 2000,bgColor: Colors.indigo);
                                                      }else{
                                                        showSnackBar(context, "No changes made", 1300,bgColor: Colors.indigo);
                                                      }

                                                    }, icon: const Icon(Icons.check,color: Colors.white,size: 30,))
                                                ),
                                              ),
                                            ),
                                          const SizedBox(height: 20,),
                                          if(!GroupInfoScreen.isInEditMode)
                                            Text(groupAbout.isEmpty ? "Add group about to display here": groupAbout,maxLines: 3,style: GoogleFonts.poppins(fontWeight: FontWeight.w400,color: Colors.white),textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,),
                                          if(GroupInfoScreen.isInEditMode)
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 7),
                                              child: TextFormField(
                                                maxLines: 2,
                                                cursorColor: Colors.white,
                                                initialValue: groupAbout.isNotEmpty ? groupAbout:null,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                textAlign: TextAlign.center,
                                                keyboardType:
                                                TextInputType.emailAddress,
                                                onChanged: (value) {
                                                  newGroupAbout = value;
                                                },
                                                decoration:
                                                kMsgInputContainerDecoration.copyWith(
                                                  hintText: "",
                                                    fillColor: Colors.white12,
                                                    prefixIcon: const Icon(
                                                      Icons.info,
                                                      color: Colors.white,
                                                      size: 30,
                                                    ),
                                                    suffixIcon: IconButton(
                                                        tooltip: "Apply",
                                                        onPressed: ()async{
                                                      if(newGroupAbout.isEmpty){
                                                        newGroupAbout = groupAbout;
                                                      }
                                                      if(groupAbout != newGroupAbout){
                                                        setState(() {
                                                          groupAbout = newGroupAbout;
                                                        });
                                                        await DatabaseService.updateGroupDetails(groupId,"about",groupAbout);
                                                        showSnackBar(context, "Group about has been changed to,\n$groupAbout", 2000,bgColor: Colors.indigo);
                                                      }else{
                                                        showSnackBar(context, "No changes made", 1300,bgColor: Colors.indigo);

                                                      }
                                                    }, icon: const Icon(Icons.check,color: Colors.white,size: 30,))
                                                ),
                                              ),
                                            ),
                                          const SizedBox(height: 20,),
                                        ],
                                      )
                                  ),
                                  const SizedBox(height: 10,),
                                  Center(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width*0.95,
                                      margin:
                                      const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: Colors.white12),
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if (isAdmin) ...[
                                              IconButton(
                                                  tooltip: "Erase all messages",
                                                  onPressed: () {
                                                    showDialogBox(
                                                      context,
                                                      'DELETE ALL MESSAGES?',
                                                      "This process is permanent and cannot be undone",
                                                      Colors.red,
                                                      superUserDelAllMsg,
                                                      popOutOfContext,
                                                    );
                                                  },
                                                  icon: const Icon(
                                                    Icons.message,
                                                    color: Colors.red,
                                                    size: 25,
                                                  )),
                                              const SizedBox(width: 13,),
                                              IconButton(
                                                  tooltip: "Delete group",
                                                  onPressed: () {
                                                    showDialogBox(
                                                      context,
                                                      'DELETE GROUP?',
                                                      "This process is permanent and cannot be undone",
                                                      Colors.red,
                                                      superDeleteGroup,
                                                      popOutOfContext,
                                                    );
                                                  },
                                                  icon: const Icon(
                                                    Ionicons.trash_bin,
                                                    color: Colors.red,
                                                    size: 25,
                                                  )),
                                              const SizedBox(width: 13,),
                                            ],
                                            IconButton(
                                                tooltip: "Leave",
                                                onPressed: () {
                                                  if(!isAdmin){
                                                    showDialogBox(
                                                        context,
                                                        'LEAVE GROUP?',
                                                        "You can join the group again.",
                                                        Colors.red,
                                                        leaveGroup,
                                                        popOutOfContext);
                                                  }else{
                                                    showSnackBar(context, "Group creator cannot leave group without deleting it.", 3000,bgColor: Colors.indigo);
                                                  }
                                                },
                                                icon: const Icon(
                                                  Ionicons.log_out_outline,
                                                  color: Colors.red,
                                                  size: 25,
                                                )),
                                          ]),
                                    ),
                                  ),
                                  const SizedBox(height: 5,),
                                  Divider(
                                    thickness: 2,
                                    indent: MediaQuery.of(context).size.width * 0.030,
                                    endIndent:
                                    MediaQuery.of(context).size.width * 0.030,
                                    height: 18,
                                    color: Colors.white12,
                                  ),
                                  const SizedBox(height: 10,),
                                ],
                              );
                          }
                      ),
                      memberList(),
                    ],
                  ),
              ),
            ),
          ],
        )
      ),
    );
  }
}
