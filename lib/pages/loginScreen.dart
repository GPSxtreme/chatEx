import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_room/pages/chatScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ionicons/ionicons.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../components/roundedBtnT1.dart';
import '../consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_size_text/auto_size_text.dart';

class loginScreen extends StatefulWidget {
  loginScreen({Key? key}) : super(key: key);
  static String id = 'login_screen';
  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  Color colorPTF = Colors.white;
  String password = '';
  String email = '';
  bool showLoader = false;
  final _auth = FirebaseAuth.instance;
  void showSnackBar(String txt,double fontSize){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SizedBox(
            width: MediaQuery.of(context).size.width*0.80,
            child: AutoSizeText(txt,
              style:GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
            ),
          ),
          backgroundColor: Colors.red,
          shape: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          duration: const Duration(seconds: 4),
        ));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: HexColor("#090909"),
      body: ModalProgressHUD(
        opacity: 0.18,
        inAsyncCall: showLoader,
        child: Center(
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
                        roundedBtn(title: 'Login', onPressed: () async {
                          if(password.isNotEmpty && email.isNotEmpty){
                              setState(() {
                                showLoader = true;
                              });
                              try{
                                final newUser = await _auth.signInWithEmailAndPassword(email: email, password: password);
                                if(newUser != null){
                                  setState(() {
                                    showLoader = false;
                                  });
                                  Navigator.pushNamed(context, chatScreen.id);
                                }
                              } on FirebaseAuthException catch  (e) {
                                setState(() {
                                  showLoader = false;
                                });
                                showSnackBar(e.message.toString(), 12);
                              }
                          }
                          else{
                            showSnackBar('Please fill in all fields!!',17);
                          }
                        },),
                      ],
                    ),
                  ),

                ],
              ),
            )
        ),
      ),
    );
  }
}
