//language_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class LanguageService {
  static const _langCodeKey = 'langCode';
  static const _countryCodeKey = 'countryCode';

  static Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langCodeKey, locale.languageCode);
    await prefs.setString(_countryCodeKey, locale.countryCode ?? '');
  }

  static Future<Locale?> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_langCodeKey);
    final countryCode = prefs.getString(_countryCodeKey);

    if (langCode != null && countryCode != null) {
      return Locale(langCode, countryCode);
    }
    return null;
  }

  static void updateLocale(Locale locale) {
    saveLocale(locale);
    Get.updateLocale(locale);
  }
}
