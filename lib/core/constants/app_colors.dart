import 'package:flutter/material.dart';
import 'dart:math' as math;

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0A84FF);
  static const Color primaryDark = Color(0xFF0056CC);
  static const Color primaryLight = Color(0xFF5AC8FA);
  static const Color primaryUltraLight = Color(0xFFE8F4FD);

  static const Color secondary = Color(0xFF5856D6);
  static const Color secondaryDark = Color(0xFF3634A3);
  static const Color secondaryLight = Color(0xFF8E8CD8);
  static const Color secondaryUltraLight = Color(0xFFF2F2F7);

  static const Color success = Color(0xFF30D158);
  static const Color successDark = Color(0xFF248A3D);
  static const Color successLight = Color(0xFF7DE68F);
  static const Color successGlow = Color(0xFF4ADE80);

  static const Color danger = Color(0xFFFF453A);
  static const Color dangerDark = Color(0xFFD70015);
  static const Color dangerLight = Color(0xFFFF8A80);
  static const Color dangerGlow = Color(0xFFEF4444);

  static const Color warning = Color(0xFFFF9F0A);
  static const Color warningDark = Color(0xFFD48806);
  static const Color warningLight = Color(0xFFFFCC47);
  static const Color warningGlow = Color(0xFFF59E0B);

  static const Color info = Color(0xFF007AFF);
  static const Color infoDark = Color(0xFF0051D5);
  static const Color infoLight = Color(0xFF40A9FF);

  static const Color backgroundLight = Color(0xFFFFFBFE);
  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color backgroundUltraDark = Color(0xFF010409);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF21262D);
  static const Color surfaceElevated = Color(0xFFF8F9FA);
  static const Color surfaceGlass = Color(0x0DFFFFFF);

  static const Color textPrimary = Color(0xFF1C1E21);
  static const Color textSecondary = Color(0xFF65676B);
  static const Color textTertiary = Color(0xFFB0B3B8);
  static const Color textDisabled = Color(0xFFE4E6EA);
  static const Color textInverse = Color(0xFFFFFFFF);

  static const Color neonPink = Color(0xFFFF006E);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonBlue = Color(0xFF1B03A3);
  static const Color neonYellow = Color(0xFFFFFF00);
  static const Color neonPurple = Color(0xFFBF00FF);

  static const Color pastelPink = Color(0xFFFFB3D9);
  static const Color pastelBlue = Color(0xFFB3E0FF);
  static const Color pastelGreen = Color(0xFFB3FFB3);
  static const Color pastelPurple = Color(0xFFE0B3FF);
  static const Color pastelYellow = Color(0xFFFFFFB3);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF10B981)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [
      Color(0xFFFF6B6B),
      Color(0xFFFFE66D),
      Color(0xFF4ECDC4),
      Color(0xFF45B7D1)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient fireGradient = LinearGradient(
    colors: [
      Color(0xFFFF9A56),
      Color(0xFFFF6347),
      Color(0xFFFF1744),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient galaxyGradient = LinearGradient(
    colors: [
      Color(0xFF2C1810),
      Color(0xFF5B2C87),
      Color(0xFF9D4EDD),
      Color(0xFFE0AAFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonGradient = LinearGradient(
    colors: [neonPink, neonBlue, neonGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient auroraGradient = LinearGradient(
    colors: [
      Color(0xFF00C9FF),
      Color(0xFF92FE9D),
      Color(0xFFFF6B6B),
      Color(0xFFFFE66D),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  static const LinearGradient glassWhite = LinearGradient(
    colors: [Color(0x40FFFFFF), Color(0x10FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassBlack = LinearGradient(
    colors: [Color(0x40000000), Color(0x10000000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassColor = LinearGradient(
    colors: [Color(0x400A84FF), Color(0x100A84FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x66000000);

  static const Color shadowBlue = Color(0x330A84FF);
  static const Color shadowPurple = Color(0x335856D6);
  static const Color shadowGreen = Color(0x3330D158);
  static const Color shadowRed = Color(0x33FF453A);

  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity.clamp(0.0, 1.0));
  }

  static Color blendColors(Color color1, Color color2, double ratio) {
    return Color.lerp(color1, color2, ratio.clamp(0.0, 1.0)) ?? color1;
  }

  static Color randomBeautifulColor() {
    final colors = [
      primary, secondary, success, warning, danger,
      neonPink, neonBlue, neonGreen, neonPurple,
      pastelPink, pastelBlue, pastelGreen, pastelPurple,
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  static LinearGradient randomGradient() {
    final gradients = [
      primaryGradient, successGradient, sunsetGradient,
      oceanGradient, fireGradient, galaxyGradient,
      neonGradient, auroraGradient,
    ];
    return gradients[math.Random().nextInt(gradients.length)];
  }

  static Color getThemeColor(bool isDark) {
    return isDark ? surfaceDark : surfaceLight;
  }

  static Color getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textPrimary : textInverse;
  }

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  static const lightTheme = ColorScheme.light(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: textInverse,
    secondary: secondary,
    onSecondary: textInverse,
    surface: surfaceLight,
    onSurface: textPrimary,
    background: backgroundLight,
    onBackground: textPrimary,
    error: danger,
    onError: textInverse,
  );

  static const darkTheme = ColorScheme.dark(
    brightness: Brightness.dark,
    primary: primaryLight,
    onPrimary: textPrimary,
    secondary: secondaryLight,
    onSecondary: textPrimary,
    surface: surfaceDark,
    onSurface: textInverse,
    background: backgroundDark,
    onBackground: textInverse,
    error: dangerLight,
    onError: textPrimary,
  );

  static Color adjustBrightness(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final adjustedHsl = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return adjustedHsl.toColor();
  }

  static Color adjustSaturation(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final adjustedHsl = hsl.withSaturation(
      (hsl.saturation + amount).clamp(0.0, 1.0),
    );
    return adjustedHsl.toColor();
  }

  static Color complementaryColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    final complementary = hsl.withHue((hsl.hue + 180) % 360);
    return complementary.toColor();
  }

  static List<Color> analogousColors(Color color, {int count = 3}) {
    final hsl = HSLColor.fromColor(color);
    List<Color> colors = [];
    final step = 30.0;

    for (int i = 0; i < count; i++) {
      final hue = (hsl.hue + (i * step)) % 360;
      colors.add(hsl.withHue(hue).toColor());
    }

    return colors;
  }

  static List<Color> triadicColors(Color color) {
    final hsl = HSLColor.fromColor(color);
    return [
      color,
      hsl.withHue((hsl.hue + 120) % 360).toColor(),
      hsl.withHue((hsl.hue + 240) % 360).toColor(),
    ];
  }

  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static LinearGradient createGradient({
    required Color startColor,
    required Color endColor,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: [startColor, endColor],
      begin: begin,
      end: end,
    );
  }

  static LinearGradient createMultiColorGradient({
    required List<Color> colors,
    List<double>? stops,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: colors,
      stops: stops,
      begin: begin,
      end: end,
    );
  }

  static Color getColorFromPercentage(double percentage) {
    if (percentage < 0.25) return danger;
    if (percentage < 0.5) return warning;
    if (percentage < 0.75) return info;
    return success;
  }

  static BoxShadow createShadow(Color color, {double blur = 8, double spread = 0}) {
    return BoxShadow(
      color: color.withOpacity(0.3),
      blurRadius: blur,
      spreadRadius: spread,
      offset: const Offset(0, 2),
    );
  }

  static List<BoxShadow> createMultipleShadows(Color color) {
    return [
      BoxShadow(
        color: color.withOpacity(0.1),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
      BoxShadow(
        color: color.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static Color getHoverColor(Color color) {
    return adjustBrightness(color, -0.1);
  }

  static Color getPressedColor(Color color) {
    return adjustBrightness(color, -0.2);
  }

  static Color getDisabledColor(Color color) {
    return color.withOpacity(0.5);
  }
}