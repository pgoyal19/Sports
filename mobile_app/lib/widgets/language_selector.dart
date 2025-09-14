import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';

class LanguageSelector extends StatelessWidget {
  final bool showAsDialog;
  final VoidCallback? onLanguageChanged;

  const LanguageSelector({
    super.key,
    this.showAsDialog = false,
    this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        if (showAsDialog) {
          return _buildLanguageDialog(context, languageService);
        } else {
          return _buildLanguageDropdown(context, languageService);
        }
      },
    );
  }

  Widget _buildLanguageDialog(BuildContext context, LanguageService languageService) {
    return AlertDialog(
      title: Text(
        'Select Language',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: LanguageService.supportedLocales.map((locale) {
          final isSelected = languageService.currentLocale == locale;
          return ListTile(
            leading: Text(
              LanguageService.languageFlags[locale.languageCode] ?? '🌐',
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(
              LanguageService.languageNames[locale.languageCode] ?? locale.languageCode,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
              ),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: AppTheme.primary,
                    size: 24,
                  )
                : null,
            onTap: () {
              languageService.changeLanguage(locale);
              Navigator.of(context).pop();
              onLanguageChanged?.call();
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown(BuildContext context, LanguageService languageService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Locale>(
          value: languageService.currentLocale,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppTheme.textSecondary,
          ),
          items: LanguageService.supportedLocales.map((locale) {
            return DropdownMenuItem<Locale>(
              value: locale,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LanguageService.languageFlags[locale.languageCode] ?? '🌐',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    LanguageService.languageNames[locale.languageCode] ?? locale.languageCode,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (Locale? newLocale) {
            if (newLocale != null) {
              languageService.changeLanguage(newLocale);
              onLanguageChanged?.call();
            }
          },
        ),
      ),
    );
  }
}

class LanguageSelectorButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const LanguageSelectorButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return IconButton(
          onPressed: onPressed ?? () => _showLanguageDialog(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              LanguageService.languageFlags[languageService.currentLanguageCode] ?? '🌐',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          tooltip: 'Change Language',
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LanguageSelector(showAsDialog: true),
    );
  }
}

class LanguageChip extends StatelessWidget {
  final Locale locale;
  final bool isSelected;
  final VoidCallback? onTap;

  const LanguageChip({
    super.key,
    required this.locale,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primary.withOpacity(0.1)
              : AppTheme.neutral100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppTheme.primary
                : AppTheme.neutral200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LanguageService.languageFlags[locale.languageCode] ?? '🌐',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              LanguageService.languageNames[locale.languageCode] ?? locale.languageCode,
              style: TextStyle(
                color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
