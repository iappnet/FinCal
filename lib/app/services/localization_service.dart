import 'dart:convert'; // To decode JSON files
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // To load JSON files
import 'package:get/get.dart';

class LocalizationService extends Translations {
  static Locale? locale = Locale('en', 'US'); // Default to English
  static Locale fallbackLocale = Locale('en', 'US');
  static final langs = ['English', 'العربية'];

  static final locales = [
    Locale('en', 'US'),
    Locale('ar', 'SA'),
  ];
  static Map<String, Map<String, String>> localizedStrings = {};

  // Load JSON files dynamically
  static Future<void> loadJSON() async {
    try {
      final enData = await rootBundle.loadString('assets/lang/en.json');
      final arData = await rootBundle.loadString('assets/lang/ar.json');
      localizedStrings['en_US'] = Map<String, String>.from(json.decode(enData));
      localizedStrings['ar_SA'] = Map<String, String>.from(json.decode(arData));
    } catch (e) {
      print('Error loading localization files: $e');
    }
  }

  @override
  Map<String, Map<String, String>> get keys => localizedStrings;

  void changeLocale(String lang) {
    final selectedLocale = _getLocaleFromLanguage(lang);
    locale = selectedLocale; // Update the static locale
    Get.updateLocale(selectedLocale);
  }

  Locale _getLocaleFromLanguage(String lang) {
    for (int i = 0; i < langs.length; i++) {
      if (lang == langs[i]) return locales[i];
    }
    return fallbackLocale;
  }

  static String getCurrentLanguage() {
    // Fallback to English if locale is null
    return locale?.languageCode == 'ar' ? 'العربية' : 'English';
  }
}
