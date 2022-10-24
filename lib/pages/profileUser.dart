import 'package:chat_room/pages/chatScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class profileUser extends StatefulWidget {
  static String id = 'profileUser_screen';
  const profileUser({Key? key}) : super(key: key);

  @override
  State<profileUser> createState() => _profileUserState();
}

class _profileUserState extends State<profileUser> {
  Map data = {};
  final _fireStore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty? data: ModalRoute.of(context)?.settings.arguments as Map;
    return WillPopScope(
      onWillPop: ()async=>false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white24,
          title: Text("User Profile",style: GoogleFonts.poppins(color: Colors.white),),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: (){
              Navigator.of(context).pushNamed(chatScreen.id);
            },
          ),

        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder<DocumentSnapshot>(
                future: _fireStore.collection('users').doc(data['senderUid']).get(),
                  builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot> snapshot){
                    if (snapshot.hasError) {
                      return Text("Something went wrong");
                    }

                    if (snapshot.hasData && !snapshot.data!.exists) {
                      return Text("Document does not exist");
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(data['profileImgLink']),
                          ),
                          const SizedBox(height: 30,),
                          Text("Email:${data["email"]}",style:const TextStyle(color: Colors.white,fontSize: 20)),
                          Text("User name:${data["UserName"]}",style:const TextStyle(color: Colors.white,fontSize: 20)),
                          Text("Phone number:${data["PhoneNumber"]}",style:const TextStyle(color: Colors.white,fontSize: 20)),
                          Text("About:${data["about"]}",style:const TextStyle(color: Colors.white,fontSize: 20)),
                        ],
                      );
                    }
                    return Text("loading",style: TextStyle(color: Colors.white),);
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
