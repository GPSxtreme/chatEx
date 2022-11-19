import 'package:chat_room/services/localDataService.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class ThemeDataService{
  static Future setUpAppThemes()async{
   final userTheme = await LocalDataService.getUserTheme();
   if(userTheme != null && userTheme.isNotEmpty){
     MainScreenTheme().customTheme(userTheme);
      SettingsScreenTheme().customTheme(userTheme);
   }else if(userTheme == ""){
     resetToDark();
   }
  }
  static setAppTheme(String hexCode){
    MainScreenTheme().customTheme(hexCode);
    SettingsScreenTheme().customTheme(hexCode);
  }
  static resetToDark(){
    MainScreenTheme().reset();
    SettingsScreenTheme().reset();
  }
}

class MainScreenTheme with ChangeNotifier {
  static Color mainScreenBg = Colors.black;
  static Color mainScreenAppBarBg = Colors.black12;
  static Color mainScreenAppBarSearchIcon = Colors.white;
  static Color mainScreenAppBarBgTitle = Colors.white;
  customTheme(String hexCode) {
    mainScreenBg = HexColor(hexCode);
    notifyListeners();
  }
  reset() {
    mainScreenBg = Colors.black;
    notifyListeners();
  }
}
class SettingsScreenTheme with ChangeNotifier {
  static Color settingsScreenAppBarBg = Colors.black12;
  static Color settingsScreenAppBarTitle = Colors.white;
  static Color settingsScreenBg = Colors.black;
  static Color settingsScreenText = Colors.white;
  customTheme(String hexCode) {
    settingsScreenBg = HexColor(hexCode);
    notifyListeners();
  }
  reset() {
    settingsScreenBg = Colors.black;
    notifyListeners();
  }
}