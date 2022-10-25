import 'package:chat_room/pages/splashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat_room/pages/chatScreen.dart';
import 'package:chat_room/pages/loginScreen.dart';
import 'package:chat_room/pages/registrationScreen.dart';
import 'package:chat_room/pages/welcomeScreen.dart';
import 'package:chat_room/pages/profileCreate.dart';
import 'package:chat_room/pages/profileUser.dart';



Future<void> main() async{
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return   MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute:SplashScreen.id,
      routes: {
        SplashScreen.id:(context) =>SplashScreen(),
        welcomeScreen.id : (context) => welcomeScreen(),
        loginScreen.id: (context) => loginScreen(),
        regScreen.id:(context)=>regScreen(),
        profileCreate.id:(context)=>profileCreate(),
        chatScreen.id:(context)=>chatScreen(),
        profileUser.id:(context)=>profileUser(),
      },
    );
  }
}

