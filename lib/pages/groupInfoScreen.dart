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
  bool isInEditMode = false;
  String newGroupName = "";
  memberList(){
    return StreamBuilder(
        stream:_fireStore.collection("groups").doc(groupId).snapshots(),
        builder: (context, AsyncSnapshot snapshot){
          if(snapshot.hasData){
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data["members"].length,
              itemBuilder: (context,index){
                return GroupUserTile(userId:snapshot.data["members"][index].toString().split("_")[0]);
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
          if(!isInEditMode)
          IconButton(
              onPressed: (){
            setState(() {
              isInEditMode = true;
            });
          }, icon: const Icon(Icons.edit,color: Colors.white,)
          ),
          if(isInEditMode) ...[
            IconButton(
                onPressed: (){
                  setState(() {
                    isInEditMode = false;
                  });
                }, icon: const Icon(Icons.undo,color: Colors.white,)
            ),
            IconButton(
                onPressed: (){
                  //update settings
                }, icon: const Icon(Icons.check,color: Colors.white,)
            ),
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
                      Column(
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
                                  if(!isInEditMode)
                                  Text(groupName,style: GoogleFonts.poppins(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,),
                                  if(isInEditMode)
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
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                            suffixIcon: IconButton(onPressed: ()async{
                                              if(newGroupName.isEmpty){
                                                newGroupName = groupName;
                                              }
                                              setState(() {
                                                groupName = newGroupName;
                                              });
                                              await DatabaseService.updateGroupDetails(groupId,"newName",groupName);
                                              setState(() {
                                                isInEditMode = false;
                                              });
                                            }, icon: const Icon(Icons.check,color: Colors.white,size: 30,))
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 20,),
                                  if(!isInEditMode)
                                  Text("Add group about to display here",maxLines: 3,style: GoogleFonts.poppins(fontWeight: FontWeight.w400,color: Colors.white),textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,),
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
                                      TextButton(
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
                                          child: const Icon(
                                            Icons.message,
                                            color: Colors.red,
                                            size: 25,
                                          )),
                                      TextButton(
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
                                          child: const Icon(
                                            Ionicons.trash_bin,
                                            color: Colors.red,
                                            size: 25,
                                          )),
                                    ],
                                    TextButton(
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
                                        child: const Icon(
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
