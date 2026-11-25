import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta e estilos do KryptoVault: preto + branco, alto contraste,
/// equivalentes às variáveis do index.css do projeto web.
class KV {
  KV._();

  static const Color black = Color(0xFF000000);
  static const Color panel = Color(0xFF050505);
  static const Color border = Color(0xFF555555);
  static const Color borderSoft = Color(0xFF444444);
  static const Color inputBorder = Color(0xFF666666);
  static const Color muted = Color(0xFFBDBDBD);
  static const Color gray = Color(0xFFA8A8A8);
  static const Color dim = Color(0xFF858585);
  static const Color noticeBg = Color(0xFF1B1A16);
  static const Color noticeBorder = Color(0xFF39352A);
  static const Color success = Color(0xFFB8E7C4);

  /// DM Sans — texto geral.
  static TextStyle body({
    double size = 15,
    Color color = Colors.white,
    FontWeight weight = FontWeight.w400,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.dmSans(
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// Space Grotesk — títulos e marca.
  static TextStyle grotesk({
    double size = 18,
    Color color = Colors.white,
    FontWeight weight = FontWeight.w600,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// IBM Plex Mono — detalhes "técnicos" (eyebrows, botões, números).
  static TextStyle mono({
    double size = 12,
    Color color = Colors.white,
    FontWeight weight = FontWeight.w400,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.ibmPlexMono(
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
      );
}

class KvTheme {
  KvTheme._();

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: KV.black,
      canvasColor: KV.black,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        onPrimary: Colors.black,
        secondary: Colors.white,
        onSecondary: Colors.black,
        surface: KV.black,
        onSurface: Colors.white,
        error: Colors.white,
        onError: Colors.black,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: Color(0x55FFFFFF),
        selectionHandleColor: Colors.white,
      ),
    );
  }
}
