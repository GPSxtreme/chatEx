import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:url_launcher/url_launcher_string.dart';


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

            },
                icon: const Icon(Icons.edit,color: Colors.white,)
            )
          ]
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
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
                          const SizedBox(height:30),
                          CircleAvatar(
                            radius: 90,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(data['profileImgLink'],),
                          ),
                          if(!isMe) ...[
                            const SizedBox(height: 20,),
                            Text(data["userName"],style:GoogleFonts.poppins(color: Colors.white,fontSize: 40,fontWeight: FontWeight.w600,),textAlign: TextAlign.center,),
                          ],
                          const SizedBox(height: 20,),
                          Divider(
                            thickness: 1.5,
                            indent: MediaQuery.of(context).size.width*0.1,
                            endIndent: MediaQuery.of(context).size.width*0.1,
                            height: 15,
                            color: HexColor("#999999"),
                          ),
                          const SizedBox(height: 30,),
                          Container(
                            width: MediaQuery.of(context).size.width*0.8,
                            decoration: BoxDecoration(
                                color: HexColor("222222"),
                              borderRadius: BorderRadius.circular(8)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: Column(
                                children: [
                                  if(isMe) ...[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(width: 30,),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white24,
                                              borderRadius: BorderRadius.circular(8)
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 7,vertical: 2),
                                            child: Text("Name",style:GoogleFonts.poppins(color: Colors.white,fontSize: 15,fontWeight: FontWeight.w400)),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(data["userName"],style:GoogleFonts.poppins(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600)),
                                        const SizedBox(width: 30,),
                                      ],
                                    )
                                  ],
                                  const SizedBox(height: 20,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 30,),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius: BorderRadius.circular(8)
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 7,vertical: 2),
                                          child: Text("Email",style:GoogleFonts.poppins(color: Colors.white,fontSize: 15,fontWeight: FontWeight.w400)),
                                        ),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                          onTap:()async{
                                            if(!isMe){
                                              final email = "mailto:${data['email']}";
                                              try {
                                                await launchUrlString(email);
                                              } catch (e) { print(e);}
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              Text(data["email"],style:GoogleFonts.poppins(color: Colors.white,fontWeight: FontWeight.w600)),
                                              const SizedBox(width: 30,),
                                            ],
                                          )
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 30,),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius: BorderRadius.circular(8)
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 7,vertical: 2),
                                          child: Text("Phone",style:GoogleFonts.poppins(color: Colors.white,fontSize: 15,fontWeight: FontWeight.w400)),
                                        ),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () async{
                                          if(!isMe){
                                            final phNo = "tel:${data["phoneNumber"]}>";
                                            try {
                                              await launchUrlString(phNo);
                                            } catch (e) { print(e);}
                                          }
                                        },
                                          child: Row(
                                            children: [
                                              Text(data["phoneNumber"],style:GoogleFonts.poppins(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600,)),
                                              const SizedBox(width: 5,),
                                              const Icon(Icons.phone,color: Colors.green,size: 30,)
                                            ],
                                          )
                                      ),
                                      const SizedBox(width: 30,),
                                    ],
                                  ),
                                  const SizedBox(height: 30,),
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
                                      Text(data["about"],style:GoogleFonts.poppins(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w400)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
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
      ),
    );
  }
}
