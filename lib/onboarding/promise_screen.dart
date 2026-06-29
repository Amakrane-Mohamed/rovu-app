import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Personal Promise — the payoff after the questionnaire. Reflects the user's
/// answers back at them so the app feels built for them personally.
class PromiseScreen extends StatefulWidget {
  const PromiseScreen({
    super.key,
    required this.answers,
    required this.onContinue,
  });

  final Map<String, String> answers;
  final VoidCallback onContinue;

  @override
  State<PromiseScreen> createState() => _PromiseScreenState();
}

class _PromiseScreenState extends State<PromiseScreen>
    with TickerProviderStateMixin {
  static const Color _red = Color(0xFFEC3407);
  static const Color _ink = Colors.black;
  static const Color _volt = Color(0xFFE2FF3D);

  late final AnimationController _entrance;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  String get _vibeWord {
    switch (widget.answers['vibe']) {
      case 'Easy social':
        return 'easy, social';
      case 'Beginner friendly':
        return 'beginner-friendly';
      case 'Long runs':
        return 'long';
      case 'Fast pace':
        return 'fast';
      default:
        return 'social';
    }
  }

  String get _timeWord {
    switch (widget.answers['time']) {
      case 'Morning':
        return 'morning runs';
      case 'Evening':
        return 'evening runs';
      case 'Weekends':
        return 'weekend runs';
      case 'Anytime':
        return 'runs anytime';
      default:
        return 'runs';
    }
  }

  String get _promiseLine => 'Built for runners who love $_vibeWord $_timeWord.';

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              _reveal(
                start: 0,
                end: 0.4,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _volt,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'YOUR MATCH IS READY',
                      style: GoogleFonts.archivo(
                        color: _ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _reveal(
                start: 0.1,
                end: 0.5,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'YOUR CROVU\nIS READY.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.kanit(
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      fontSize: 48,
                      height: 0.94,
                      letterSpacing: -1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _reveal(
                start: 0.2,
                end: 0.6,
                child: Text(
                  _promiseLine,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.archivo(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              _reveal(
                start: 0.34,
                end: 0.74,
                child: const _MatchStats(),
              ),
              const SizedBox(height: 22),
              _reveal(
                start: 0.46,
                end: 0.84,
                child: const _BenefitRow(
                  icon: Icons.directions_run_rounded,
                  title: 'Runs near you',
                  subtitle: 'Join group runs starting close by, any day.',
                ),
              ),
              _reveal(
                start: 0.54,
                end: 0.9,
                child: const _BenefitRow(
                  icon: Icons.location_on_rounded,
                  title: 'Never lose the group',
                  subtitle: 'Live location keeps the whole run together.',
                ),
              ),
              _reveal(
                start: 0.62,
                end: 0.96,
                child: const _BenefitRow(
                  icon: Icons.ios_share_rounded,
                  title: 'Share every run',
                  subtitle: 'Auto-made cards worth posting after you finish.',
                ),
              ),
              const Spacer(flex: 3),
              _reveal(
                start: 0.7,
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
                          'Show My Runs',
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
    );
  }
}

class _MatchStats extends StatelessWidget {
  const _MatchStats();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _StatTile(end: 7, label: 'RUNS\nMATCHED')),
        SizedBox(width: 12),
        Expanded(child: _StatTile(end: 4, label: 'CLUBS\nNEARBY')),
        SizedBox(width: 12),
        Expanded(child: _StatTile(end: 58, label: 'RUNNERS\nLIKE YOU')),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.end, required this.label});

  static const Color _volt = Color(0xFFE2FF3D);

  final int end;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: end.toDouble()),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Text(
              value.round().toString(),
              style: GoogleFonts.kanit(
                color: _volt,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                fontSize: 30,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.archivo(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w800,
              fontSize: 10,
              height: 1.2,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  static const Color _ink = Colors.black;
  static const Color _volt = Color(0xFFE2FF3D);

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _volt,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _volt.withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: _ink, size: 22),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.archivo(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.archivo(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                      fontSize: 12.5,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
