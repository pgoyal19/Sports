import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/athlete_avatar_screen.dart';
import 'screens/ar_test_setup_screen.dart';
import 'screens/record_test_screen.dart';
import 'screens/results_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/sai_dashboard_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/home_shell.dart';
import 'screens/phone_auth_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/language_settings_screen.dart';
import 'theme/app_theme.dart';
import 'providers/athlete_provider.dart';
import 'providers/gamification_provider.dart';
import 'providers/blockchain_provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/language_service.dart';
import 'widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await EasyLocalization.ensureInitialized();
  
  // API URLs will be auto-detected based on platform
  // ApiService.setBaseUrl('http://192.168.1.3:8000');
  // AuthService.setBaseUrl('http://192.168.1.3:8000');
  
  runApp(
    EasyLocalization(
      supportedLocales: LanguageService.supportedLocales,
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const GoChampApp(),
    ),
  );
}

class GoChampApp extends StatelessWidget {
  const GoChampApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AthleteProvider()),
        ChangeNotifierProvider(create: (_) => GamificationProvider()),
        ChangeNotifierProvider(create: (_) => BlockchainProvider()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
      ],
      child: MaterialApp(
        title: 'GoChamp',
        theme: AppTheme.theme(),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: const AuthWrapper(),
        routes: {
          '/': (context) => const AuthWrapper(),
          '/phone-auth': (context) => const PhoneAuthScreen(),
          '/otp-verification': (context) {
            final phoneNumber = ModalRoute.of(context)!.settings.arguments as String;
            return OTPVerificationScreen(phoneNumber: phoneNumber);
          },
          '/home': (context) => const HomeShell(),
          '/onboarding': (context) => OnboardingScreen(),
          '/login': (context) => LoginScreen(),
          '/avatar': (context) => AthleteAvatarScreen(),
          '/ar-setup': (context) => ARTestSetupScreen(),
          '/record': (context) => RecordTestScreen(),
          '/results': (context) => ResultsScreen(),
          '/leaderboard': (context) => LeaderboardScreen(),
          '/sai-dashboard': (context) => SAIDashboardScreen(),
          '/language-settings': (context) => const LanguageSettingsScreen(),
        },
      ),
    );
  }
}

