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
  static void setUserName(String userName)async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName',  userName);
  }
  static void setUserDp(String userDpUrl)async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userDpUrl',  userDpUrl);
  }
  static Future<String?> getUserName()async{
    final prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('userName');
    return userName;
  }
  static Future<String?> getUserDp()async{
    final prefs = await SharedPreferences.getInstance();
    String? userDpUrl = prefs.getString('userDpUrl');
    return userDpUrl;
  }

}