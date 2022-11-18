import 'package:chat_room/consts.dart';
import 'package:chat_room/pages/welcomeScreen.dart';
import 'package:chat_room/services/themeDataService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chat_room/services/authService.dart';

class SplashScreen extends StatefulWidget {
  static String id = "splash_screen";
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn = false;
  final _fireStore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool isUserOffline = false;
  @override
  void initState() {
    super.initState();
    coRoutine();
  }

  void coRoutine() async {
    try {
      bool isOnline = await HelperFunctions.checkUserConnection();
      await ThemeDataService.setUpAppThemes();
      if (isOnline) {
        bool isLoggedIn = _auth.currentUser != null ? true : false;
        Future.delayed(const Duration(milliseconds: 1400), () async {
          if (isLoggedIn) {
            bool docExists = await AuthService.checkIfUserDocExists();
            if (docExists) {
              AuthService.pushMainScreenRoutine(context);
            } else {
              _auth.signOut();
              Navigator.popAndPushNamed(context, welcomeScreen.id);
            }
          } else {
            Navigator.popAndPushNamed(context, welcomeScreen.id);
          }
        });
      } else {
        setState(() {
          isUserOffline = true;
        });
      }
    } catch (e) {
      print("error: $e");
    }
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
              const Icon(
                Ionicons.chatbubble_ellipses_outline,
                color: Colors.white,
                size: 55,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "ChatEx",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 50,
                    color: Colors.white),
              )
            ],
          ),
          if (isUserOffline) ...[
            const SizedBox(
              height: 40,
            ),
            Icon(Icons.signal_cellular_connected_no_internet_0_bar,
                size: 150, color: HexColor("222222")),
            const SizedBox(
              height: 40,
            ),
            Text(
              "Uff you are offline.\nPlease try again when you get online 😔.",
              textAlign: TextAlign.center,
              maxLines: 2,
              style: GoogleFonts.poppins(
                fontSize: 17,
                color: Colors.white,
              ),
            ),
          ],
          const Expanded(child: SizedBox()),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Made with 💖 by Prudhvi",
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),
              ),
              const SizedBox(
                height: 50,
              ),
            ],
          )
        ],
      ),
    );
  }
}
