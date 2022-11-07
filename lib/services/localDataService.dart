import 'package:shared_preferences/shared_preferences.dart';

class LocalDataService{
  static void setUserDpUrl(String imgUrl)async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userDpUrl', imgUrl);
  }
  static Future<String?> getUserDpUrl()async{
    final prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('userDpUrl');
    return url;
  }
}