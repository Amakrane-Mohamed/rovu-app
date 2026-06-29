import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium ROVU questionnaire — red base, lime accent, Kanit sport type.
/// Stepped one-question-at-a-time flow with staggered entrance, press
/// feedback, haptics, and a subtle animated ambient glow.
class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({
    super.key,
    required this.onFinished,
    this.onSkip,
  });

  /// Returns the chosen answers keyed by question id.
  final ValueChanged<Map<String, String>> onFinished;
  final VoidCallback? onSkip;

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen>
    with TickerProviderStateMixin {
  static const Color _red = Color(0xFFEC3407);
  static const Color _volt = Color(0xFFE2FF3D);

  static const _questions = <_Question>[
    _Question(
      id: 'intent',
      title: 'WHAT ARE YOU\nHERE FOR?',
      options: [
        _Option('Join a run', Icons.directions_run_rounded),
        _Option('Find a club', Icons.groups_rounded),
        _Option('Bring my club', Icons.campaign_rounded),
        _Option('Meet runners', Icons.people_alt_rounded),
      ],
    ),
    _Question(
      id: 'vibe',
      title: "WHAT'S YOUR\nRUN VIBE?",
      options: [
        _Option('Easy social', Icons.sentiment_satisfied_alt_rounded),
        _Option('Beginner friendly', Icons.waving_hand_rounded),
        _Option('Long runs', Icons.route_rounded),
        _Option('Fast pace', Icons.bolt_rounded),
      ],
    ),
    _Question(
      id: 'time',
      title: 'WHEN DO\nYOU RUN?',
      options: [
        _Option('Morning', Icons.wb_sunny_rounded),
        _Option('Evening', Icons.nights_stay_rounded),
        _Option('Weekends', Icons.weekend_rounded),
        _Option('Anytime', Icons.schedule_rounded),
      ],
    ),
    _Question(
      id: 'club',
      title: 'ARE YOU IN\nA CLUB?',
      options: [
        _Option('Not yet', Icons.person_add_alt_1_rounded),
        _Option('I run with friends', Icons.diversity_3_rounded),
        _Option("I'm a member", Icons.verified_rounded),
        _Option('I organize a club', Icons.admin_panel_settings_rounded),
      ],
    ),
  ];

  final Map<String, String> _answers = {};
  int _step = 0;

  late final AnimationController _entrance;
  late final AnimationController _ambient;

  _Question get _current => _questions[_step];
  String? get _selected => _answers[_current.id];

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..forward();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entrance.dispose();
    _ambient.dispose();
    super.dispose();
  }

  void _select(String value) {
    HapticFeedback.selectionClick();
    setState(() => _answers[_current.id] = value);
  }

  void _next() {
    if (_selected == null) return;
    HapticFeedback.lightImpact();
    if (_step < _questions.length - 1) {
      setState(() => _step++);
      _entrance.forward(from: 0);
    } else {
      widget.onFinished(_answers);
    }
  }

  void _back() {
    if (_step == 0) return;
    HapticFeedback.lightImpact();
    setState(() => _step--);
    _entrance.forward(from: 0);
  }

  /// Fade + rise driven by [_entrance] over a staggered interval.
  Widget _staggered({
    required double start,
    required double end,
    required Widget child,
  }) {
    final anim = CurvedAnimation(
      parent: _entrance,
      curve: Interval(start.clamp(0, 1), end.clamp(0, 1),
          curve: Curves.easeOutCubic),
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

  @override
  Widget build(BuildContext context) {
    final progress = (_step + 1) / _questions.length;
    final options = _current.options;

    return Scaffold(
      backgroundColor: _red,
      body: Stack(
        children: [
          _AmbientGlow(animation: _ambient),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header: back button (left) + centered progress bar.
                  SizedBox(
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _IconTap(
                            icon: Icons.arrow_back_rounded,
                            onTap: _step == 0 ? null : _back,
                          ),
                        ),
                        Center(
                          child: FractionallySizedBox(
                            widthFactor: 0.5,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: progress),
                                duration: const Duration(milliseconds: 480),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, _) =>
                                    LinearProgressIndicator(
                                  value: value,
                                  minHeight: 6,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.22),
                                  valueColor:
                                      const AlwaysStoppedAnimation(_volt),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Title.
                  _staggered(
                    start: 0,
                    end: 0.5,
                    child: Text(
                      _current.title,
                      key: ValueKey('title_${_current.id}'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.kanit(
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        fontSize: 52,
                        height: 0.92,
                        letterSpacing: -1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Options with staggered entrance.
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      itemCount: options.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final opt = options[i];
                        final start = 0.18 + i * 0.10;
                        return _staggered(
                          start: start,
                          end: start + 0.5,
                          child: _OptionCard(
                            key: ValueKey('${_current.id}_${opt.label}'),
                            option: opt,
                            selected: _selected == opt.label,
                            onTap: () => _select(opt.label),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),
                  _ContinueButton(
                    label:
                        _step == _questions.length - 1 ? 'Finish' : 'Continue',
                    enabled: _selected != null,
                    onTap: _next,
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

/// Subtle breathing glow blobs behind the content for depth.
class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.animation});

  static const Color _volt = Color(0xFFE2FF3D);

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final v = animation.value; // 0..1
        return Stack(
          children: [
            Positioned(
              top: -140 + 40 * v,
              right: -90,
              child: _blob(280, _volt.withValues(alpha: 0.16 + 0.08 * v)),
            ),
            Positioned(
              bottom: -120 - 30 * v,
              left: -110,
              child: _blob(340, Colors.black.withValues(alpha: 0.22)),
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

class _Question {
  const _Question({
    required this.id,
    required this.title,
    required this.options,
  });

  final String id;
  final String title;
  final List<_Option> options;
}

class _Option {
  const _Option(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _OptionCard extends StatefulWidget {
  const _OptionCard({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _Option option;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard> {
  static const Color _ink = Colors.black;
  static const Color _volt = Color(0xFFE2FF3D);

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: selected ? _volt : Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? _volt : Colors.white.withValues(alpha: 0.24),
                width: 1.5,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: _volt.withValues(alpha: 0.40),
                        blurRadius: 26,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected
                        ? _ink.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.option.icon,
                    color: selected ? _ink : Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.option.label,
                    style: GoogleFonts.kanit(
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: selected ? _ink : Colors.white,
                      fontSize: 19,
                    ),
                  ),
                ),
                AnimatedScale(
                  scale: selected ? 1 : 0,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutBack,
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: _ink,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatefulWidget {
  const _ContinueButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton> {
  static const Color _ink = Colors.black;
  static const Color _volt = Color(0xFFE2FF3D);

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    return Listener(
      onPointerDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onPointerUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onPointerCancel: enabled ? (_) => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.45,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: _volt.withValues(alpha: 0.35),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ]
                  : null,
            ),
            child: ElevatedButton(
              onPressed: enabled ? widget.onTap : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _volt,
                foregroundColor: _ink,
                disabledBackgroundColor: _volt,
                disabledForegroundColor: _ink,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                widget.label,
                style: GoogleFonts.kanit(
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  fontSize: 21,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconTap extends StatelessWidget {
  const _IconTap({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
