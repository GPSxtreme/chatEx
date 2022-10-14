import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_room/pages/chatScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ionicons/ionicons.dart';

import '../components/roundedBtnT1.dart';
import '../consts.dart';

class loginScreen extends StatefulWidget {
  loginScreen({Key? key}) : super(key: key);
  static String id = 'login_screen';
  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  Color colorPTF = Colors.white;
  String? password;
  String? email;

  void showSnackBar(String txt){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(txt,style:GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ))
            ],
          ),
          backgroundColor: Colors.red,
          shape: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          duration: const Duration(seconds: 2),
        ));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: HexColor("#090909"),
      body: Center(
          child:SingleChildScrollView(
            child: Column(
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
                    SizedBox(
                      width: size.width*0.70,
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
                  margin: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      TextField(
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value){email = value;},
                        decoration: kTextFieldInputDecoration.copyWith(hintText: "Enter your email",labelText: "Email:"),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        obscureText: true,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        onChanged: (value){ password = value; },
                        decoration: kTextFieldInputDecoration.copyWith(hintText: "Enter your password",labelText: "Password:"),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      roundedBtn(title: 'Login', onPressed: (){
                        if(password != null  && email != null){
                            Navigator.pushNamed(context, chatScreen.id);
                          }
                        else{
                          showSnackBar('Please fill in all fields!!');
                        }
                      },),
                    ],
                  ),
                ),

              ],
            ),
          )
      ),
    );
  }
}
