import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components.dart';
import '../models.dart';

class RunCard extends StatelessWidget {
  const RunCard({
    super.key,
    required this.run,
    this.featured = false,
    this.onJoin,
  });

  final ClubRun run;
  final bool featured;
  final VoidCallback? onJoin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SportCard(
        color: featured ? const Color(0xFF1C1410) : AppColors.surface,
        borderColor: featured ? AppColors.primary.withValues(alpha: 0.5) : AppColors.border,
        glowColor: featured ? AppColors.primary : null,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _TimeBadge(time: run.time, featured: featured),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(run.title.toUpperCase(), style: AppTheme.display(20)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(run.meetingPoint,
                                style: AppTheme.body(13), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Row(
                children: [
                  _Meta(icon: Icons.speed_rounded, text: run.pace),
                  Container(width: 1, height: 18, color: AppColors.border),
                  _Meta(icon: Icons.person_outline, text: run.host),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _Avatars(count: run.joined),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '${run.joined} GOING · ${run.spots - run.joined} LEFT',
                    style: AppTheme.caption(11, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                featured
                    ? PrimaryButton(
                        label: 'Join',
                        onTap: onJoin ?? () {},
                        expand: false,
                        height: 42,
                        glow: false,
                        icon: null,
                      )
                    : PrimaryButton.solid(
                        label: 'Join',
                        onTap: onJoin ?? () {},
                        color: AppColors.glassHigh,
                        textColor: AppColors.textPrimary,
                        expand: false,
                        height: 42,
                        icon: null,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  const _TimeBadge({required this.time, required this.featured});

  final String time;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final parts = time.split(' ');
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: featured ? AppColors.heat : null,
        color: featured ? null : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(parts.first,
              style: AppTheme.display(18,
                  color: featured ? Colors.white : AppColors.textPrimary)),
          if (parts.length > 1)
            Text(parts.last,
                style: AppTheme.caption(10,
                    color: featured
                        ? Colors.white.withValues(alpha: 0.9)
                        : AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 15, color: AppColors.primary),
            const SizedBox(width: 5),
            Expanded(
              child: Text(text,
                  style: AppTheme.body(13, color: AppColors.textPrimary, weight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatars extends StatelessWidget {
  const _Avatars({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final shown = count.clamp(0, 3);
    return SizedBox(
      width: shown * 16.0 + 12,
      height: 28,
      child: Stack(
        children: List.generate(shown, (i) {
          return Positioned(
            left: i * 16.0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceHigh,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
              child: Center(
                child: Text(String.fromCharCode(65 + i),
                    style: AppTheme.caption(11, color: AppColors.textPrimary)),
              ),
            ),
          );
        }),
      ),
    );
  }
}
