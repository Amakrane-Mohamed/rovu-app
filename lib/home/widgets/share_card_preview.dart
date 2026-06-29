import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components.dart';
import '../models.dart';
import 'route_map.dart';

/// The post-run share card — a core Crovu visual.
class ShareCardPreview extends StatelessWidget {
  const ShareCardPreview({super.key, required this.memory});

  final PastRunMemory memory;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              RouteMap(seed: 42, height: 180),
              Positioned(
                left: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(memory.distance.toUpperCase(),
                        style: AppTheme.display(40, color: Colors.white)),
                    Text('${memory.city.toUpperCase()} · ${memory.crew.toUpperCase()}',
                        style: AppTheme.caption(11,
                            color: Colors.white.withValues(alpha: 0.9))),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(memory.title.toUpperCase(), style: AppTheme.display(16)),
                      const SizedBox(height: 2),
                      Text(memory.date, style: AppTheme.body(13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.blueTint,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.ios_share, size: 16, color: AppColors.blue),
                      const SizedBox(width: 6),
                      Text('SHARE',
                          style: AppTheme.caption(12, color: AppColors.blue)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
