import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';

/// Account creation — Apple and Google sign-in.
class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.onAuthenticated,
  });

  final void Function({
    required String userId,
    String? email,
    required String provider,
  }) onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  static const Color _red = Color(0xFFEC3407);

  late final AnimationController _entrance;
  bool _loading = false;
  String? _provider;
  String? _error;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _signIn(Future<AuthResult> Function() action, String id) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _provider = id;
      _error = null;
    });
    try {
      final result = await action();
      if (!mounted) return;
      HapticFeedback.lightImpact();
      widget.onAuthenticated(
        userId: result.userId,
        email: result.email,
        provider: result.provider,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _provider = null;
        });
      }
    }
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
          offset: Offset(0, 24 * (1 - anim.value)),
          child: c,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _red,
      body: Stack(
        children: [
          // Club photo across the top, dissolving into the red base.
          SizedBox(
            height: size.height * 0.52,
            width: double.infinity,
            child: ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.white, Colors.transparent],
                stops: [0.0, 0.62, 1.0],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/club.jpeg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          // Red wash so the photo blends with the brand color, not a hard edge.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _red.withValues(alpha: 0.25),
                  _red.withValues(alpha: 0.55),
                  _red,
                ],
                stops: const [0.0, 0.32, 0.46],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 6),
                  _reveal(
                    start: 0.1,
                    end: 0.55,
                    child: Text(
                      'JOIN THE\nMOVEMENT.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.kanit(
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        fontSize: 60,
                        height: 0.9,
                        letterSpacing: -1.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _reveal(
                    start: 0.2,
                    end: 0.65,
                    child: Text(
                      'Save your profile, join runs, and connect with clubs near you.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.archivo(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  _reveal(
                    start: 0.45,
                    end: 0.85,
                    child: _AuthButton(
                      label: 'Continue with Apple',
                      icon: Icons.apple,
                      style: _AuthButtonStyle.light,
                      loading: _loading && _provider == 'apple',
                      onTap: () => _signIn(
                        AuthService.instance.signInWithApple,
                        'apple',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _reveal(
                    start: 0.55,
                    end: 0.95,
                    child: _AuthButton(
                      label: 'Continue with Google',
                      iconWidget: const _GoogleLogo(),
                      style: _AuthButtonStyle.volt,
                      loading: _loading && _provider == 'google',
                      onTap: () => _signIn(
                        AuthService.instance.signInWithGoogle,
                        'google',
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.archivo(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _reveal(
                    start: 0.7,
                    end: 1,
                    child: Text(
                      'Free to use. No credit card required.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.archivo(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _AuthButtonStyle { light, volt }

class _AuthButton extends StatefulWidget {
  const _AuthButton({
    required this.label,
    required this.onTap,
    required this.style,
    this.icon,
    this.iconWidget,
    this.loading = false,
  });

  final String label;
  final VoidCallback onTap;
  final _AuthButtonStyle style;
  final IconData? icon;
  final Widget? iconWidget;
  final bool loading;

  @override
  State<_AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<_AuthButton> {
  static const Color _ink = Colors.black;
  static const Color _volt = Color(0xFFE2FF3D);

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isVolt = widget.style == _AuthButtonStyle.volt;
    final bg = isVolt ? _volt : Colors.white;
    final glow = isVolt ? _volt : Colors.black;

    return Listener(
      onPointerDown: widget.loading ? null : (_) => setState(() => _pressed = true),
      onPointerUp: widget.loading ? null : (_) => setState(() => _pressed = false),
      onPointerCancel:
          widget.loading ? null : (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: GestureDetector(
          onTap: widget.loading ? null : widget.onTap,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: glow.withValues(alpha: isVolt ? 0.32 : 0.18),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: widget.loading
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: _ink,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.iconWidget != null)
                        widget.iconWidget!
                      else
                        Icon(widget.icon, size: 24, color: _ink),
                      const SizedBox(width: 12),
                      Text(
                        widget.label,
                        style: GoogleFonts.kanit(
                          color: _ink,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                          fontSize: 20,
                          letterSpacing: 0.1,
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

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/googlepng.png',
      width: 24,
      height: 24,
      fit: BoxFit.contain,
    );
  }
}
