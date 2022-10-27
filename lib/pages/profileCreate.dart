import 'package:chat_room/authService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ionicons/ionicons.dart';
import '../components/roundedBtnT1.dart';
import 'chatScreen.dart';
import 'package:chat_room/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class profileCreate extends StatefulWidget {
  static String id = "profileCreate_Screen";
  const profileCreate({Key? key}) : super(key: key);

  @override
  State<profileCreate> createState() => _profileState();
}

class _profileState extends State<profileCreate> {

  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  bool showLoader = false;
  String userName = '';
  String phoneNumber = '';
  String about = '';
  String? userUid;
  late User loggedUser;
  String imageUrl = " ";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser (){
    try{
      final user =  _auth.currentUser;
      if(user!=null){
        loggedUser = user;
      }
    }
    catch(e){
      print(e);
    }
  }
  void pickUploadImage() async{
    final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      imageQuality: 50
    );
    setState(() {
      showLoader = true;
    });
    Reference ref = FirebaseStorage.instance.ref().child("userProfilePictures/${loggedUser.uid}.jpg");
    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then(
        (val){
          setState(() {
            imageUrl = val;
          });
        }
    );
    setState(() {
      showLoader = false;
    });
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width*0.70,
                        child: Center(
                          child: AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                'Welcome!',
                                textStyle: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w600,
                                ),
                                speed: const Duration(milliseconds: 300),
                              ),
                            ],
                            pause: const Duration(milliseconds: 4000),
                            repeatForever: true,
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text(
                        'Complete your profile.',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,)
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  GestureDetector(
                    onTap: pickUploadImage,
                    child: imageUrl == " " ? CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child:  Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Ionicons.camera_outline,size: 40,color: Colors.black,),
                            Text("choose",style:GoogleFonts.poppins(color: Colors.black,fontSize:12),)
                          ],
                        ),
                    ) : CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(imageUrl),
                    )
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        TextField(
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.name,
                          onChanged: (value){
                            userName = value;
                          },
                          decoration: kTextFieldInputDecoration.copyWith(hintText: "set a username",labelText: "Username"),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextField(
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          onChanged: (value){
                            phoneNumber = value;
                          },
                          decoration: kTextFieldInputDecoration.copyWith(hintText: "",labelText: "Phone number"),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextField(
                          maxLines: 3,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.name,
                          onChanged: (value){
                            about = value;
                          },
                          decoration: kTextFieldInputDecoration.copyWith(hintText: "Eg: Iam a student studying in...",labelText: "About",),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        roundedBtn(title: 'Finish', onPressed: () {
                          if(userName.isNotEmpty && phoneNumber.isNotEmpty && phoneNumber.length == 10 && about.isNotEmpty){
                            setState(() {
                              showLoader = true;
                            });
                            try{
                              _fireStore.collection("users").doc(loggedUser.uid).set({
                                "email": loggedUser.email,
                                "userName": userName,
                                "joinedGroups":FieldValue.arrayUnion([]),
                                "phoneNumber": phoneNumber,
                                "about":about,
                                "profileImgLink":imageUrl,
                              });
                              AuthService.pushMainScreenRoutine(context);
                            }on FirebaseAuthException catch  (e) {
                              setState(() {
                                showLoader = false;
                              });
                              showSnackBar(context,e.message.toString(),2000);
                            }
                          }
                          else if(userName.isEmpty || phoneNumber.isEmpty || about.isEmpty){
                            showSnackBar(context,'Please fill in all the fields',2000);
                          }
                          else if (phoneNumber.length != 10 && (userName.isNotEmpty && phoneNumber.isNotEmpty && about.isNotEmpty)){
                          showSnackBar(context,'Please enter a valid phone number',2000);
                          }
                        }),
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
