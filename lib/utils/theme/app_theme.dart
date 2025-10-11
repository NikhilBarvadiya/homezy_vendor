import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlack = Color(0xFF000000);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color secondaryBlack = Color(0xFF1A1A1A);
  static const Color secondaryWhite = Color(0xFFF5F5F5);
  static const Color accentGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color darkGray = Color(0xFF333333);
  static const Color mediumGray = Color(0xFF999999);
  static const Color dividerLight = Color(0xFFEEEEEE);
  static const Color dividerDark = Color(0xFF444444);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryBlack,
      onPrimary: primaryWhite,
      primaryContainer: primaryBlack,
      onPrimaryContainer: primaryWhite,
      secondary: darkGray,
      onSecondary: primaryWhite,
      secondaryContainer: lightGray,
      onSecondaryContainer: primaryBlack,
      surface: primaryWhite,
      onSurface: primaryBlack,
      surfaceVariant: secondaryWhite,
      onSurfaceVariant: darkGray,
      background: primaryWhite,
      onBackground: primaryBlack,
      error: Color(0xFFBA1A1A),
      onError: primaryWhite,
      outline: lightGray,
      outlineVariant: dividerLight,
    ),
    scaffoldBackgroundColor: primaryWhite,
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: primaryBlack, height: 1.2),
      displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: primaryBlack, height: 1.2),
      displaySmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: primaryBlack, height: 1.3),
      headlineLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: primaryBlack, height: 1.3),
      headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: primaryBlack, height: 1.3),
      headlineSmall: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: primaryBlack, height: 1.4),
      titleLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: primaryBlack, height: 1.4),
      titleMedium: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: primaryBlack, height: 1.4),
      titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: primaryBlack, height: 1.4),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal, color: darkGray, height: 1.5),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, color: darkGray, height: 1.5),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal, color: mediumGray, height: 1.5),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: primaryBlack, height: 1.4),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: darkGray, height: 1.4),
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: mediumGray, height: 1.4),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: primaryWhite,
      foregroundColor: primaryBlack,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: primaryBlack),
      iconTheme: const IconThemeData(color: primaryBlack, size: 24),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: primaryWhite,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: primaryWhite,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: dividerLight, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlack,
        foregroundColor: primaryWhite,
        disabledBackgroundColor: mediumGray,
        disabledForegroundColor: primaryWhite,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryBlack,
        side: const BorderSide(color: primaryBlack, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBlack,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: primaryWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightGray, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightGray, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryBlack, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 2),
      ),
      labelStyle: GoogleFonts.inter(fontSize: 14, color: mediumGray, fontWeight: FontWeight.w500),
      hintStyle: GoogleFonts.inter(fontSize: 14, color: mediumGray),
      errorStyle: GoogleFonts.inter(fontSize: 12, color: Color(0xFFBA1A1A)),
    ),
    iconTheme: const IconThemeData(color: darkGray, size: 24),
    dividerTheme: const DividerThemeData(color: dividerLight, thickness: 1, space: 1),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: primaryWhite,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: primaryWhite,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: primaryBlack),
      contentTextStyle: GoogleFonts.inter(fontSize: 14, color: darkGray),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: lightGray,
      disabledColor: mediumGray.withOpacity(0.12),
      selectedColor: primaryBlack,
      secondarySelectedColor: primaryBlack,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: darkGray),
      secondaryLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: primaryWhite),
      brightness: Brightness.light,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: primaryWhite,
      selectedItemColor: primaryBlack,
      unselectedItemColor: mediumGray,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryWhite,
      onPrimary: primaryBlack,
      primaryContainer: primaryWhite,
      onPrimaryContainer: primaryBlack,
      secondary: lightGray,
      onSecondary: primaryBlack,
      secondaryContainer: darkGray,
      onSecondaryContainer: primaryWhite,
      surface: secondaryBlack,
      onSurface: primaryWhite,
      surfaceVariant: darkGray,
      onSurfaceVariant: lightGray,
      background: secondaryBlack,
      onBackground: primaryWhite,
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      outline: dividerDark,
      outlineVariant: darkGray,
    ),
    scaffoldBackgroundColor: secondaryBlack,
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: primaryWhite, height: 1.2),
      displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: primaryWhite, height: 1.2),
      displaySmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: primaryWhite, height: 1.3),
      headlineLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: primaryWhite, height: 1.3),
      headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: primaryWhite, height: 1.3),
      headlineSmall: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: primaryWhite, height: 1.4),
      titleLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: primaryWhite, height: 1.4),
      titleMedium: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: primaryWhite, height: 1.4),
      titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: primaryWhite, height: 1.4),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal, color: lightGray, height: 1.5),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, color: lightGray, height: 1.5),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal, color: mediumGray, height: 1.5),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: primaryWhite, height: 1.4),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: lightGray, height: 1.4),
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: mediumGray, height: 1.4),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: secondaryBlack,
      foregroundColor: primaryWhite,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: primaryWhite),
      iconTheme: const IconThemeData(color: primaryWhite, size: 24),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: secondaryBlack,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: darkGray,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: dividerDark, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryWhite,
        foregroundColor: primaryBlack,
        disabledBackgroundColor: mediumGray,
        disabledForegroundColor: primaryBlack,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryWhite,
        side: const BorderSide(color: primaryWhite, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryWhite,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkGray,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerDark, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerDark, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryWhite, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFFB4AB), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFFB4AB), width: 2),
      ),
      labelStyle: GoogleFonts.inter(fontSize: 14, color: mediumGray, fontWeight: FontWeight.w500),
      hintStyle: GoogleFonts.inter(fontSize: 14, color: mediumGray),
      errorStyle: GoogleFonts.inter(fontSize: 12, color: Color(0xFFFFB4AB)),
    ),
    iconTheme: const IconThemeData(color: lightGray, size: 24),
    dividerTheme: const DividerThemeData(color: dividerDark, thickness: 1, space: 1),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: darkGray,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: darkGray,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: primaryWhite),
      contentTextStyle: GoogleFonts.inter(fontSize: 14, color: lightGray),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: dividerDark,
      disabledColor: mediumGray.withOpacity(0.12),
      selectedColor: primaryWhite,
      secondarySelectedColor: primaryWhite,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: lightGray),
      secondaryLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: primaryBlack),
      brightness: Brightness.dark,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: secondaryBlack,
      selectedItemColor: primaryWhite,
      unselectedItemColor: mediumGray,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
