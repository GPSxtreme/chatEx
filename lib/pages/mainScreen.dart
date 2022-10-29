import 'package:chat_room/pages/profileUserShow.dart';
import 'package:chat_room/pages/welcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import  'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import  'package:chat_room/consts.dart';
import 'package:chat_room/components/groupTile.dart';
import 'package:chat_room/components/groupCreatePopUp.dart';
//global variables
dynamic loggedUser;

class MainScreen extends StatefulWidget {
  static String id = "main_screen";
  static dynamic image;
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Map data = {};
  final _fireStore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late final userDetails;
  late final userChats;
  Stream? groups;

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    getCurrentUser();
  }

  void getCurrentUser ()async {
    try{
      final user =  _auth.currentUser;
      if(user!=null){
        loggedUser = user;
      }
      userDetails = await _fireStore.collection('users').doc(loggedUser.uid).get();
      userChats = await _fireStore.collection('users').doc(loggedUser.uid).collection("chats").get();
    }
    catch(e){
      print(e);
    }
  }
  popOutOfContext(){
    Navigator.of(context).pop();
  }
  userLogOut(){
    _auth.signOut();
    Navigator.popAndPushNamed(context, welcomeScreen.id);
  }
  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty? data: ModalRoute.of(context)?.settings.arguments as Map;
    return WillPopScope(
      onWillPop: ()async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black12,
          elevation: 0,
          title: Text("ChatEx",style: GoogleFonts.poppins(color: Colors.white,fontSize: 27,fontWeight: FontWeight.bold),),
          centerTitle: true,
          actions: [
            IconButton(onPressed: (){},
                icon: const Icon(Icons.search,color: Colors.white,)
            )
          ],
        ),
        drawer: Drawer(
          elevation: 10,
          width: MediaQuery.of(context).size.width*0.8,
          backgroundColor: Colors.black,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 50),
            children: [
              CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(data['img'],),
              ),
              const SizedBox(height: 20,),
              Text(data["name"],textAlign: TextAlign.center,style: GoogleFonts.poppins(fontWeight: FontWeight.w700,color: Colors.white,fontSize: 24),),
              const SizedBox(height: 20,),
              const Divider(
                color: Colors.white,
                indent: 20,
                endIndent: 20,
                height: 2,
              ),
              ListTile(
                onTap: (){},
                contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                leading: const Icon(Icons.people,color: Colors.white,size: 30,),
                title: Text("Groups",style: GoogleFonts.poppins(fontSize: 20,color: Colors.white,fontWeight: FontWeight.w400),),
              ),
              ListTile(
                onTap: (){
                  popOutOfContext();
                  popUpDialog(context);
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                leading: const Icon(Icons.person_add_alt_1,color: Colors.white,size: 30,),
                title: Text("Create group",style: GoogleFonts.poppins(fontSize: 20,color: Colors.white,fontWeight: FontWeight.w400),),
              ),
              ListTile(
                onTap: (){
                  Navigator.pushNamed(context, profileUserShow.id,arguments:{"senderUid":data['uid']});
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                leading: const Icon(Icons.person,color: Colors.white,size: 30,),
                title: Text("My profile",style: GoogleFonts.poppins(fontSize: 20,color: Colors.white,fontWeight: FontWeight.w400),),
              ),
              ListTile(
                onTap: (){
                  showDialogBox(
                      context,
                      'Log Out?',
                      "You can login again by entering your credentials.",
                      Colors.red,
                      userLogOut,
                      popOutOfContext
                  );
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                leading: const Icon(Icons.logout,color: Colors.red,size: 30,),
                title: Text("Logout",style: GoogleFonts.poppins(fontSize: 20,color: Colors.red,fontWeight: FontWeight.w400),),
              ),
            ],
          ),
        ),
        body : groupList(),
      ),
    );
  }

  popUpDialog(BuildContext context){
    showDialog(
      barrierColor: Colors.black54,
      barrierDismissible: false,
      context: context,
      builder: (context){
        return GroupCreatePopUp(userName: data["name"],userUid: loggedUser.uid);
      }
    );
  }
  groupList(){
    return StreamBuilder(
        stream:  _fireStore.collection("users").doc(loggedUser.uid).snapshots(),
        builder:(context,AsyncSnapshot snapshot){
          if (snapshot.hasData) {
            if(snapshot.data['joinedGroups'] != null && snapshot.data['joinedGroups'].length != 0){
              return ListView.builder(
                reverse: false,
                itemCount: snapshot.data['joinedGroups'].length,
                itemBuilder: (context,index){
                  if(index == snapshot.data['joinedGroups'].length){
                  }
                  return GroupTile(groupId: snapshot.data["joinedGroups"][index]);
                },
              );
            }
            else{
              return noGroupWidget();
            }
          }
          else {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }
        }
    );
  }
  noGroupWidget(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: GestureDetector(
        onTap: (){
          popUpDialog(context);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle,color: Colors.white24,size: 75,),
            Text("You have not joined any groups.Create a group by tapping here or in the options drawer or search for already existing group using the search button.",style:GoogleFonts.poppins(color: Colors.white24),textAlign: TextAlign.center,)
          ],
        ),
      ),
    );
  }
}
