import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService{
  static StorageService get to => Get.find();
  late final SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  String getString(String key){
    return _prefs.getString(key) ?? '';
  }

  int getInt(String key) {
    return _prefs.getInt(key) ?? 1;
  }

  bool getBool(String key){
    return _prefs.getBool(key) ?? false;
  }
}