import 'package:chat_room/pages/welcomeScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class chatScreen extends StatefulWidget {
  chatScreen({Key? key}) : super(key: key);
  static String id = 'chat_screen';
  @override
  State<chatScreen> createState() => _chatScreenState();
}

class _chatScreenState extends State<chatScreen> {
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  late User loggedUser;
  String msgTxt = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser (){
    try{
      final user =  _auth.currentUser;
      if(user!=null){
        loggedUser = user;
        print(loggedUser.email);
      }
    }
    catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: Text('Chat Room',style: GoogleFonts.poppins(),),
        centerTitle: true,
        backgroundColor: Colors.white24,
        elevation: 5,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 10,),
                  Expanded(
                      child: TextField(
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                        decoration: InputDecoration(
                          hintText: 'Type your message here...',
                          hintStyle: GoogleFonts.poppins(color: Colors.white,fontWeight: FontWeight.w400),
                        ),
                        onChanged: (value){
                          msgTxt = value;
                        }
                      )
                  ),
                  TextButton(
                      onPressed: (){
                          _fireStore.collection("messages").add({
                          'text':msgTxt,
                          'sender':loggedUser.email
                          });
                        },
                      child: Text('Send',style: GoogleFonts.righteous(),))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
