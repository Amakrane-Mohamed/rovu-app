import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/rovu_brand.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  static const _tabs = [
    _TabConfig(label: 'Home', icon: Icons.bolt_outlined, activeIcon: Icons.bolt),
    _TabConfig(
      label: 'Explore',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
    ),
    _TabConfig(label: 'Create', icon: Icons.add, activeIcon: Icons.add, center: true),
    _TabConfig(
      label: 'Club',
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups,
    ),
    _TabConfig(
      label: 'You',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RovuBrand.red,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const RovuAmbientGlow(),
          SafeArea(
            bottom: false,
            child: const SizedBox.expand(),
          ),
        ],
      ),
      bottomNavigationBar: _RovuTabBar(
        index: _tab,
        tabs: _tabs,
        onTap: (i) {
          HapticFeedback.selectionClick();
          setState(() => _tab = i);
        },
      ),
    );
  }
}

class _TabConfig {
  const _TabConfig({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.center = false,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool center;
}

class _RovuTabBar extends StatelessWidget {
  const _RovuTabBar({
    required this.index,
    required this.tabs,
    required this.onTap,
  });

  final int index;
  final List<_TabConfig> tabs;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (i) {
              final tab = tabs[i];
              final selected = i == index;

              if (tab.center) {
                return GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: RovuBrand.volt,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: RovuBrand.volt.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: RovuBrand.ink, size: 28),
                  ),
                );
              }

              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 56,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? tab.activeIcon : tab.icon,
                        size: 24,
                        color: selected
                            ? RovuBrand.volt
                            : Colors.white.withValues(alpha: 0.42),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tab.label,
                        style: RovuBrand.body(
                          10,
                          color: selected
                              ? RovuBrand.volt
                              : Colors.white.withValues(alpha: 0.42),
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
