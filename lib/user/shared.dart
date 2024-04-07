import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {
  // keys
  static String userLoggedInKey = "LOGGEDINKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String userIdKey = "USERIdKEY";
  static String userTokenKey = "USERTOKENKEY";
  static String userPhoneKey = "USERPHONEKEY";

  // saving the data to shared preferences

  static Future<bool> saveUserLoggedInStatus(bool isUserLogggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(userLoggedInKey, isUserLogggedIn);
  }

  static Future<bool> saveUserEmailSF(String userEmail) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userEmailKey, userEmail);
  }

  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }

  static Future<String?> getUserEmailFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userEmailKey);
  }

  static Future<String?> getUserIdFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userIdKey);
  }

  static Future<String?> getUserTokenFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userTokenKey);
  }

  static Future<String?> getUserPhoneFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userPhoneKey);
  }
}
