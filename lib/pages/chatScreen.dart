import 'package:chat_room/pages/welcomeScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class chatScreen extends StatefulWidget {
  chatScreen({Key? key}) : super(key: key);
  static String id = 'chat_screen';
  @override
  State<chatScreen> createState() => _chatScreenState();
}

class _chatScreenState extends State<chatScreen> {
  final _auth = FirebaseAuth.instance;
  late User loggedUser;

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
      body: Center(
        child: TextButton(
          onPressed: (){
            Navigator.pushNamed(context, welcomeScreen.id);
          },
          child: const Text('welcomeScreen',style: TextStyle(fontSize: 30),),
        ),
      ),
    );
  }
}
