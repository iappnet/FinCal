import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  static final FlutterSecureStorage storage = FlutterSecureStorage();

  // Load JSON files dynamically
  static Future<void> loadJSON() async {
    try {
      final enData = await rootBundle.loadString('assets/lang/en.json');
      final arData = await rootBundle.loadString('assets/lang/ar.json');
      localizedStrings['en_US'] = Map<String, String>.from(json.decode(enData));
      localizedStrings['ar_SA'] = Map<String, String>.from(json.decode(arData));
    } catch (e) {
      // Handle error if necessary
    }
  }

  @override
  Map<String, Map<String, String>> get keys => localizedStrings;

  // Initialize the locale based on device language or stored preference
  static Future<void> initializeLocale() async {
    // Retrieve stored language preference, if any
    final savedLang = await storage.read(key: 'selectedLanguage');

    if (savedLang != null) {
      locale = getLocaleFromLanguage(savedLang);
    } else {
      // Detect device language
      final deviceLanguage = window.locale.languageCode;

      if (deviceLanguage == 'ar') {
        locale = Locale('ar', 'SA');
      } else {
        locale = Locale('en', 'US');
      }

      // Save the detected language as default
      await storage.write(
          key: 'selectedLanguage',
          value: locale!.languageCode == 'ar' ? 'العربية' : 'English');
    }

    Get.updateLocale(locale!);
  }

  static Locale getLocaleFromLanguage(String language) {
    switch (language) {
      case 'English':
        return Locale('en', 'US');
      case 'العربية':
        return Locale('ar', 'SA');
      default:
        return Locale('en', 'US'); // Default language
    }
  }

  static Future<void> changeLocale(String language) async {
    // Update the app's locale
    locale = getLocaleFromLanguage(language);
    Get.updateLocale(locale!);

    // Save the selected language to persistent storage
    await storage.write(key: 'selectedLanguage', value: language);
  }

  // Retrieve locale based on stored language
  static Future<void> loadStoredLocale() async {
    // Retrieve the stored language or default to English
    final savedLang = await storage.read(key: 'selectedLanguage') ?? 'English';
    locale = getLocaleFromLanguage(savedLang);

    // Update the app's locale
    Get.updateLocale(locale!);
  }

  static String getCurrentLanguage() {
    // This should return the current app language as a string
    Locale currentLocale = Get.locale ?? Locale('en', 'US');
    return currentLocale.languageCode == 'ar' ? 'العربية' : 'English';
  }

  // Helper to reorder language list with the current language on top
  static List<String> reorderLanguages() {
    String currentLang = getCurrentLanguage();
    List<String> reorderedLangs = List.from(langs);
    reorderedLangs.remove(currentLang);
    reorderedLangs.insert(0, currentLang);
    return reorderedLangs;
  }
}
