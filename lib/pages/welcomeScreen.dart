import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat_room/pages/chatScreen.dart';
import 'package:chat_room/pages/loginScreen.dart';
import 'package:chat_room/pages/registrationScreen.dart';
import 'package:chat_room/pages/welcomeScreen.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sizer/sizer.dart';
import 'package:chat_room/consts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../components/roundedBtnT1.dart';
import 'package:chat_room/main.dart';
class welcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';
  welcomeScreen({Key? key}) : super(key: key);

  @override
  State<welcomeScreen> createState() => _welcomeScreenState();
}

class _welcomeScreenState extends State<welcomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Firebase.initializeApp();
  }

  @override

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: HexColor("#090909"),
      body: Center(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            Row(
              children: [
                SizedBox(width: size.width*0.09,),
                const Icon(
                  Ionicons.chatbubble_ellipses_outline,
                  color: Colors.white,
                  size: 60,
                ),
                SizedBox(width: size.width*0.03,),
                Flexible(
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'ChatEx',
                        textStyle: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                        speed: const Duration(milliseconds: 300),
                      ),
                    ],
                    pause: const Duration(milliseconds: 4000),
                    repeatForever: true,
                  ),
                )
              ],
            ),
              Container(
                height: 50,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  roundedBtn(title: 'Register', onPressed: (){
                    Navigator.pushNamed(context, regScreen.id);
                  },),
                  roundedBtn(title: 'Login', onPressed: (){
                    Navigator.pushNamed(context, loginScreen.id);
                  },),
                ],
              ),
            ],
          )
      ),
    );
  }
}

