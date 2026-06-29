import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components.dart';
import '../models.dart';

class ClubStrip extends StatelessWidget {
  const ClubStrip({super.key, required this.club});

  final RunningClub club;

  @override
  Widget build(BuildContext context) {
    return SportCard(
      onTap: () {},
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.heat,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Text(club.initials,
                style: AppTheme.display(20, color: Colors.white)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(club.name.toUpperCase(), style: AppTheme.display(18)),
                const SizedBox(height: 3),
                Text('${club.members} MEMBERS · NEXT ${club.nextRun.toUpperCase()}',
                    style: AppTheme.caption(11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textFaint, size: 24),
        ],
      ),
    );
  }
}
