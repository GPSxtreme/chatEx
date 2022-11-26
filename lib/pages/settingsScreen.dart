import 'package:chat_room/consts.dart';
import 'package:chat_room/services/authService.dart';
import 'package:chat_room/services/localDataService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../services/themeDataService.dart';
import 'package:drop_shadow/drop_shadow.dart';

class SettingsScreen extends StatefulWidget {
  static String id = "settings_screen";
  static bool isAThemeTileActive = false;
  static String selectedThemeColor = "";
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = FirebaseAuth.instance;
  MainScreenTheme themeData = MainScreenTheme();
  bool isInEmailEditMode = false;
  String newUserEmail = "";
  String userEmailFetched = "";
  @override
  void initState() {
    super.initState();
    themeData.addListener(themeListener);
    userEmailFetched = _auth.currentUser?.email ?? "";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsScreenTheme.settingsScreenBg,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(color: SettingsScreenTheme.settingsScreenAppBarTitle),
        ),
        backgroundColor: SettingsScreenTheme.settingsScreenAppBarBg,
      ),
      body: Column(
          children: [
            Expanded(
              child: ScrollConfiguration(
                behavior: const ScrollBehavior(),
                child: GlowingOverscrollIndicator(
                  axisDirection: AxisDirection.down,
                  color: MainScreenTheme.mainScreenBg,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 10,),
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.95,
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 5, vertical: 25),
                                child: Column(children: [
                                  Text(
                                    "App Theme",
                                    style: GoogleFonts.poppins(
                                        color: SettingsScreenTheme.settingsScreenText,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Divider(
                                    color: Colors.white12,
                                    indent: 20,
                                    endIndent: 20,
                                    height: 2,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                                    children: const [
                                      ThemeTile(
                                        tileColorHexCode: "501b23",
                                      ),
                                      ThemeTile(
                                        tileColorHexCode: "961e7c",
                                      ),
                                      ThemeTile(
                                        tileColorHexCode: "4B0082",
                                      ),
                                      ThemeTile(
                                        tileColorHexCode: "3c341f",
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async{
                                          await LocalDataService.setUserTheme(SettingsScreen.selectedThemeColor);
                                          ThemeDataService.setAppTheme(SettingsScreen.selectedThemeColor);
                                          showSnackBar(context, "Theme set.\nRestart app to show changes", 2000,hexCode: SettingsScreen.selectedThemeColor);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: MainScreenTheme.mainScreenBg,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        child:Text(
                                          "Apply",
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 15,),
                                      ElevatedButton(
                                        onPressed: () async{
                                          await LocalDataService.setUserTheme("");
                                          SettingsScreen.isAThemeTileActive = false;
                                          ThemeDataService.resetToDark();
                                          showSnackBar(context, "Default theme set.\nRestart app to show changes", 2000,bgColor:Colors.black);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: MainScreenTheme.mainScreenBg,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        child:Text(
                                          "Reset",
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ]),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10,),
                          ListTile(
                            leading: const Icon(Icons.password,color: Colors.white,size: 30,),
                            title: Text("Change password",style: GoogleFonts.poppins(color: Colors.white),),
                            onTap: ()async{
                              await AuthService.changeUserPassword();
                              showSnackBar(context, "Password reset email sent to $userEmailFetched\nPlease check spam folder of your email.", 3800,bgColor: MainScreenTheme.mainScreenBg == Colors.black ? HexColor("222222"):Colors.indigo );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.email,color: Colors.white,size: 30,),
                            title: Text("Change email",style: GoogleFonts.poppins(color: Colors.white),),
                            onTap: ()async{
                              if(!isInEmailEditMode){
                                setState(() {
                                  isInEmailEditMode = true;
                                });
                              }else{
                                setState(() {
                                  isInEmailEditMode = false;
                                });
                              }
                            },
                          ),
                          if(isInEmailEditMode) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7),
                              child: TextFormField(
                                cursorColor: Colors.white,
                                initialValue: userEmailFetched,
                                // controller: userNameController,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                                keyboardType:
                                TextInputType.emailAddress,
                                onChanged: (value) {
                                  newUserEmail = value;
                                },
                                decoration:
                                kMsgInputContainerDecoration.copyWith(
                                    fillColor: Colors.white12,
                                    prefixIcon: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    suffixIcon: IconButton(onPressed: ()async{
                                      if(newUserEmail.isEmpty){
                                        newUserEmail = userEmailFetched;
                                      }
                                      userEmailFetched = newUserEmail;
                                      await AuthService.changeUserEmail(context, userEmailFetched);
                                    }, icon: const Icon(Icons.check,color: Colors.white,size: 30,))
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            HelperFunctions.tradeMark(),
          ],
        ),
    );
  }
}

class ThemeTile extends StatefulWidget {
  const ThemeTile({super.key, required this.tileColorHexCode});
  final String tileColorHexCode;
  @override
  State<ThemeTile> createState() => _ThemeTileState();
}

class _ThemeTileState extends State<ThemeTile> {
  bool isSelected = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpTile();
  }
  setUpTile()async{
    final userTheme  = await LocalDataService.getUserTheme();
    if(userTheme != null && userTheme == widget.tileColorHexCode){
      setState(() {
        isSelected = true;
      });
      SettingsScreen.isAThemeTileActive = true;
    }
  }
  onTap(){
    if (!isSelected && !SettingsScreen.isAThemeTileActive) {
      SettingsScreen.isAThemeTileActive = true;
      SettingsScreen.selectedThemeColor = widget.tileColorHexCode;
      setState(() {
        isSelected = true;
      });
    }else if(isSelected && SettingsScreen.isAThemeTileActive) {
      SettingsScreen.isAThemeTileActive = false;
      SettingsScreen.selectedThemeColor = "";
      setState(() {
        isSelected = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DropShadow(
        blurRadius: 1,
        offset: const Offset(1,1),
        opacity: 1,
        spread: 1,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
              color: HexColor(widget.tileColorHexCode),
              borderRadius: BorderRadius.circular(100),
              border:
                  isSelected ? Border.all(color: Colors.blue, width: 3) : null),
          child: Center(
            child: isSelected? Icon(Icons.check,color: Colors.black.withAlpha(87),size: 30,):null,
          ),
        ),
      ),
    );
  }
}
