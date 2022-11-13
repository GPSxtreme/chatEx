import 'package:chat_room/pages/profileUserShow.dart';
import 'package:chat_room/pages/welcomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../consts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MainScreenDrawer extends StatefulWidget {
  const MainScreenDrawer(
      {Key? key,
      required this.imageUrl,
      required this.userName,
      required this.userUid})
      : super(key: key);
  final String imageUrl;
  final String userName;
  final String userUid;
  @override
  State<MainScreenDrawer> createState() => _MainScreenDrawerState();
}

class _MainScreenDrawerState extends State<MainScreenDrawer> {
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  popOutOfContext() {
    Navigator.of(context).pop();
  }

  userLogOut() {
    _auth.signOut();
    Navigator.popAndPushNamed(context, welcomeScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        elevation: 10,
        width: MediaQuery.of(context).size.width * 0.8,
        backgroundColor: HexColor("#222222"),
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Column(
            children: [
              StreamBuilder(
                stream: _fireStore
                    .collection("users")
                    .doc(widget.userUid)
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    String userName = snapshot.data["userName"];
                    String userDpUrl = snapshot.data["profileImgLink"];
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(userDpUrl),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      child: Text(
                                        userName,
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            fontSize: 20),
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, profileUserShow.id,
                                          arguments: {
                                            "senderUid": widget.userUid,
                                            "isMe": true
                                          });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "View profile ",
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white),
                                            ),
                                            const Icon(
                                              Ionicons.eye_outline,
                                              color: Colors.white,
                                            )
                                          ],
                                        ),
                                      ),
                                    ))
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.white,
                    ));
                  }
                },
              ),
              const SizedBox(
                height: 10,
              ),
              ListTile(
                onTap: () {
                  popOutOfContext();
                  HelperFunctions.popUpGrpCreateDialog(
                      context, widget.userName, widget.userUid);
                },
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(
                  Icons.person_add_alt_1,
                  color: Colors.white,
                  size: 30,
                ),
                title: Text(
                  "Create group",
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w400),
                ),
              ),
              ListTile(
                onTap: () {},
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 30,
                ),
                title: Text(
                  "Settings",
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w400),
                ),
              ),
              const Expanded(child: SizedBox()),
              const Divider(
                color: Colors.white24,
                indent: 20,
                endIndent: 20,
                height: 2,
              ),
              ListTile(
                onTap: () {
                  showDialogBox(
                      context,
                      'Log Out?',
                      "You can login again by entering your credentials.",
                      Colors.red,
                      userLogOut,
                      popOutOfContext);
                },
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 30,
                ),
                title: Text(
                  "Logout",
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.red,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ));
  }
}
