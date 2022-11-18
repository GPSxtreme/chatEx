import 'package:flutter/material.dart';

class MainScreenTheme with ChangeNotifier {
  static Color mainScreenBg = Colors.black;
  static Color mainScreenAppBarBg = Colors.black12;
  static Color mainScreenAppBarSearchIcon = Colors.white;
  static Color mainScreenAppBarBgTitle = Colors.white;
  customTheme(Color color) {
    mainScreenBg = color;
    notifyListeners();
  }

  dark() {
    mainScreenBg = Colors.black;
    notifyListeners();
  }
}
