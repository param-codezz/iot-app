import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static Future<void> saveData(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    print('Data saved: $key = $value');
  }

  static Future<String?> retrieveData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(key);
    print('Retrieved data: $key = $value');
    return value;
  }
}
