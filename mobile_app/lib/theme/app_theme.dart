import 'package:flutter/material.dart';

class AppTheme {
  // Enhanced Color Palette
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);
  static const Color accentDark = Color(0xFFD97706);
  
  // Surface Colors
  static const Color surface = Color(0xFFF8FAFC);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color surfaceContainer = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFF8FAFC);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Neutral Colors
  static const Color neutral50 = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Styles
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
  
  static const List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 30,
      offset: Offset(0, 12),
    ),
  ];

  static ThemeData theme() {
    final base = ThemeData.light();
    return base.copyWith(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        onPrimary: textOnPrimary,
        secondary: secondary,
        onSecondary: textOnSecondary,
        tertiary: accent,
        onTertiary: textOnPrimary,
        surface: surface,
        onSurface: textPrimary,
        surfaceContainer: surfaceContainer,
        onSurfaceVariant: textSecondary,
        error: error,
        onError: textOnPrimary,
        outline: neutral300,
        outlineVariant: neutral200,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: surfaceContainer,
        foregroundColor: textPrimary,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        hintStyle: const TextStyle(
          color: textTertiary,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textOnPrimary,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: primary, width: 1.5),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceContainer,
        selectedItemColor: primary,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceContainer,
        indicatorColor: primary.withOpacity(0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return const TextStyle(
            color: textTertiary,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          );
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: textOnPrimary,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: neutral100,
        selectedColor: primary.withOpacity(0.1),
        labelStyle: const TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide.none,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
        fontFamily: 'Inter',
      ).copyWith(
        displayLarge: const TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.25,
          color: textPrimary,
        ),
        displayMedium: const TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          color: textPrimary,
        ),
        displaySmall: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: textPrimary,
        ),
        headlineLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          color: textPrimary,
        ),
        headlineMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: textPrimary,
        ),
        headlineSmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: textPrimary,
        ),
        titleLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: textPrimary,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          color: textPrimary,
        ),
        titleSmall: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: textPrimary,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: textPrimary,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: textSecondary,
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: textTertiary,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: textPrimary,
        ),
        labelMedium: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: textSecondary,
        ),
        labelSmall: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: textTertiary,
        ),
      ),
    );
  }
}


