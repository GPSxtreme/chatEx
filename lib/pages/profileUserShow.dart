import 'package:chat_room/services/cloudStorageService.dart';
import 'package:chat_room/services/databaseService.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:chat_room/components/imagePickerCircleAvatar.dart';
import '../consts.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/themeDataService.dart';

class profileUserShow extends StatefulWidget {
  static String id = 'profileUser_screen';
  const profileUserShow({Key? key}) : super(key: key);

  @override
  State<profileUserShow> createState() => _profileUserShowState();

}

class _profileUserShowState extends State<profileUserShow> {
  Map dataPassed = {};
  String userName = "";
  final _fireStore = FirebaseFirestore.instance;
  bool inEditMode = false;
  String updatedName = "";
  String updatedAbout = "";
  bool isLoading = false;
  MainScreenTheme themeData = MainScreenTheme();

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
  //class methods
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    themeData.addListener(themeListener);
  }

  Future<void> onRefresh()async{
     HelperFunctions.clearImageCache();
      setState(() {
      });
  }
  @override
  Widget build(BuildContext context) {
    dataPassed = dataPassed.isNotEmpty
        ? dataPassed
        : ModalRoute.of(context)?.settings.arguments as Map;
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            dataPassed["isMe"] ? "My profile" : "User Profile",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.black12,
          actions: [
            if (dataPassed["isMe"]) ...[
              !inEditMode ?
              IconButton(
                  onPressed: () {
                    setState(() {
                      inEditMode = true;
                    });
                  },
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  )):IconButton(
                  onPressed: () {
                    setState(() {
                      inEditMode = false;
                    });
                  },
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: Colors.white,
                  ))

            ],
          ],
        ),
        backgroundColor: MainScreenTheme.mainScreenBg,
        body: RefreshIndicator(
          onRefresh: onRefresh,
          color: MainScreenTheme.mainScreenBg,
          child: ListView(
            children: [
              Column(
                children: [
                  FutureBuilder<DocumentSnapshot>(
                      future: _fireStore
                          .collection('users')
                          .doc(dataPassed['senderUid'])
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        bool isMe = dataPassed["isMe"];
                        if (snapshot.hasError) {
                          return const Text("Something went wrong");
                        }
                        if (snapshot.hasData && !snapshot.data!.exists) {
                          return const Text("Document does not exist");
                        }
                        if (snapshot.connectionState == ConnectionState.done) {
                          Map<String, dynamic> dataFetched =
                          snapshot.data!.data() as Map<String, dynamic>;
                          void openCaller() async {
                            final phNo = "tel:${dataFetched["phoneNumber"]}";
                            try {
                              await launchUrlString(phNo);
                            } catch (e) {
                              print(e);
                            }
                          }

                          void openMail() async {
                            final email = "mailto:${dataFetched["email"]}";
                            try {
                              await launchUrlString(email);
                            } catch (e) {
                              print(e);
                            }
                          }

                          return Column(
                            children: [
                              const SizedBox(
                                height: 30,
                              ),
                              if (!inEditMode) ...[
                                if(!isMe) ...[
                                  dataFetched["profileImgLink"].toString().isNotEmpty ?
                                  CircleAvatar(
                                    radius: 90,
                                    backgroundColor: Colors.white,
                                    backgroundImage: NetworkImage(dataFetched["profileImgLink"]),
                                  )
                                      : const CircleAvatar(
                                    radius: 90,
                                    backgroundColor: Colors.white,
                                    child: CircularProgressIndicator(
                                      color: Colors.blue,
                                      strokeWidth: 10,
                                    ),
                                  ),
                                ]
                                else ...[
                                  dataPassed["userProfilePicturePath"] != null
                                      ? CircleAvatar(
                                    radius: 90,
                                    backgroundColor: Colors.white,
                                    backgroundImage: FileImage(File(dataPassed["userProfilePicturePath"])),
                                  )
                                      : const CircleAvatar(
                                    radius: 90,
                                    backgroundColor: Colors.white,
                                    child: CircularProgressIndicator(
                                      color: Colors.blue,
                                      strokeWidth: 10,
                                    ),
                                  ),
                                ]
                              ],
                              if (inEditMode) ...[
                                ImagePickerCircleAvatar(userDpPath: dataPassed["userProfilePicturePath"])
                              ],
                              if (!isMe) ...[
                                const SizedBox(
                                  height: 15,
                                ),
                                SizedBox(
                                  width:MediaQuery.of(context).size.width*0.9,
                                  child: Text(
                                    dataFetched["userName"],
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  decoration: BoxDecoration(
                                    color: MainScreenTheme.mainScreenBg == Colors.black ? HexColor("222222"):Colors.black54,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                          onPressed: openCaller,
                                          icon: const Icon(
                                            Icons.call,
                                            color: Colors.blue,
                                            size: 30,
                                          )),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      IconButton(
                                          onPressed: openMail,
                                          icon: const Icon(
                                            Icons.mail,
                                            color: Colors.blue,
                                            size: 30,
                                          )),
                                    ],
                                  ),
                                )
                              ],
                              const SizedBox(
                                height: 20,
                              ),
                              Divider(
                                thickness: 2,
                                indent: MediaQuery.of(context).size.width * 0.055,
                                endIndent:
                                MediaQuery.of(context).size.width * 0.055,
                                height: 18,
                                color: MainScreenTheme.mainScreenBg == Colors.black ? HexColor("222222"):Colors.black54,
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: BoxDecoration(
                                    color: MainScreenTheme.mainScreenBg == Colors.black ? HexColor("222222"):Colors.black54,
                                    borderRadius:
                                    const BorderRadius.all(Radius.circular(8))),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 30),
                                  child: Column(
                                    children: [
                                      if (isMe & !inEditMode) ...[
                                        Text(dataFetched["userName"],
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 30,
                                                fontWeight: FontWeight.w600)),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                      if (inEditMode) ...[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: TextFormField(
                                            initialValue: dataFetched["userName"],
                                            // controller: userNameController,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            textAlign: TextAlign.center,
                                            keyboardType:
                                            TextInputType.emailAddress,
                                            onChanged: (value) {
                                              updatedName = value;
                                            },
                                            decoration:
                                            kTextFieldInputDecoration.copyWith(
                                                hintText: "",
                                                labelText: "Name",
                                                prefixIcon: const Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                )),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                      GestureDetector(
                                          onTap: isMe ? null : openMail,
                                          child: Text(
                                            dataFetched["email"],
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 17),
                                            textAlign: TextAlign.center,
                                          )),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      GestureDetector(
                                          onTap: isMe ? null : openCaller,
                                          child: Text(
                                            dataFetched["phoneNumber"],
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          )),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius: BorderRadius.circular(8)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          child: Text("About",
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400)),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      inEditMode
                                          ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: TextFormField(
                                          initialValue: dataFetched["about"],
                                          maxLines: 3,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.name,
                                          onChanged: (value) {
                                            updatedAbout = value;
                                          },
                                          decoration:
                                          kTextFieldInputDecoration
                                              .copyWith(
                                            labelText: "About",
                                          ),
                                        ),
                                      )
                                          : Text('" ${dataFetched["about"]} "',
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400)),
                                    ],
                                  ),
                                ),
                              ),
                              if (inEditMode) ...[
                                const SizedBox(
                                  height: 30,
                                ),
                                TextButton(
                                  onPressed: () async {
                                    if (updatedName != "" ||
                                        updatedAbout != "" ||
                                        ImagePickerCircleAvatar.image != null) {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      if (updatedName != "") {
                                        await DatabaseService.updateUserName(
                                            updatedName);
                                        setState(() {
                                          dataFetched["userName"] = updatedName;
                                          updatedName = "";
                                        });
                                      }
                                      if (updatedAbout != "") {
                                        await DatabaseService.updateUserAbout(
                                            updatedAbout);
                                        setState(() {
                                          dataFetched["about"] = updatedAbout;
                                          updatedAbout = "";
                                        });
                                      }
                                      if (ImagePickerCircleAvatar.image != null) {
                                        await CloudStorageService
                                            .updateUserProfilePic(
                                            ImagePickerCircleAvatar.image.path);
                                        await CloudStorageService.reDownloadUserProfilePicture();
                                        HelperFunctions.clearImageCache();
                                        ImagePickerCircleAvatar.image = null;
                                      }
                                      setState(() {
                                        isLoading = false;
                                        inEditMode = false;
                                      });
                                      showSnackBar(
                                          context,
                                          "Updated profile settings!\nRestart application to show changes.",
                                          3800,
                                          bgColor: Colors.blue);
                                    } else {
                                      showSnackBar(context, "No changes made", 1800,
                                          bgColor: Colors.blue);
                                      setState(() {
                                        inEditMode = false;
                                      });
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Text(
                                        "Update",
                                        style: GoogleFonts.poppins(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                              const SizedBox(
                                height: 50,
                              )
                            ],
                          );
                        }
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ))
                            ],
                          ),
                        );
                      }),
                ],
              )
            ],
          )
        ),
      ),
    );
  }
}
