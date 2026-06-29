import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/components.dart';
import 'onboarding_models.dart';

/// Screen 9 — Welcome celebration, personalized.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.profile,
    required this.onFindRun,
    required this.onPostRun,
    this.onExplore,
  });

  final OnboardingProfile profile;
  final VoidCallback onFindRun;
  final VoidCallback onPostRun;
  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    final name = profile.displayName ?? 'Runner';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Text('🎉', textAlign: TextAlign.center, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: AppSpacing.lg),
              Text(
                profile.welcomeMessage(name).toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTheme.display(38),
              ),
              const Spacer(flex: 2),
              _ActionCard(
                title: 'Find a run today',
                subtitle: 'See what\'s happening near you right now',
                icon: Icons.near_me_rounded,
                onTap: onFindRun,
              ),
              const SizedBox(height: AppSpacing.sm),
              _ActionCard(
                title: 'Post my first run',
                subtitle: 'Be the one who brings people together',
                icon: Icons.add_circle_outline,
                onTap: onPostRun,
              ),
              const Spacer(),
              GestureDetector(
                onTap: onExplore ?? onFindRun,
                child: Text(
                  'Or explore at your own pace →',
                  textAlign: TextAlign.center,
                  style: AppTheme.body(15, color: AppColors.textSecondary,
                      weight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          const SizedBox(width: 2),
          IconBadge(icon: icon, color: AppColors.cyan, tint: AppColors.blueTint),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(), style: AppTheme.display(17)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTheme.body(13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textFaint),
        ],
      ),
    );
  }
}
