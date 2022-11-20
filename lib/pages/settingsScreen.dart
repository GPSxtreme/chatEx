import 'package:chat_room/consts.dart';
import 'package:chat_room/services/localDataService.dart';
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
  MainScreenTheme themeData = MainScreenTheme();

  @override
  void initState() {
    super.initState();
    themeData.addListener(themeListener);
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
      body: SingleChildScrollView(
        child: Column(
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
                      color: Colors.white10,
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
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        ThemeTile(
                          tileColorHexCode: "4B0082",
                        ),
                        ThemeTile(
                          tileColorHexCode: "3c341f",
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
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
                            backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child:Text(
                            "Apply",
                            style: GoogleFonts.poppins(
                                fontSize: 20,
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
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child:Text(
                            "Reset",
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  ]),
                ),
              ),
            )
          ],
        ),
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
        blurRadius: 2,
        offset: const Offset(2,2),
        opacity: 1,
        spread: 1,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
              color: HexColor(widget.tileColorHexCode),
              borderRadius: BorderRadius.circular(100),
              border:
                  isSelected ? Border.all(color: Colors.blue, width: 3) : null),
          child: Center(
            child: isSelected? Icon(Icons.check,color: Colors.black.withAlpha(87),size: 60,):null,
          ),
        ),
      ),
    );
  }
}
