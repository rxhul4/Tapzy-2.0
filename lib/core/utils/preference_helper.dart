import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHelper {
  static const String IS_LOGIN = "isLogin";
  static const String USER_DATA = "userData";
  static const String USER_ID = "userId";
  static const String IS_NEW = "isNew";
  static const String AUTH_TOKEN = "authToken";

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> load() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<void> setString(String key, String value) async {
    await _prefs!.setString(key, value);
  }

  static Future<void> setObject(String key, dynamic value) async {
    await _prefs!.setString(key, const JsonEncoder().convert(value));
  }

  static Future<void> setInt(String key, int value) async {
    await _prefs!.setInt(key, value);
  }

  static Future<void> setDouble(String key, double value) async {
    await _prefs!.setDouble(key, value);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs!.setBool(key, value);
  }

  static String? getString(String key, {String? def}) {
    return _prefs!.getString(key) ?? def;
  }

  static int? getInt(String key, {int? def}) {
    return _prefs!.getInt(key) ?? def;
  }

  static double? getDouble(String key, {double? def}) {
    return _prefs!.getDouble(key) ?? def;
  }

  static bool getBool(String key, {bool def = false}) {
    return _prefs!.getBool(key) ?? def;
  }

  static dynamic getObject(String key) {
    final val = getString(key, def: '');
    if (val!.isNotEmpty) {
      return const JsonDecoder().convert(val);
    }
    return '';
  }

  static Future<void> clear() async {
    await _prefs!.clear();
  }
}
