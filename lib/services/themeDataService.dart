import 'package:flutter/material.dart';

class MainScreenTheme with ChangeNotifier {
  static Color mainScreenBg = Colors.black;
  static Color mainScreenAppBarBg = Colors.black12;
  static Color mainScreenAppBarSearchIcon = Colors.white;
  static Color mainScreenAppBarBgTitle = Colors.white;
  brown() {
    mainScreenBg = Colors.brown;
    notifyListeners();
  }

  dark() {
    mainScreenBg = Colors.black;
    notifyListeners();
  }

  static ThemeData style0() {
    return ThemeData(
      backgroundColor: mainScreenBg,
      appBarTheme: AppBarTheme(
          actionsIconTheme: IconThemeData(color: mainScreenAppBarSearchIcon),
          backgroundColor: mainScreenAppBarBg,
          toolbarTextStyle: TextStyle(color: mainScreenAppBarBgTitle)),
    );
  }
}
