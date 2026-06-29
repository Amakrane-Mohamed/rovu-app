import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Crovu glassmorphism design system.
/// Frosted translucent surfaces over a deep aurora gradient — electric
/// cobalt → violet with a cyan spark. Anton for huge titles, Archivo for UI.
class AppColors {
  AppColors._();

  /// Aurora brand accents.
  static const Color primary = Color(0xFF5B8CFF); // electric cobalt
  static const Color primaryDark = Color(0xFF3D5FCC);
  static const Color violet = Color(0xFF9B6CFF);
  static const Color cyan = Color(0xFF3DE0FF);

  /// Compatibility aliases used across widgets.
  static const Color blue = cyan;
  static const Color blueDark = Color(0xFF1FA9CC);
  static const Color green = Color(0xFF3DDC97);
  static const Color greenDark = Color(0xFF2BA873);
  static const Color yellow = Color(0xFFFFC861);
  static const Color volt = cyan;

  /// Deep gradient base.
  static const Color bgTop = Color(0xFF141634);
  static const Color bgMid = Color(0xFF0C0D1E);
  static const Color bgBottom = Color(0xFF070710);
  static const Color background = bgBottom;

  /// Solid fallback surface (used where blur isn't available).
  static const Color surface = Color(0xFF16172C);

  /// Translucent glass layers (white over the gradient).
  static const Color glassFill = Color(0x14FFFFFF); // ~8%
  static const Color glassHigh = Color(0x1FFFFFFF); // ~12%
  static const Color glassStroke = Color(0x2EFFFFFF); // ~18%

  /// Aliases mapped onto glass tokens.
  static const Color surfaceAlt = glassFill;
  static const Color surfaceHigh = glassHigh;
  static const Color border = glassStroke;
  static const Color borderDark = Color(0x14000000);

  /// Text.
  static const Color textPrimary = Color(0xFFF4F5FF);
  static const Color textSecondary = Color(0xFFAEB0CC);
  static const Color textFaint = Color(0xFF6E7095);

  /// Accent tints.
  static const Color primaryTint = Color(0x265B8CFF);
  static const Color blueTint = Color(0x263DE0FF);
  static const Color greenTint = Color(0x263DDC97);
  static const Color voltTint = Color(0x263DE0FF);

  /// Signature aurora gradient.
  static const LinearGradient heat = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyan, primary, violet],
  );

  static const LinearGradient aurora = heat;
}

class AppRadii {
  AppRadii._();
  static const double sm = 14;
  static const double md = 18;
  static const double lg = 24;
  static const double xl = 32;
  static const double pill = 100;
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 6;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 34;
}

class AppMotion {
  AppMotion._();
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 420);
  static const Duration slow = Duration(milliseconds: 720);
  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve spring = Curves.easeOutBack;
}

class AppTheme {
  AppTheme._();

  /// Huge sport display — Anton, condensed. Use UPPERCASE.
  static TextStyle display(
    double size, {
    Color color = AppColors.textPrimary,
    double letterSpacing = 0.5,
    double height = 0.92,
  }) {
    return GoogleFonts.anton(
      fontSize: size,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle brand(double size, {Color color = AppColors.textPrimary}) {
    return GoogleFonts.anton(fontSize: size, color: color, letterSpacing: 1.0);
  }

  static TextStyle title(
    double size, {
    Color color = AppColors.textPrimary,
    FontWeight weight = FontWeight.w700,
  }) {
    return GoogleFonts.archivo(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.15,
      letterSpacing: -0.3,
    );
  }

  static TextStyle body(
    double size, {
    Color color = AppColors.textSecondary,
    FontWeight weight = FontWeight.w500,
  }) {
    return GoogleFonts.archivo(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle caption(
    double size, {
    Color color = AppColors.textSecondary,
    FontWeight weight = FontWeight.w700,
  }) {
    return GoogleFonts.archivo(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: 1.4,
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        surface: AppColors.surface,
      ).copyWith(primary: AppColors.primary),
      textTheme: GoogleFonts.archivoTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
