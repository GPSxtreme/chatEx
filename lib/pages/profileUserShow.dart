import 'package:chat_room/pages/chatScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';


class profileUserShow extends StatefulWidget {
  static String id = 'profileUser_screen';
  const profileUserShow({Key? key}) : super(key: key);

  @override
  State<profileUserShow> createState() => _profileUserShowState();
}

class _profileUserShowState extends State<profileUserShow> {
  Map data = {};
  final _fireStore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty? data: ModalRoute.of(context)?.settings.arguments as Map;
    return WillPopScope(
      onWillPop: ()async=>false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white24,
          title: Text("User Profile",style: GoogleFonts.poppins(color: Colors.white),),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: (){
              Navigator.of(context).pop();
            },
          ),

        ),
        backgroundColor: Colors.black,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder<DocumentSnapshot>(
                  future: _fireStore.collection('users').doc(data['senderUid']).get(),
                    builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot> snapshot){
                      if (snapshot.hasError) {
                        return Text("Something went wrong");
                      }

                      if (snapshot.hasData && !snapshot.data!.exists) {
                        return Text("Document does not exist");
                      }

                      if (snapshot.connectionState == ConnectionState.done) {
                        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                        return Column(
                          children: [
                            const SizedBox(height:30),
                            CircleAvatar(
                              radius: 90,
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(data['profileImgLink'],),
                            ),
                            SizedBox(height: 20,),
                            Divider(
                              thickness: 2,
                              indent: MediaQuery.of(context).size.width*0.1,
                              endIndent: MediaQuery.of(context).size.width*0.1,
                              height: 20,
                              color: HexColor("#999999"),
                            ),
                            const SizedBox(height: 30,),
                            Container(
                              width: MediaQuery.of(context).size.width*0.8,
                              decoration: BoxDecoration(
                                  color: Colors.white24,
                                borderRadius: BorderRadius.circular(8)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 30),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white24,
                                              borderRadius: BorderRadius.circular(8)
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text("Name",style:GoogleFonts.poppins(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                        const SizedBox(width: 10,),
                                        Text(data["UserName"],style:GoogleFonts.poppins(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w300)),
                                      ],
                                    ),
                                    const SizedBox(height: 20,),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white24,
                                              borderRadius: BorderRadius.circular(8)
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text("Email",style:GoogleFonts.poppins(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                        const SizedBox(width: 15,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                                onTap:()async{
                                                  final email = "mailto:${data['email']}";
                                                  try {
                                                    await launchUrlString(email);
                                                  } catch (_e) { print(_e);}
                                                },
                                                child: Row(
                                                  children: [
                                                    Text(data["email"],style:GoogleFonts.poppins(color: Colors.white,fontSize: 17,fontWeight: FontWeight.w500,decoration: TextDecoration.underline)),
                                                    const SizedBox(width: 5,),
                                                    const Icon(Icons.email,color: Colors.green,size: 30,)
                                                  ],
                                                )
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white24,
                                              borderRadius: BorderRadius.circular(8)
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text("Ph.no",style:GoogleFonts.poppins(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                        const SizedBox(width: 10,),
                                        GestureDetector(
                                          onTap: () async{
                                            final phNo = "tel:${data["PhoneNumber"]}>";
                                          try {
                                              await launchUrlString(phNo);
                                            } catch (_e) { print(_e);}
                                          },
                                            child: Row(
                                              children: [
                                                Text(data["PhoneNumber"],style:GoogleFonts.poppins(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500,decoration: TextDecoration.underline)),
                                                const SizedBox(width: 5,),
                                                const Icon(Icons.phone,color: Colors.green,size: 30,)
                                              ],
                                            )
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20,),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white24,
                                              borderRadius: BorderRadius.circular(8)
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text("about",style:GoogleFonts.poppins(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                        const SizedBox(width: 10,),
                                        Text(data["about"],style:GoogleFonts.poppins(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w300)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 50,)
                          ],
                        );
                      }
                      return Text("loading",style: TextStyle(color: Colors.white),);
                    }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
