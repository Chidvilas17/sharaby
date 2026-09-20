import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._();
  ThemeController._();

  ThemeMode _themeMode = ThemeMode.light; // Default to Light Mode
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void setLocale(Locale newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      notifyListeners();
    }
  }
}

class AppTheme {
  // Light Palette
  static const Color primaryColor = Color(0xFF0284C7);
  static const Color secondaryColor = Color(0xFF0EA5E9);
  static const Color accentCyan = Color(0xFF38BDF8);
  static const Color backgroundColor = Color(0xFFF0F9FF);
  static const Color surfaceColor = Colors.white;
  static const Color textColor = Color(0xFF0F172A);
  static const Color mutedTextColor = Color(0xFF64748B);
  static const Color borderCyan = Color(0x330EA5E9);

  // Dark Palette - Deep Royal Blue Glassmorphism
  static const Color darkBackgroundColor = Color(0xFF0B132B);
  static const Color darkSurfaceColor = Color(0xFF1C2541);
  static const Color darkCardColor = Color(0xFF1E293B);
  static const Color darkElectricCyan = Color(0xFF00B4D8);
  static const Color darkPrimaryColor = Color(0xFF0284C7);
  static const Color darkTextColor = Color(0xFFF8FAFC);
  static const Color darkMutedTextColor = Color(0xFF94A3B8);
  static const Color darkBorderCyan = Color(0x6600B4D8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 3,
        shadowColor: const Color(0x260EA5E9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderCyan, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: mutedTextColor),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: const Color(0x330284C7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: accentCyan, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
        elevation: 1,
        shadowColor: Color(0x1A0EA5E9),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFE0F2FE)),
        headingTextStyle: const TextStyle(
          color: Color(0xFF0369A1),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        dataRowColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? const Color(0xFFBAE6FD)
              : surfaceColor,
        ),
        dividerThickness: 1,
        horizontalMargin: 16,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFFF8FAFC),
        elevation: 4,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        shadowColor: const Color(0x330EA5E9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: darkElectricCyan,
        secondary: darkPrimaryColor,
        surface: darkSurfaceColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextColor,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      cardTheme: CardThemeData(
        color: darkSurfaceColor,
        elevation: 4,
        shadowColor: const Color(0x4000B4D8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorderCyan, width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF475569)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkElectricCyan, width: 2),
        ),
        labelStyle: const TextStyle(color: darkMutedTextColor),
        hintStyle: const TextStyle(color: Color(0xFF64748B)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0x4000B4D8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkElectricCyan,
          side: const BorderSide(color: darkElectricCyan, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkElectricCyan,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackgroundColor,
        foregroundColor: darkTextColor,
        elevation: 2,
        shadowColor: Color(0x4000B4D8),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(const Color(0xFF172A45)),
        headingTextStyle: const TextStyle(
          color: darkElectricCyan,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        dataRowColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? const Color(0xFF1E3A8A)
              : darkSurfaceColor,
        ),
        dividerThickness: 1,
        horizontalMargin: 16,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF0D1B2A),
        elevation: 6,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurfaceColor,
        elevation: 10,
        shadowColor: const Color(0x4000B4D8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
