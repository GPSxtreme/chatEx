import 'package:chat_room/pages/chatScreen.dart';
import 'package:chat_room/pages/mainScreen.dart';
import 'package:chat_room/pages/welcomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  static String id = "splash_screen";
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late bool isLoggedIn;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    coRoutine();
  }
  void coRoutine()async{
    bool isLoggedIn = FirebaseAuth.instance.currentUser != null ? true : false;
    final _fireStore = FirebaseFirestore.instance;
    final _auth = FirebaseAuth.instance;
    final loggedUser = _auth.currentUser;
    Future.delayed(const Duration(milliseconds: 1800) , () async {
      if(isLoggedIn){
        final userDetails = await _fireStore.collection("users").doc(_auth.currentUser?.uid).get();
        Navigator.popAndPushNamed(context, MainScreen.id,arguments: {"img":userDetails["profileImgLink"] ,"name":userDetails["userName"],"email":userDetails["email"],"phNo":userDetails["phoneNumber"],"uid":loggedUser?.uid});
      }else{
        Navigator.popAndPushNamed(context, welcomeScreen.id);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(child: SizedBox()),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Ionicons.chatbubble_ellipses_outline,color: Colors.white,size: 55,),
              const SizedBox(width: 10,),
              Text("ChatEx",style: GoogleFonts.poppins(fontWeight: FontWeight.bold,fontSize: 50,color: Colors.white),)
            ],
          ),
          const Expanded(child: SizedBox()),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Made with 💖 by Prudhvi",style: GoogleFonts.poppins(fontSize: 15,color: Colors.white),),
              const SizedBox(height: 50,),
            ],
          )
        ],
      ),
    );
  }
}
