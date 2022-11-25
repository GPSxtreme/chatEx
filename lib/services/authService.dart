import 'package:chat_room/consts.dart';
import 'package:chat_room/pages/mainScreen.dart';
import 'package:chat_room/services/themeDataService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AuthService {
  //is user logged in
  static bool isLoggedIn() {
    final _auth = FirebaseAuth.instance;
    return _auth.currentUser != null ? true : false;
  }

  //for login screen
  static void logInWithEmailPass(String email, String password) async {
    final _auth = FirebaseAuth.instance;
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  //for registration screen
  static void createUser(String email, String password) async {
    final _auth = FirebaseAuth.instance;
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  //to set prefs
  static void setPrefs() async {
    final _auth = FirebaseAuth.instance;
    final _fireStore = FirebaseFirestore.instance;
    final loggedUserUid = _auth.currentUser?.uid;
    final userDetails =
        await _fireStore.collection("users").doc(loggedUserUid).get();
  }

  //to logout
  static void logOut() {
    final _auth = FirebaseAuth.instance;
    _auth.signOut();
  }

  static Future<void> pushMainScreenRoutine(BuildContext context) async {
    try{
      final _auth = FirebaseAuth.instance;
      final _fireStore = FirebaseFirestore.instance;
      final loggedUser = _auth.currentUser;
      final userDetails =
      await _fireStore.collection("users").doc(_auth.currentUser?.uid).get();
      Navigator.popAndPushNamed(context, MainScreen.id, arguments: {
        "img": userDetails["profileImgLink"],
        "name": userDetails["userName"],
        "email": userDetails["email"],
        "phNo": userDetails["phoneNumber"],
        "uid": loggedUser?.uid
      });
    }catch(e){
      print("push main screen routine error: $e");
    }
  }

  static Future addFcmTokenToLoggedUser() async {
    final _auth = FirebaseAuth.instance;
    final _fireStore = FirebaseFirestore.instance;
    final loggedUser = _auth.currentUser;
    var doc = await _fireStore.collection('users').doc(loggedUser?.uid).get();
    final fcmToken = await FirebaseMessaging.instance.getToken();
    _fireStore
        .collection('users')
        .doc(loggedUser!.uid)
        .update({"fcmToken": fcmToken});
  }

  static Future<bool> checkIfUserDocExists() async {
    final _auth = FirebaseAuth.instance;
    final _fireStore = FirebaseFirestore.instance;
    await _auth.currentUser!.reload();
    final userDoc =
        await _fireStore.collection("users").doc(_auth.currentUser!.uid).get();
    return userDoc.exists;
  }

  static Future<bool> isUserEmailVerified() async {
    final _auth = FirebaseAuth.instance;
    await _auth.currentUser!.reload();
    bool _ver = _auth.currentUser!.emailVerified;
    return _ver;
  }

  static Future sendUserVerificationEmail() async {
    final _auth = FirebaseAuth.instance;
    await _auth.currentUser!.reload();
    final user = _auth.currentUser;
    await user!.sendEmailVerification();
  }
  static Future changeUserPassword()async{
    final _auth = FirebaseAuth.instance;
    final _fireStore = FirebaseFirestore.instance;
    final userDetails = await _fireStore.collection("users").doc(_auth.currentUser?.uid).get();
    final userEmail = userDetails["email"];
    await _auth.sendPasswordResetEmail(email: userEmail);
  }
  static Future changeUserEmail(BuildContext context , String email)async{
    final _auth = FirebaseAuth.instance;
    final _fireStore = FirebaseFirestore.instance;
    final user = _auth.currentUser;
    final userDetails = await _fireStore.collection("users").doc(_auth.currentUser?.uid).get();
    if(email != userDetails["email"]){
      try{
        await user?.updateEmail(email);
        await user?.reload();
        await user?.sendEmailVerification();
        await _fireStore.collection("users").doc(_auth.currentUser?.uid).update({
          "email":email
        });
        showSnackBar(context, "Change Email link sent to $email\nPlease check spam folder of your email.", 1800,bgColor: MainScreenTheme.mainScreenBg == Colors.black ? HexColor("222222"):Colors.indigo);
      }on FirebaseAuthException catch(e){
        showSnackBar(context, e.message.toString(), 2000);
      }
    }else{
      showSnackBar(context, "No changes made.", 1400,bgColor: MainScreenTheme.mainScreenBg == Colors.black ? HexColor("222222"):Colors.indigo);
    }
  }
}
