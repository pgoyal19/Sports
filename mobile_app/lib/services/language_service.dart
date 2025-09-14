import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('en', 'US');
  
  Locale get currentLocale => _currentLocale;
  
  String get currentLanguageCode => _currentLocale.languageCode;
  
  // Supported languages
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('hi', 'IN'), // Hindi
    Locale('bn', 'BD'), // Bengali
    Locale('ta', 'IN'), // Tamil
  ];
  
  // Language names for display
  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'हिन्दी',
    'bn': 'বাংলা',
    'ta': 'தமிழ்',
  };
  
  // Language flags for display
  static const Map<String, String> languageFlags = {
    'en': '🇺🇸',
    'hi': '🇮🇳',
    'bn': '🇧🇩',
    'ta': '🇮🇳',
  };
  
  LanguageService() {
    _loadSavedLanguage();
  }
  
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString(_languageKey);
      
      if (savedLanguageCode != null) {
        final savedLocale = supportedLocales.firstWhere(
          (locale) => locale.languageCode == savedLanguageCode,
          orElse: () => const Locale('en', 'US'),
        );
        _currentLocale = savedLocale;
        notifyListeners();
      }
    } catch (e) {
      // If loading fails, use default language
      _currentLocale = const Locale('en', 'US');
    }
  }
  
  Future<void> changeLanguage(Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      return;
    }
    
    _currentLocale = locale;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
    } catch (e) {
      // If saving fails, continue with the language change
      debugPrint('Failed to save language preference: $e');
    }
  }
  
  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode.toUpperCase();
  }
  
  String getLanguageFlag(String languageCode) {
    return languageFlags[languageCode] ?? '🌐';
  }
  
  bool isRTL() {
    // Add RTL languages here if needed
    return false;
  }
  
  TextDirection get textDirection {
    return isRTL() ? TextDirection.rtl : TextDirection.ltr;
  }
}
