import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/components.dart';
import 'models.dart';
import 'widgets/club_strip.dart';
import 'widgets/run_card.dart';
import 'widgets/share_card_preview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: AppBackground(
        child: _tab == 0
          ? const _HomeTab()
          : _PlaceholderTab(
              title: switch (_tab) {
                1 => 'Explore',
                2 => 'Create',
                3 => 'Club',
                _ => 'You',
              },
            ),
      ),
      bottomNavigationBar: SportNavBar(
        index: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          SportNavItem(icon: Icons.bolt_outlined, activeIcon: Icons.bolt),
          SportNavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore),
          SportNavItem(icon: Icons.add, activeIcon: Icons.add, isCenter: true),
          SportNavItem(icon: Icons.groups_outlined, activeIcon: Icons.groups),
          SportNavItem(icon: Icons.person_outline, activeIcon: Icons.person),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final tonight = demoRuns.firstWhere((r) => r.isTonight);
    final others = demoRuns.where((r) => !r.isTonight).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
            child: Reveal(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text('CASABLANCA',
                                style: AppTheme.caption(12,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      _RoundIcon(icon: Icons.notifications_none_rounded),
                      const SizedBox(width: 10),
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: AppColors.heat,
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                        child: Text('Y',
                            style: AppTheme.display(18, color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('GOOD\nEVENING.', style: AppTheme.display(48)),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
            child: Reveal(index: 1, child: const _WeekStats()),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Reveal(index: 2, child: const SectionTitle(label: 'Tonight')),
              const SizedBox(height: AppSpacing.sm),
              Reveal(
                index: 3,
                child: RunCard(run: tonight, featured: true, onJoin: () {}),
              ),
              const SizedBox(height: AppSpacing.xl),
              Reveal(index: 4, child: const SectionTitle(label: 'Your club')),
              const SizedBox(height: AppSpacing.sm),
              Reveal(index: 5, child: const ClubStrip(club: demoClub)),
              const SizedBox(height: AppSpacing.xl),
              Reveal(
                index: 6,
                child: const SectionTitle(label: 'Also today', action: 'See all'),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (var i = 0; i < others.length; i++)
                Reveal(index: 7 + i, child: RunCard(run: others[i], onJoin: () {})),
              const SizedBox(height: AppSpacing.lg),
              Reveal(index: 9, child: const SectionTitle(label: 'Last run')),
              const SizedBox(height: AppSpacing.sm),
              Reveal(index: 10, child: const ShareCardPreview(memory: demoMemory)),
            ]),
          ),
        ),
      ],
    );
  }
}

class _WeekStats extends StatelessWidget {
  const _WeekStats();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      tint: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('THIS WEEK', style: AppTheme.caption(12)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.greenTint,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, size: 13, color: AppColors.green),
                    const SizedBox(width: 3),
                    Text('+18%', style: AppTheme.caption(11, color: AppColors.green)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              StatBlock(value: '24.8', label: 'km run'),
              SizedBox(width: AppSpacing.xl),
              StatBlock(value: '3', label: 'runs'),
              SizedBox(width: AppSpacing.xl),
              StatBlock(value: '2h 11', label: 'time'),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.glassHigh,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.glassStroke),
      ),
      child: Icon(icon, size: 22, color: AppColors.textPrimary),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title.toUpperCase(),
          style: AppTheme.display(32, color: AppColors.textFaint)),
    );
  }
}
