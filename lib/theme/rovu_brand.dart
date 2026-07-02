import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ROVU sport brand — red base, volt accent, Kanit display + Archivo UI.
/// Shared across onboarding, questionnaire, and the main app shell.
class RovuBrand {
  RovuBrand._();

  static const Color red = Color(0xFFEC3407);
  static const Color volt = Color(0xFFE2FF3D);
  static const Color ink = Colors.black;

  static TextStyle display(
    double size, {
    Color color = Colors.white,
    double height = 0.92,
    double letterSpacing = -1.2,
  }) {
    return GoogleFonts.kanit(
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.italic,
      color: color,
      fontSize: size,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle navTitle({Color color = Colors.white}) {
    return GoogleFonts.kanit(
      fontWeight: FontWeight.w800,
      fontStyle: FontStyle.italic,
      color: color,
      fontSize: 18,
      letterSpacing: 0.2,
    );
  }

  static TextStyle caption(
    double size, {
    Color color = Colors.white,
    double letterSpacing = 1.4,
  }) {
    return GoogleFonts.archivo(
      color: color,
      fontWeight: FontWeight.w800,
      fontSize: size,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle body(
    double size, {
    Color color = Colors.white,
    FontWeight weight = FontWeight.w500,
  }) {
    return GoogleFonts.archivo(
      color: color,
      fontWeight: weight,
      fontSize: size,
      height: 1.4,
    );
  }
}

/// Breathing glow blobs behind content — same depth as the questionnaire.
class RovuAmbientGlow extends StatefulWidget {
  const RovuAmbientGlow({super.key});

  @override
  State<RovuAmbientGlow> createState() => _RovuAmbientGlowState();
}

class _RovuAmbientGlowState extends State<RovuAmbientGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final v = _controller.value;
        return Stack(
          children: [
            Positioned(
              top: -140 + 40 * v,
              right: -90,
              child: _blob(
                280,
                RovuBrand.volt.withValues(alpha: 0.16 + 0.08 * v),
              ),
            ),
            Positioned(
              bottom: -120 - 30 * v,
              left: -110,
              child: _blob(340, RovuBrand.ink.withValues(alpha: 0.22)),
            ),
            Positioned(
              top: 240 + 30 * (1 - v),
              left: -70,
              child: _blob(200, Colors.white.withValues(alpha: 0.05)),
            ),
          ],
        );
      },
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
