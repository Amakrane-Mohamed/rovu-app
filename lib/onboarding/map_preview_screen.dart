import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'onboarding_models.dart';
import 'widgets/onboarding_scaffold.dart';

/// Screen 3 — Live map preview (aha moment, before signup).
class MapPreviewScreen extends StatefulWidget {
  const MapPreviewScreen({
    super.key,
    required this.profile,
    required this.onContinue,
    this.onSkip,
  });

  final OnboardingProfile profile;
  final VoidCallback onContinue;
  final VoidCallback? onSkip;

  @override
  State<MapPreviewScreen> createState() => _MapPreviewScreenState();
}

class _MapPreviewScreenState extends State<MapPreviewScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final city = widget.profile.city;
    return OnboardingScaffold(
      onSkip: widget.onSkip,
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _CityMap(),
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) => CustomPaint(
              painter: _PulsePainter(_pulse.value),
              size: Size.infinite,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.35, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.onSkip != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: GestureDetector(
                        onTap: widget.onSkip,
                        child: Text('Skip',
                            style: AppTheme.body(16,
                                color: AppColors.textSecondary,
                                weight: FontWeight.w500)),
                      ),
                    ),
                  ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    '$city is\nrunning now.'.toUpperCase(),
                    style: AppTheme.display(40),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    scrollDirection: Axis.horizontal,
                    itemCount: previewRuns.length,
                    separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, i) => _BlurredRunCard(run: previewRuns[i]),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    'Join to see who\'s running',
                    style: AppTheme.body(14, color: AppColors.textFaint),
                  ),
                ),
                OnboardingPrimaryButton(
                  label: 'Join for free — takes 10 seconds',
                  onTap: widget.onContinue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CityMap extends StatelessWidget {
  const _CityMap();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MapPainter(), size: Size.infinite);
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0E1014),
    );
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    // Street lines
    final streets = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.45),
      streets,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.15),
      Offset(size.width * 0.4, size.height * 0.85),
      streets,
    );
    // Runner dots
    final rng = math.Random(7);
    for (int i = 0; i < 12; i++) {
      final p = Offset(
        size.width * (0.15 + rng.nextDouble() * 0.7),
        size.height * (0.2 + rng.nextDouble() * 0.6),
      );
      canvas.drawCircle(p, 5, Paint()..color = AppColors.primary);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PulsePainter extends CustomPainter {
  _PulsePainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(3);
    for (int i = 0; i < 6; i++) {
      final center = Offset(
        size.width * (0.2 + rng.nextDouble() * 0.6),
        size.height * (0.25 + rng.nextDouble() * 0.5),
      );
      final phase = (t + i * 0.17) % 1.0;
      final radius = 20 + 60 * phase;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = AppColors.primary.withValues(alpha: (1 - phase) * 0.4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PulsePainter old) => old.t != t;
}

class _BlurredRunCard extends StatelessWidget {
  const _BlurredRunCard({required this.run});

  final PreviewRun run;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(run.time, style: AppTheme.title(18, weight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('${run.distance} · ${run.pace}',
                  style: AppTheme.body(13)),
              const SizedBox(height: 6),
              Text('${run.spotsLeft} spots left',
                  style: AppTheme.caption(12, color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
