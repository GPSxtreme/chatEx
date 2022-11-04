import 'package:chat_room/databaseService.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../consts.dart';


class profileUserShow extends StatefulWidget {
  static String id = 'profileUser_screen';
  const profileUserShow({Key? key}) : super(key: key);

  @override
  State<profileUserShow> createState() => _profileUserShowState();
}

class _profileUserShowState extends State<profileUserShow> {
  Map data = {};
  String userName = "";
  final _fireStore = FirebaseFirestore.instance;
  bool inEditMode = false;
  String updatedName = "";
  String updatedAbout = "";

  //class methods
  void openCaller()async{
    final phNo = "tel:${data["phoneNumber"]}>";
    try {
      await launchUrlString(phNo);
    } catch (e) { print(e);}
  }
  void openMail()async{
    final email = "mailto:${data['email']}";
    try {
      await launchUrlString(email);
    } catch (e) { print(e);}
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty? data: ModalRoute.of(context)?.settings.arguments as Map;
    return Scaffold(
      appBar: AppBar(
        title: Text(data["isMe"] ? "My Profile": "User Profile",style: GoogleFonts.poppins(color: Colors.white),),
        backgroundColor: Colors.black12,
        actions: [
          if(data["isMe"]) ...[
            IconButton(onPressed: (){
              setState(() {
                inEditMode = true;
              });
            },
                icon: const Icon(Icons.edit,color: Colors.white,)
            )
          ]
        ],
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: _fireStore.collection('users').doc(data['senderUid']).get(),
                builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot> snapshot){
                  bool isMe = data["isMe"];

                  if (snapshot.hasError) {
                    return const Text("Something went wrong");
                  }
                  if (snapshot.hasData && !snapshot.data!.exists) {
                    return const Text("Document does not exist");
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
                    Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                    return Column(
                      children: [
                        const SizedBox(height: 30,),
                        CircleAvatar(
                          radius: 90,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(data['profileImgLink'],),
                        ),
                        if(!isMe) ...[
                          const SizedBox(height: 15,),
                          Text(data["userName"],style:GoogleFonts.poppins(color: Colors.white,fontSize: 40,fontWeight: FontWeight.w600,),textAlign: TextAlign.center,),
                          const SizedBox(height: 15,),
                          Container(
                            width: MediaQuery.of(context).size.width*0.5,
                            decoration: BoxDecoration(
                              color: HexColor("222222"),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(onPressed: openCaller,
                                    icon: const Icon(Icons.call,color: Colors.blue,size: 30,)
                                ),
                                const SizedBox(width: 10,),
                                IconButton(onPressed: openMail,
                                    icon: const Icon(Icons.mail,color: Colors.blue,size: 30,)
                                ),
                              ],
                            ),
                          )
                        ],
                        const SizedBox(height: 20,),
                        Divider(
                          thickness: 2,
                          indent: MediaQuery.of(context).size.width*0.055,
                          endIndent: MediaQuery.of(context).size.width*0.055,
                          height: 18,
                          color: HexColor("222222"),
                        ),
                        const SizedBox(height: 25,),
                        Container(
                          width: MediaQuery.of(context).size.width*0.9,
                          decoration: BoxDecoration(
                              color: HexColor("222222"),
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Column(
                              children: [
                                if(isMe & !inEditMode) ...[
                                  Text(data["userName"],style:GoogleFonts.poppins(color: Colors.white,fontSize: 30,fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 20,),
                                ],
                                if(inEditMode) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: TextFormField(
                                      initialValue: data["userName"],
                                      // controller: userNameController,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.emailAddress,
                                      onChanged: (value){
                                        updatedName = value;
                                      },
                                      decoration: kTextFieldInputDecoration.copyWith(hintText: "",labelText: "Name",prefixIcon: const Icon(Icons.person,color: Colors.white,)),
                                    ),
                                  ),
                                  const SizedBox(height: 20,),
                                ],
                                GestureDetector(
                                    onTap:isMe ? null:openMail,
                                    child: Text(data["email"],style:GoogleFonts.poppins(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 17),textAlign: TextAlign.center,)
                                ),
                                const SizedBox(height: 20,),
                                GestureDetector(
                                    onTap:isMe ? null:openCaller,
                                    child: Text(data["phoneNumber"],style:GoogleFonts.poppins(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500,),textAlign: TextAlign.center,)
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
                                        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 2),
                                        child: Text("About",style:GoogleFonts.poppins(color: Colors.white,fontSize: 15,fontWeight: FontWeight.w400)),
                                      ),
                                    ),
                                    const SizedBox(height: 20,),
                                    inEditMode ?
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: TextFormField(
                                        initialValue: data["about"],
                                        maxLines: 3,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.name,
                                        onChanged: (value){
                                          updatedAbout = value;
                                        },
                                        decoration: kTextFieldInputDecoration.copyWith(labelText: "About",),
                                      ),
                                    ):
                                    Text('" ${data["about"]} "',style:GoogleFonts.poppins(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w400)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if(inEditMode) ...[
                          const SizedBox(height: 30,),
                          TextButton(
                            onPressed:()async{
                              if(updatedName != "" && updatedAbout != ""){
                                await DatabaseService.updateUserName(updatedName);
                                await DatabaseService.updateUserAbout(updatedAbout);
                                setState(() {
                                  data["userName"] = updatedName;
                                  data["about"] = updatedAbout;
                                });
                                showSnackBar(context, "Updated both name and about!", 1800,bgColor: Colors.blue);
                              }
                              else if (updatedName != ""){
                                await DatabaseService.updateUserName(updatedName);
                                setState(() {
                                  data["userName"] = updatedName;
                                });
                                showSnackBar(context, "Updated user name!", 1800,bgColor: Colors.blue);
                              }
                              else if(updatedAbout != ""){
                                await DatabaseService.updateUserAbout(updatedAbout);
                                setState(() {
                                  data["about"] = updatedAbout;
                                });
                                showSnackBar(context, "Updated user about!", 1800,bgColor: Colors.blue);
                              }else{
                                showSnackBar(context, "No changes made", 1800,bgColor: Colors.blue);
                              }
                              setState(() {
                                inEditMode = false;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                child: Text("Update",style: GoogleFonts.poppins(color: Colors.white,fontSize: 18),),
                              ),
                            ),
                          )
                        ],
                        const SizedBox(height: 50,)
                      ],
                    );
                  }
                  return const CircularProgressIndicator(color: Colors.white,);
                }
            ),
          ],
        ),
      ),
    );
  }
}
