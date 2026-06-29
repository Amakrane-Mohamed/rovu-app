import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// The Crovu aha moment: show real-feeling runs before asking questions.
class RunsNearYouScreen extends StatefulWidget {
  const RunsNearYouScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  State<RunsNearYouScreen> createState() => _RunsNearYouScreenState();
}

class _RunsNearYouScreenState extends State<RunsNearYouScreen>
    with TickerProviderStateMixin {
  static const Color _red = Color(0xFFEC3407);
  static const Color _ink = Colors.black;
  static const Color _volt = Color(0xFFE2FF3D);

  late final AnimationController _entrance;
  late final AnimationController _pulse;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Widget _reveal({
    required double start,
    required double end,
    required Widget child,
  }) {
    final anim = CurvedAnimation(
      parent: _entrance,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (context, c) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, 26 * (1 - anim.value)),
          child: c,
        ),
      ),
      child: child,
    );
  }

  void _continue() {
    HapticFeedback.lightImpact();
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _red,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) => CustomPaint(
              painter: _RouteAccentPainter(_pulse.value),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  _reveal(
                    start: 0.12,
                    end: 0.58,
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'RUNS NEAR\nYOU TODAY.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.kanit(
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              fontSize: 46,
                              height: 0.94,
                              letterSpacing: -1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _LivePill(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _reveal(
                    start: 0.24,
                    end: 0.68,
                    child: Text(
                      'Clubs near you are heading out. Pick your pace and meet them at the start line.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.archivo(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _reveal(
                    start: 0.34,
                    end: 0.84,
                    child: const _RunsStack(),
                  ),
                  const Spacer(flex: 3),
                  _reveal(
                    start: 0.52,
                    end: 1,
                    child: Listener(
                      onPointerDown: (_) => setState(() => _pressed = true),
                      onPointerUp: (_) => setState(() => _pressed = false),
                      onPointerCancel: (_) => setState(() => _pressed = false),
                      child: AnimatedScale(
                        scale: _pressed ? 0.97 : 1,
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOut,
                        child: Container(
                          height: 66,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: _volt.withValues(alpha: 0.36),
                                blurRadius: 30,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _continue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _volt,
                              foregroundColor: _ink,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: Text(
                              'Find My Run',
                              style: GoogleFonts.kanit(
                                fontWeight: FontWeight.w800,
                                fontStyle: FontStyle.italic,
                                fontSize: 22,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill();

  static const Color _ink = Colors.black;
  static const Color _volt = Color(0xFFE2FF3D);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: _volt,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: _volt.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        '3 RUNS · 41 RUNNERS ACTIVE',
        style: GoogleFonts.archivo(
          color: _ink,
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _RunsStack extends StatelessWidget {
  const _RunsStack();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _RunCard(
          club: 'City Runners Club',
          title: 'Easy 5K Social',
          meta: '7:00 PM · 12 runners · Riverside Park',
          tag: 'Beginner',
          selected: true,
        ),
        SizedBox(height: 12),
        _RunCard(
          club: 'Sunset Run Crew',
          title: 'Sunset Tempo',
          meta: '6:30 PM · 8 runners · Central Park',
          tag: 'Fast',
        ),
        SizedBox(height: 12),
        _RunCard(
          club: 'Weekend Long Run',
          title: '10K City Loop',
          meta: 'Tomorrow · 21 runners · Waterfront',
          tag: 'Long run',
        ),
      ],
    );
  }
}

class _RunCard extends StatelessWidget {
  const _RunCard({
    required this.club,
    required this.title,
    required this.meta,
    required this.tag,
    this.selected = false,
  });

  static const Color _ink = Colors.black;
  static const Color _volt = Color(0xFFE2FF3D);

  final String club;
  final String title;
  final String meta;
  final String tag;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? _ink : Colors.white;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: selected ? _volt : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected ? _volt : Colors.white.withValues(alpha: 0.22),
          width: 1.4,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: _volt.withValues(alpha: 0.30),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: selected
                  ? _ink.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.directions_run_rounded, color: fg, size: 24),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        club,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.archivo(
                          color: fg.withValues(alpha: 0.68),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? _ink.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.archivo(
                          color: fg,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.kanit(
                    color: fg,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    fontSize: 21,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: fg.withValues(alpha: 0.72),
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.archivo(
                          color: fg.withValues(alpha: 0.78),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Abstract route accent: premium motion without pretending to be a real map.
class _RouteAccentPainter extends CustomPainter {
  const _RouteAccentPainter(this.t);

  final double t;

  static const Color _volt = Color(0xFFE2FF3D);

  @override
  void paint(Canvas canvas, Size size) {
    final route = Path()
      ..moveTo(size.width * -0.05, size.height * 0.24)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.08,
        size.width * 0.36,
        size.height * 0.34,
        size.width * 0.54,
        size.height * 0.18,
      )
      ..cubicTo(
        size.width * 0.74,
        size.height * 0.02,
        size.width * 1.02,
        size.height * 0.22,
        size.width * 0.86,
        size.height * 0.52,
      );

    canvas.drawPath(
      route,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.15),
    );

    final metrics = route.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final m = metrics.first;
      final distance = m.length * t;
      final tan = m.getTangentForOffset(distance);
      if (tan != null) {
        final p = tan.position;
        canvas.drawCircle(
          p,
          18,
          Paint()..color = _volt.withValues(alpha: 0.16),
        );
        canvas.drawCircle(p, 5, Paint()..color = _volt);
      }
    }

    for (final point in [
      Offset(size.width * 0.18, size.height * 0.2),
      Offset(size.width * 0.58, size.height * 0.22),
      Offset(size.width * 0.78, size.height * 0.42),
    ]) {
      final phase = (t + point.dx / size.width) % 1;
      canvas.drawCircle(
        point,
        10 + 28 * phase,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = _volt.withValues(alpha: (1 - phase) * 0.25),
      );
      canvas.drawCircle(point, 4, Paint()..color = _volt);
    }
  }

  @override
  bool shouldRepaint(covariant _RouteAccentPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
