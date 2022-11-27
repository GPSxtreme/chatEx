import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_room/pages/profileCreate.dart';
import 'package:chat_room/services/authService.dart';
import 'package:chat_room/services/themeDataService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ionicons/ionicons.dart';
import '../components/roundedBtnT1.dart';
import 'package:chat_room/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class regScreen extends StatefulWidget {
  static String id = 'reg_screen';
  const regScreen({Key? key}) : super(key: key);
  @override
  State<regScreen> createState() => _regScreenState();
}

class _regScreenState extends State<regScreen> {
  String password = '';
  String rePassword = '';
  String email = '';
  final _auth = FirebaseAuth.instance;
  bool showLoader = false;
  bool isVerifyEmailSent = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: MainScreenTheme.mainScreenBg,
      body: ModalProgressHUD(
        opacity: 0.18,
        inAsyncCall: showLoader,
        child: Center(
            child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: [
                  SizedBox(
                    width: size.width * 0.09,
                  ),
                  const Icon(
                    Ionicons.chatbubble_ellipses_outline,
                    color: Colors.white,
                    size: 60,
                  ),
                  SizedBox(
                    width: size.width * 0.03,
                  ),
                  SizedBox(
                    width: size.width * 0.70,
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
                    const SizedBox(
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
                      onChanged: (value) {
                        email = value;
                      },
                      decoration: kTextFieldInputDecoration.copyWith(
                          hintText: "Enter your email",
                          labelText: "Email",
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.white,
                          )),
                    ),
                    const SizedBox(
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
                      onChanged: (value) {
                        password = value;
                      },
                      decoration: kTextFieldInputDecoration.copyWith(
                          hintText: "Enter your password",
                          labelText: "Password",
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.white,
                          )),
                    ),
                    const SizedBox(
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
                      onChanged: (value) {
                        rePassword = value;
                      },
                      decoration: kTextFieldInputDecoration.copyWith(
                          hintText: "Re-enter your password",
                          labelText: "Re-enter password",
                          labelStyle: const TextStyle(
                              fontSize: 15, color: Colors.white),
                          hintStyle: const TextStyle(
                              fontSize: 15, color: Colors.white)),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    if (isVerifyEmailSent) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Did not receive verification email? ",
                              style: TextStyle(color: Colors.white)),
                          TextButton(
                              onPressed: () {
                                AuthService.sendUserVerificationEmail();
                                showSnackBar(
                                    context,
                                    "Verification email sent(check spam folder if not in inbox)",
                                    3800,
                                    bgColor: Colors.indigo);
                              },
                              child: const Text(
                                "Click here",
                                style: TextStyle(color: Colors.blue),
                              )),
                        ],
                      ),
                      roundedBtn(
                          title: "Open mail 📧",
                          onPressed: () {
                            HelperFunctions.openGmail(context);
                          }),
                    ],
                    roundedBtn(
                      title: 'Register',
                      onPressed: () async {
                        if (_auth.currentUser != null) {
                          setState(() {
                            showLoader = true;
                          });
                          await _auth.currentUser!.reload();
                          final user = _auth.currentUser;
                          if (user != null) {
                            bool isVerified = user.emailVerified;
                            if (isVerified) {
                              setState(() {
                                showLoader = false;
                              });
                              Navigator.pushNamed(context, profileCreate.id);
                            } else if (!isVerified) {
                              setState(() {
                                showLoader = false;
                              });
                              showSnackBar(
                                  context, "Please verify your email!", 1800);
                            }
                          }
                        } else if (password.isNotEmpty &&
                            rePassword.isNotEmpty &&
                            email.isNotEmpty) {
                          if (password == rePassword &&
                              (password.length >= 6)) {
                            setState(() {
                              showLoader = true;
                            });
                            try {
                              await _auth.createUserWithEmailAndPassword(
                                  email: email, password: password);
                              final newUser = _auth.currentUser;
                              newUser!.sendEmailVerification().then((value) {
                                setState(() {
                                  showLoader = false;
                                  isVerifyEmailSent = true;
                                });
                              });
                              showSnackBar(
                                  context,
                                  "Please verify your account through the verification email sent.If not recieved please check spam folder of your email.",
                                  3800,
                                  bgColor: Colors.indigo);
                            } on FirebaseAuthException catch (e) {
                              setState(() {
                                showLoader = false;
                              });
                              showSnackBar(context, e.message.toString(), 2000);
                            }
                          } else {
                            showSnackBar(
                                context,
                                'Password should be longer than 6 characters',
                                2000);
                          }
                        } else {
                          showSnackBar(
                              context, 'Please fill in all fields!!', 2000);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
