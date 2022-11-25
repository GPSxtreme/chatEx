import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat_room/services/themeDataService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:path_provider/path_provider.dart';
import 'components/groupCreatePopUp.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'dart:io';

const kTextFieldInputDecoration = InputDecoration(
  hintText: '',
  labelText: '',
  labelStyle: TextStyle(color: Colors.white, fontSize: null),
  hintStyle: TextStyle(color: Colors.white),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(color: Colors.white, width: 2.0),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(color: Colors.white, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(color: Colors.orangeAccent, width: 2.0),
  ),
);
InputDecoration kMsgInputContainerDecoration = InputDecoration(
  filled: true,
  fillColor: HexColor("111111"),
  hintText: 'Type your message here...',
  hintStyle:
      GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w400),
  border: OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: HexColor("111111"), width: 0)
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: HexColor("111111"), width: 0)
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: HexColor("111111"), width: 0),
  ),
);

InputDecoration kSearchGroupInputDecoration = InputDecoration(
  border: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: Colors.white, width: 1.4),
  ),
  enabledBorder: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: Colors.white, width: 1.4),
  ),
  focusedBorder: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: Colors.white, width: 1.4),
  ),
  hintStyle: GoogleFonts.poppins(color: Colors.white),
  hintText: "search for a group",
);

void showSnackBar(BuildContext buildContext, String txt, int duration,
    {Color? bgColor,String? hexCode}) {
  Color bgNormalColor = Colors.red;
  if(bgColor != null){
    bgNormalColor = bgColor;
  }
  ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
    content: SizedBox(
      width: MediaQuery.of(buildContext).size.width * 0.80,
      child: AutoSizeText(
        txt,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
        maxLines: 2,
      ),
    ),
    backgroundColor: hexCode != null ? HexColor(hexCode):bgNormalColor,
    shape: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Colors.transparent)
    ),
    duration: Duration(milliseconds: duration),
  ));
}

//alertBox
Future showDialogBox(BuildContext context, title, String msg, Color titleColor,
    dynamic Function()? yes, dynamic Function()? no) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 5,
          backgroundColor: MainScreenTheme.mainScreenBg,
          title: Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(msg, style: const TextStyle(color: Colors.white))
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: yes,
                child: const Text(
                  'Yes',
                  style: TextStyle(color: Colors.white),
                )),
            TextButton(
                onPressed: no,
                child: const Text(
                  'No',
                  style: TextStyle(color: Colors.white),
                )),
          ],
        );
      });
}

class HelperFunctions {
  //contains helper functions
  static popUpGrpCreateDialog(
      BuildContext context, String userName, String userUid) {
    showDialog(
        barrierColor: Colors.black54,
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return GroupCreatePopUp(userName: userName, userUid: userUid);
        });
  }

  static Future openGmail(BuildContext context) async {
    try {
      await LaunchApp.openApp(
          androidPackageName: 'com.google.android.gm', openStore: true);
    } catch (e) {
      showSnackBar(context, "$e", 2000);
    }
  }

  static Future<bool> checkUserConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }
  static Future<bool> checkIfLocalDirExistsInApp(String path)async{
    final appDocDir = await getApplicationDocumentsDirectory();
    Directory fileDir = Directory('${appDocDir.path}/$path/');
    final doesDirExist = await fileDir.exists();
    return doesDirExist;
  }
  static Future createLocalDirInApp(String path)async{
    final appDocDir = await getApplicationDocumentsDirectory();
    Directory fileDir = Directory('${appDocDir.path}/$path/');
    await fileDir.create(recursive: true);
  }
  static Future<bool> checkIfLocalDirExistsInStorage(String path)async{
    final appDocDir = await getExternalStorageDirectory();
    Directory fileDir = Directory('${appDocDir?.path}/$path');
    final doesDirExist = await fileDir.exists();
    return doesDirExist;
  }
  static Future createLocalDirInStorage(String path)async{
    final appDocDir = await getExternalStorageDirectory();
    Directory fileDir = Directory('${appDocDir?.path}/$path');
    await fileDir.create(recursive: true);
  }
  static void clearImageCache(){
    imageCache.clear();
    imageCache.clearLiveImages();
  }
  static void scrollDown(){
    final ScrollController controller = ScrollController();
    //animate scroll
    controller.animateTo(
      controller.position.maxScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
    //no animate scroll
    controller.jumpTo(controller.position.maxScrollExtent);
  }
  static popOutOfContext(BuildContext context) {
    Navigator.of(context).pop();
  }
  static popOfPage(BuildContext context){
    final nav = Navigator.of(context);
    nav.pop();
    nav.pop();
  }
  static Widget tradeMark(){
    return Column(
      children: [
        Text("By\nGPSxtreme",style: GoogleFonts.mansalva(color: Colors.white54),textAlign: TextAlign.center,),
        const SizedBox(height: 10,)
      ],
    );
  }
}
