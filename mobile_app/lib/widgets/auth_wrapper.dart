import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/phone_auth_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/home_shell.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Simulate checking authentication status
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isCheckingAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const SplashScreen();
    }

    if (AuthService.isAuthenticated) {
      // User is authenticated, show the main app
      return const HomeShell();
    } else {
      // User is not authenticated, show phone auth screen
      return const PhoneAuthScreen();
    }
  }
}

