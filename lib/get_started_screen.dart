import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({
    super.key,
    required this.onGetStarted,
    this.onSignIn,
  });

  final VoidCallback onGetStarted;
  final VoidCallback? onSignIn;

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with SingleTickerProviderStateMixin {
  static const Color _red = Color(0xFFEC3407);
  static const Color _ink = Colors.black;
  static const Color _volt = Color(0xFFE2FF3D);

  late final VideoPlayerController _controller;
  late final AnimationController _motion;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _buttonSlide;
  late final Animation<double> _buttonFade;
  bool _ready = false;
  bool _buttonPressed = false;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _titleSlide = _slideAnimation(0.05, 0.52, beginDy: 0.22);
    _titleFade = _fadeAnimation(0.05, 0.52);
    _subtitleSlide = _slideAnimation(0.24, 0.68, beginDy: 0.18);
    _subtitleFade = _fadeAnimation(0.24, 0.68);
    _buttonSlide = _slideAnimation(0.42, 1.0, beginDy: 0.2);
    _buttonFade = _fadeAnimation(0.42, 1.0);
    _motion.forward();

    _controller = VideoPlayerController.asset('assets/video1.mp4')
      ..setLooping(true)
      ..setVolume(0.0)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _motion.dispose();
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _fadeAnimation(double begin, double end) {
    return CurvedAnimation(
      parent: _motion,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
  }

  Animation<Offset> _slideAnimation(
    double start,
    double end, {
    required double beginDy,
  }) {
    return Tween<Offset>(
      begin: Offset(0, beginDy),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _motion,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  Widget _entrance({
    required Animation<double> fade,
    required Animation<Offset> slide,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _red,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-bleed media.
          if (_ready)
            FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          else
            const ColoredBox(color: _red),

          // Dissolve the media into the red base so the copy reads cleanly.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00EC3407),
                  Color(0x33EC3407),
                  Color(0xCCEC3407),
                  Color(0xFFEC3407),
                ],
                stops: [0.3, 0.52, 0.72, 0.9],
              ),
            ),
          ),

          // Bottom-anchored content.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _entrance(
                    fade: _titleFade,
                    slide: _titleSlide,
                    child: Text(
                      "OWN THE\nADRENALINE",
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                      style: GoogleFonts.kanit(
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        fontSize: size.height * 0.082,
                        height: 0.9,
                        letterSpacing: -1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _entrance(
                    fade: _subtitleFade,
                    slide: _subtitleSlide,
                    child: Text(
                      'Push your limits. Track every ride—your next rush starts here.',
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: GoogleFonts.archivo(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _entrance(
                    fade: _buttonFade,
                    slide: _buttonSlide,
                    child: Listener(
                      onPointerDown: (_) => setState(() => _buttonPressed = true),
                      onPointerUp: (_) => setState(() => _buttonPressed = false),
                      onPointerCancel: (_) =>
                          setState(() => _buttonPressed = false),
                      child: AnimatedScale(
                        scale: _buttonPressed ? 0.97 : 1,
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOut,
                        child: Container(
                          width: double.infinity,
                          height: 68,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: _volt.withValues(alpha: 0.35),
                                blurRadius: 28,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: widget.onGetStarted,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _volt,
                              foregroundColor: _ink,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: Text(
                              'Get Started',
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
