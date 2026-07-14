import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Centralized color palette — light mode.
///
/// Field names are kept stable on purpose: several screens reference
/// `AppColors.xxx` directly (not via `Theme.of(context)`), so this class
/// is effectively part of the app's public API.
class AppColors {
  static const Color primary = Color(0xFF1D4ED8); // deep blue
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color accent = Color(0xFF16A34A); // pos green, slightly deeper
  static const Color background = Color(0xFFFFFFFF); // pure white
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF8FAFC); // subtle off-white for inputs/fills
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color shadow = Color(0x1A0F172A); // low-opacity navy shadow
}

/// Centralized color palette — dark mode.
class AppColorsDark {
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color accent = Color(0xFF4ADE80);
  static const Color background = Color(0xFF121318);
  static const Color surface = Color(0xFF1E2028);
  static const Color surfaceVariant = Color(0xFF262933);
  static const Color textPrimary = Color(0xFFE5E7EB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color border = Color(0xFF2E313C);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);
  static const Color shadow = Color(0x40000000);
}

/// Small internal bundle so the light/dark themes can share a single
/// builder instead of duplicating every ThemeData property twice.
class _Palette {
  final Brightness brightness;
  final Color primary;
  final Color primaryDark;
  final Color accent;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color error;
  final Color shadow;

  const _Palette({
    required this.brightness,
    required this.primary,
    required this.primaryDark,
    required this.accent,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.error,
    required this.shadow,
  });

  static const light = _Palette(
    brightness: Brightness.light,
    primary: AppColors.primary,
    primaryDark: AppColors.primaryDark,
    accent: AppColors.accent,
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceVariant: AppColors.surfaceVariant,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    border: AppColors.border,
    error: AppColors.error,
    shadow: AppColors.shadow,
  );

  static const dark = _Palette(
    brightness: Brightness.dark,
    primary: AppColorsDark.primary,
    primaryDark: AppColorsDark.primaryDark,
    accent: AppColorsDark.accent,
    background: AppColorsDark.background,
    surface: AppColorsDark.surface,
    surfaceVariant: AppColorsDark.surfaceVariant,
    textPrimary: AppColorsDark.textPrimary,
    textSecondary: AppColorsDark.textSecondary,
    border: AppColorsDark.border,
    error: AppColorsDark.error,
    shadow: AppColorsDark.shadow,
  );
}

class AppTheme {
  static ThemeData get lightTheme => _build(_Palette.light);
  static ThemeData get darkTheme => _build(_Palette.dark);

  static ThemeData _build(_Palette c) {
    final textTheme = _textTheme(c);

    return ThemeData(
      useMaterial3: true,
      brightness: c.brightness,
      scaffoldBackgroundColor: c.background,
      splashFactory: InkRipple.splashFactory,
      fontFamily: 'Roboto',

      // fromSeed() defaults to tinting elevated surfaces with the seed
      // color, which is what makes white cards/app bars look slightly
      // purple/off-white instead of clean white. surfaceTint: transparent
      // keeps surfaces genuinely white regardless of elevation.
      colorScheme: ColorScheme.fromSeed(
        seedColor: c.primary,
        brightness: c.brightness,
        primary: c.primary,
        secondary: c.accent,
        error: c.error,
        surface: c.surface,
        surfaceTint: Colors.transparent,
      ),

      textTheme: textTheme,

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: c.shadow,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: c.textPrimary),
      ),

      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: c.shadow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.border, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: c.textSecondary, fontSize: 14),
        labelStyle: TextStyle(color: c.textSecondary, fontSize: 14),
        floatingLabelStyle: TextStyle(color: c.primary, fontSize: 14, fontWeight: FontWeight.w600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.error, width: 1.6),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: c.primary.withValues(alpha: 0.4),
          minimumSize: const Size.fromHeight(52),
          elevation: 1,
          shadowColor: c.primary.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.pressed)
                ? Colors.white.withValues(alpha: 0.12)
                : null,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: c.border, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        extendedTextStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      iconTheme: IconThemeData(color: c.textSecondary, size: 22),

      dividerTheme: DividerThemeData(
        color: c.border,
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: c.textSecondary,
        textColor: c.textPrimary,
        tileColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceVariant,
        selectedColor: c.primary.withValues(alpha: 0.14),
        labelStyle: TextStyle(color: c.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
        side: BorderSide(color: c.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.textPrimary,
        contentTextStyle: TextStyle(color: c.surface, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actionTextColor: c.accent,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: c.shadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surface,
        selectedItemColor: c.primary,
        unselectedItemColor: c.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: c.primary,
        unselectedLabelColor: c.textSecondary,
        indicatorColor: c.primary,
        dividerColor: c.border,
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected) ? c.primary : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: BorderSide(color: c.border, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected) ? c.primary : c.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
              ? c.primary.withValues(alpha: 0.35)
              : c.border,
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected) ? c.primary : c.textSecondary,
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.border,
        circularTrackColor: c.border,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.textPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(color: c.surface, fontSize: 12),
      ),

      cardColor: c.surface,
      dividerColor: c.border,
      shadowColor: c.shadow,
    );
  }

  static TextTheme _textTheme(_Palette c) {
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: c.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.3, color: c.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.2, color: c.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600, color: c.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, color: c.textPrimary, height: 1.4,
      ),
      bodyMedium: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w400, color: c.textSecondary, height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: 12.5, fontWeight: FontWeight.w400, color: c.textSecondary, height: 1.3,
      ),
      labelLarge: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2, color: c.textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.2, color: c.textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.3, color: c.textSecondary,
      ),
    );
  }
}