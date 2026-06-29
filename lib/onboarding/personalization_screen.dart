import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'onboarding_models.dart';
import 'widgets/onboarding_scaffold.dart';

/// Screen 6 — Personalized match after questionnaire.
class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({
    super.key,
    required this.profile,
    required this.onContinue,
    this.onSkip,
  });

  final OnboardingProfile profile;
  final VoidCallback onContinue;
  final VoidCallback? onSkip;

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      onSkip: widget.onSkip,
      bottom: OnboardingPrimaryButton(
        label: 'Create my free account',
        onTap: widget.onContinue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            'WE FOUND\nYOUR MATCH.',
            style: AppTheme.display(46),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            widget.profile.matchMessage,
            style: AppTheme.body(18, color: AppColors.textPrimary,
                weight: FontWeight.w500),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: List.generate(4, (i) {
              return AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) {
                  final scale = 1 + (_pulse.value * 0.08 * (i.isEven ? 1 : -1));
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceHigh,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(Icons.person, color: AppColors.textFaint),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Runners near you — join to see profiles',
            style: AppTheme.caption(13),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
