import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_selector.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'common.language'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.surfaceContainer,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'common.select_language'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'common.language_description'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Language options
                ...LanguageService.supportedLocales.map((locale) {
                  final isSelected = languageService.currentLocale == locale;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          languageService.changeLanguage(locale);
                          context.setLocale(locale);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppTheme.primary.withOpacity(0.1)
                                : AppTheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected 
                                  ? AppTheme.primary
                                  : AppTheme.neutral200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Flag
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppTheme.primary.withOpacity(0.1)
                                      : AppTheme.neutral100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    LanguageService.languageFlags[locale.languageCode] ?? '🌐',
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Language name
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      LanguageService.languageNames[locale.languageCode] ?? locale.languageCode,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getLanguageDescription(locale.languageCode),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Selection indicator
                              if (isSelected)
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: AppTheme.textOnPrimary,
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 32),

                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.info.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.info,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'common.language_info'.tr(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.info,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getLanguageDescription(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English - Default language';
      case 'hi':
        return 'हिन्दी - भारत की राष्ट्रीय भाषा';
      case 'bn':
        return 'বাংলা - পশ্চিমবঙ্গ ও বাংলাদেশের ভাষা';
      case 'ta':
        return 'தமிழ் - தமிழ்நாட்டின் மொழி';
      default:
        return 'Local language support';
    }
  }
}
