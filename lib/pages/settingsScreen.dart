import 'package:chat_room/services/themeDataService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class SettingsScreen extends StatefulWidget {
  static String id = "settings_screen";
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Color settingsScreenAppBarBg = Colors.black12;
  Color settingsScreenAppBarTitle = Colors.white;
  Color settingsScreenBg = Colors.black;
  Color settingsScreenText = Colors.white;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: settingsScreenBg,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(color: settingsScreenAppBarTitle),
        ),
        backgroundColor: settingsScreenAppBarBg,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                decoration: BoxDecoration(
                  color: HexColor("222222"),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 25),
                  child: Column(children: [
                    Text(
                      "App Theme",
                      style: GoogleFonts.poppins(
                          color: settingsScreenText,
                          fontSize: 22,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(
                      color: Colors.white24,
                      indent: 20,
                      endIndent: 20,
                      height: 2,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ThemeTile(
                          tileColor: Colors.brown,
                          fun: MainScreenTheme().customTheme(Colors.brown),
                        ),
                        ThemeTile(
                          tileColor: Colors.orange,
                          fun: MainScreenTheme().customTheme(Colors.orange),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ThemeTile(
                          tileColor: Colors.indigo,
                          fun: MainScreenTheme().customTheme(Colors.indigo),
                        ),
                        ThemeTile(
                          tileColor: Colors.teal,
                          fun: MainScreenTheme().customTheme(Colors.teal),
                        ),
                      ],
                    ),
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
  const ThemeTile({super.key, required this.tileColor, required this.fun});
  final Color tileColor;
  final Function fun;
  @override
  State<ThemeTile> createState() => _ThemeTileState();
}

class _ThemeTileState extends State<ThemeTile> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          setState(() {
            isSelected = false;
          });
        } else {
          setState(() {
            isSelected = true;
          });
          widget.fun;
        }
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
            color: widget.tileColor,
            borderRadius: BorderRadius.circular(18),
            border:
                isSelected ? Border.all(color: Colors.blue, width: 5) : null),
      ),
    );
  }
}
