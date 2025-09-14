# Testing Multi-Language Feature

## Quick Test Steps

### 1. Run the App
```bash
cd mobile_app
flutter run
```

### 2. Test Language Switching

#### Method 1: From Phone Auth Screen
1. Open the app
2. You'll see the phone authentication screen
3. Look for the language selector button (🌐) in the top-right corner
4. Tap it to open the language selection dialog
5. Select different languages and see the text change

#### Method 2: From Profile Menu (After Login)
1. Complete the phone authentication process
2. Go to the home screen
3. Tap the profile icon in the top-right corner
4. Select "Language" from the menu
5. Choose your preferred language
6. Navigate through different screens to see the translations

### 3. Test Different Screens

Navigate through these screens to see translations:
- Phone Authentication Screen
- OTP Verification Screen
- Home Screen
- Test Setup Screen
- Results Screen
- Leaderboard Screen
- Profile Screen

### 4. Test Language Persistence

1. Select a language (e.g., Hindi)
2. Close the app completely
3. Reopen the app
4. Verify that the selected language is still active

## Expected Behavior

### English (Default)
- All text should be in English
- App name: "GoChamp"
- Welcome message: "Welcome to GoChamp"

### Hindi
- All text should be in Hindi
- App name: "गोचैंप"
- Welcome message: "गोचैंप में आपका स्वागत है"

### Bengali
- All text should be in Bengali
- App name: "গোচ্যাম্প"
- Welcome message: "গোচ্যাম্পে স্বাগতম"

### Tamil
- All text should be in Tamil
- App name: "கோசாம்ப்"
- Welcome message: "கோசாம்ப்-க்கு வரவேற்கிறோம்"

## Troubleshooting

### If translations don't appear:
1. Check that the translation files are in `assets/translations/`
2. Verify that `pubspec.yaml` includes the assets section
3. Run `flutter clean` and `flutter pub get`
4. Restart the app

### If language doesn't persist:
1. Check that `SharedPreferences` is working
2. Verify that the language service is properly initialized
3. Check for any error messages in the console

### If some text is not translated:
1. Check if the translation key exists in all language files
2. Verify that the key is being used correctly (e.g., `'key'.tr()`)
3. Make sure the key follows the nested structure (e.g., `'auth.welcome'`)

## Adding New Translations

To add a new translation:

1. Add the key to `assets/translations/en.json`:
```json
{
  "new_section": {
    "new_key": "English text"
  }
}
```

2. Add the same key to all other language files with appropriate translations

3. Use it in your widget:
```dart
Text('new_section.new_key'.tr())
```

## Performance Notes

- Language switching is instant
- No performance impact on app functionality
- Translation files are loaded once at startup
- Memory usage is minimal

## Accessibility Features

- Language selector is easily accessible
- Visual indicators show current language
- Consistent UI across all languages
- RTL support ready for future languages
