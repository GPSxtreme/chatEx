// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:chat_room/pages/searchGroupsScreen.dart';
import 'package:chat_room/pages/splashScreen.dart';
import 'package:chat_room/pages/welcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_room/consts.dart';
import 'package:chat_room/components/groupTile.dart';
import 'package:chat_room/components/mainScreenDrawer.dart';
import 'package:chat_room/services/themeDataService.dart';

import '../services/authService.dart';

//global variables
dynamic loggedUser;

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static String id = "main_screen";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Map data = {};
  Stream? groups;
  late final userChats;
  late final userDetails;
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  MainScreenTheme themeData = MainScreenTheme();

  @override
  void initState() {
    super.initState();
    themeData.addListener(themeListener);
    getCurrentUser();
  }

  @override
  void dispose() {
    super.dispose();
    themeData.removeListener(themeListener);
  }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  //class functions
  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedUser = user;
      }
      userDetails =
          await _fireStore.collection('users').doc(loggedUser.uid).get();
      userChats = await _fireStore
          .collection('users')
          .doc(loggedUser.uid)
          .collection("chats")
          .get();
    } catch (e) {
      print(e);
    }
  }

  popOutOfContext() {
    Navigator.of(context).pop();
  }

  userLogOut() {
    _auth.signOut();
    Navigator.popAndPushNamed(context, welcomeScreen.id);
  }

  groupList() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder(
              stream: _fireStore.collection("users").doc(loggedUser.uid).snapshots(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data['joinedGroups'] != null &&
                      snapshot.data['joinedGroups'].length != 0) {
                    return ListView.builder(
                      shrinkWrap: false,
                      reverse: false,
                      itemCount: snapshot.data['joinedGroups'].length,
                      itemBuilder: (context, index) {
                        return GroupTile(
                            groupId: snapshot.data["joinedGroups"][index]);
                      },
                    );
                  } else {
                    return noGroupWidget();
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }
              }
              ),
        ),
        HelperFunctions.tradeMark()
      ],
    );
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: GestureDetector(
        onTap: () {
          HelperFunctions.popUpGrpCreateDialog(
              context, data["name"], loggedUser.uid);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle,
              color: Colors.white24,
              size: 75,
            ),
            Text(
              "You have not joined any groups.Create a group by tapping here or in the options drawer or search for already existing group using the search button.",
              style: GoogleFonts.poppins(color: Colors.white24),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
  Future<void> onRefresh()async{
    AuthService.pushMainScreenRoutine(context);
  }


  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty
        ? data
        : ModalRoute.of(context)?.settings.arguments as Map;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: MainScreenTheme.mainScreenBg,
        appBar: AppBar(
          backgroundColor: MainScreenTheme.mainScreenAppBarBg,
          elevation: 0,
          title: Text(
            "ChatEx",
            style: GoogleFonts.poppins(
                color: MainScreenTheme.mainScreenAppBarBgTitle,
                fontSize: 27,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  onRefresh();
                },
                icon: Icon(
                  Icons.refresh,
                  color: MainScreenTheme.mainScreenAppBarSearchIcon,
                )),
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, SearchGroupsScreen.id);
                },
                icon: Icon(
                  Icons.search,
                  color: MainScreenTheme.mainScreenAppBarSearchIcon,
                )),
          ],
        ),
        drawer: MainScreenDrawer(
            imageUrl: data["img"],
            userName: data["name"],
            userUid: loggedUser.uid),
        body: RefreshIndicator(
          onRefresh: onRefresh,
          color: MainScreenTheme.mainScreenBg,
          child: Stack(
            children: [
              groupList()
            ],
          ),
        ),
      ),
    );
  }
}

