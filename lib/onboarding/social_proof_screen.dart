import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/components.dart';
import 'onboarding_models.dart';
import 'widgets/onboarding_scaffold.dart';

/// Screen 4 — Social proof before signup.
class SocialProofScreen extends StatelessWidget {
  const SocialProofScreen({
    super.key,
    required this.onContinue,
    this.onSkip,
  });

  final VoidCallback onContinue;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      onSkip: onSkip,
      bottom: OnboardingPrimaryButton(label: 'I want in', onTap: onContinue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            "YOU'RE NOT\nALONE.",
            style: AppTheme.display(46),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final q in socialProofQuotes) ...[
            _QuoteCard(quote: q),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            'Join 2,400 runners across Morocco and Portugal',
            style: AppTheme.body(15, weight: FontWeight.w500,
                color: AppColors.textPrimary),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote});

  final SocialQuote quote;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${quote.text}"',
            style: AppTheme.body(15, color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '— ${quote.name}, ${quote.city} ${quote.flag}',
            style: AppTheme.caption(13),
          ),
        ],
      ),
    );
  }
}
