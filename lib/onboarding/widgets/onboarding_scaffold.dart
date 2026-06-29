import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components.dart';

/// Shared onboarding chrome — premium sport: slim progress + skip, big CTA.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.child,
    this.onSkip,
    this.bottom,
    this.progress,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final VoidCallback? onSkip;
  final Widget? bottom;
  final double? progress;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
              child: Row(
                children: [
                  if (progress != null)
                    Expanded(child: ProgressBar(value: progress!))
                  else
                    const Spacer(),
                  if (onSkip != null) ...[
                    const SizedBox(width: AppSpacing.md),
                    GestureDetector(
                      onTap: onSkip,
                      child: Text('SKIP',
                          style: AppTheme.caption(13, color: AppColors.textFaint)),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(child: Padding(padding: padding, child: child)),
            ?bottom,
          ],
        ),
        ),
      ),
    );
  }
}

class OnboardingPrimaryButton extends StatelessWidget {
  const OnboardingPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: PrimaryButton(label: label, onTap: onTap, enabled: enabled),
    );
  }
}

class OnboardingSecondaryLink extends StatelessWidget {
  const OnboardingSecondaryLink({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTheme.body(15, color: AppColors.textSecondary, weight: FontWeight.w600),
        ),
      ),
    );
  }
}

class ProgressDots extends StatelessWidget {
  const ProgressDots({super.key, required this.total, required this.current});

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final on = i <= current;
        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
            decoration: BoxDecoration(
              color: on ? AppColors.primary : AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}
