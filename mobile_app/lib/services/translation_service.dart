import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

class TranslationService {
  // Get translated text with fallback
  static String tr(String key, {Map<String, dynamic>? args}) {
    try {
      return key.tr(args: args);
    } catch (e) {
      // Return the key itself if translation fails
      return key;
    }
  }
  
  // Get translated text with plural support
  static String trPlural(String key, int count, {Map<String, dynamic>? args}) {
    try {
      return key.trPlural(count, args: args);
    } catch (e) {
      return key;
    }
  }
  
  // Get current locale
  static Locale getCurrentLocale(BuildContext context) {
    return context.locale;
  }
  
  // Check if current language is RTL
  static bool isRTL(BuildContext context) {
    return context.locale.languageCode == 'ar' || 
           context.locale.languageCode == 'he' ||
           context.locale.languageCode == 'fa';
  }
  
  // Get text direction
  static TextDirection getTextDirection(BuildContext context) {
    return isRTL(context) ? TextDirection.rtl : TextDirection.ltr;
  }
  
  // Format numbers based on locale
  static String formatNumber(BuildContext context, dynamic number) {
    final locale = getCurrentLocale(context);
    final formatter = NumberFormat.decimalPattern(locale.toString());
    return formatter.format(number);
  }
  
  // Format currency based on locale
  static String formatCurrency(BuildContext context, double amount, {String? symbol}) {
    final locale = getCurrentLocale(context);
    final formatter = NumberFormat.currency(
      locale: locale.toString(),
      symbol: symbol ?? '₹',
    );
    return formatter.format(amount);
  }
  
  // Format date based on locale
  static String formatDate(BuildContext context, DateTime date, {String? pattern}) {
    final locale = getCurrentLocale(context);
    final formatter = DateFormat(pattern ?? 'dd/MM/yyyy', locale.toString());
    return formatter.format(date);
  }
  
  // Format time based on locale
  static String formatTime(BuildContext context, DateTime time, {String? pattern}) {
    final locale = getCurrentLocale(context);
    final formatter = DateFormat(pattern ?? 'HH:mm', locale.toString());
    return formatter.format(time);
  }
  
  // Get localized text with context
  static String localizedText(BuildContext context, String key, {Map<String, dynamic>? args}) {
    return tr(key, args: args);
  }
  
  // Get localized text for specific language
  static String localizedTextForLanguage(String languageCode, String key, {Map<String, dynamic>? args}) {
    try {
      // This would need to be implemented based on your translation structure
      return key;
    } catch (e) {
      return key;
    }
  }
}
