import 'package:flutter/material.dart';
import 'package:chat_room/pages/chatScreen.dart';
import 'package:chat_room/pages/loginScreen.dart';
import 'package:chat_room/pages/registrationScreen.dart';
import 'package:chat_room/pages/welcomeScreen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:chat_room/pages/profile.dart';

void main()=>{runApp(
    ResponsiveSizer(
      builder: ((context, orientation, deviceType) {
        return   MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: welcomeScreen.id,
          routes: {
            welcomeScreen.id : (context) => welcomeScreen(),
            loginScreen.id: (context) => loginScreen(),
            regScreen.id:(context)=>regScreen(),
            profile.id:(context)=>const profile(),
            chatScreen.id:(context)=>chatScreen(),
          },
        );
      }),
    )
  )
};