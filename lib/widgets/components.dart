import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Deep aurora gradient with soft blurred color blobs. Put this behind
/// transparent scaffolds so frosted glass surfaces have something to blur.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        const _Blob(
          alignment: Alignment(-1.1, -0.9),
          color: AppColors.primary,
          size: 320,
        ),
        const _Blob(
          alignment: Alignment(1.2, -0.5),
          color: AppColors.violet,
          size: 300,
        ),
        const _Blob(
          alignment: Alignment(0.9, 0.9),
          color: AppColors.cyan,
          size: 260,
          opacity: 0.18,
        ),
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.alignment,
    required this.color,
    required this.size,
    this.opacity = 0.28,
  });

  final Alignment alignment;
  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: opacity), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

/// Frosted glass surface — translucent fill, hairline highlight, real blur.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppRadii.lg,
    this.onTap,
    this.tint,
    this.borderColor,
    this.blur = 18,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? tint;
  final Color? borderColor;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);
    final glow = tint != null;

    Widget surface = ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.04),
              ],
            ),
            color: tint?.withValues(alpha: 0.16),
            borderRadius: br,
            border: Border.all(
              color: borderColor ?? AppColors.glassStroke,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );

    surface = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: br,
        boxShadow: [
          BoxShadow(
            color: glow
                ? tint!.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.35),
            blurRadius: glow ? 34 : 22,
            spreadRadius: glow ? -6 : -8,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: surface,
    );

    if (onTap == null) return surface;
    return _Press(onTap: onTap!, child: surface);
  }
}

/// Backwards-compatible alias used by home cards.
class SportCard extends StatelessWidget {
  const SportCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color = AppColors.surface,
    this.borderColor = AppColors.border,
    this.radius = AppRadii.lg,
    this.onTap,
    this.glowColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final double radius;
  final VoidCallback? onTap;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding,
      radius: radius,
      onTap: onTap,
      tint: glowColor,
      borderColor: borderColor,
      child: child,
    );
  }
}

class _Press extends StatefulWidget {
  const _Press({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  State<_Press> createState() => _PressState();
}

class _PressState extends State<_Press> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.98 : 1,
        duration: AppMotion.fast,
        child: widget.child,
      ),
    );
  }
}

/// Staggered fade + slide-up entrance.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 26,
    this.duration = AppMotion.medium,
  });

  final Widget child;
  final int index;
  final double offset;
  final Duration duration;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 70 * widget.index), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _c, curve: AppMotion.emphasized);
    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) => Opacity(
        opacity: curve.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - curve.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Big sport section title with an accent tick and optional action.
class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.label, this.action, this.onAction});

  final String label;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            gradient: AppColors.heat,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(label.toUpperCase(), style: AppTheme.display(22)),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!.toUpperCase(),
                style: AppTheme.caption(12, color: AppColors.cyan)),
          ),
      ],
    );
  }
}

/// Premium pressable gradient button with aurora glow.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.gradient = AppColors.heat,
    this.solidColor,
    this.textColor = Colors.white,
    this.icon = Icons.arrow_forward_rounded,
    this.enabled = true,
    this.expand = true,
    this.height = 58,
    this.glow = true,
  });

  final String label;
  final VoidCallback onTap;
  final LinearGradient gradient;
  final Color? solidColor;
  final Color textColor;
  final IconData? icon;
  final bool enabled;
  final bool expand;
  final double height;
  final bool glow;

  // Compat: allow `color:` callers via factory-like constructor.
  factory PrimaryButton.solid({
    Key? key,
    required String label,
    required VoidCallback onTap,
    required Color color,
    Color textColor = Colors.white,
    IconData? icon,
    bool expand = true,
    double height = 58,
    bool glow = false,
  }) {
    return PrimaryButton(
      key: key,
      label: label,
      onTap: onTap,
      solidColor: color,
      textColor: textColor,
      icon: icon,
      expand: expand,
      height: height,
      glow: glow,
    );
  }

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    final fg = enabled ? widget.textColor : AppColors.textFaint;

    final btn = AnimatedScale(
      scale: _down ? 0.97 : 1,
      duration: AppMotion.fast,
      child: Container(
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: (widget.solidColor == null && enabled) ? widget.gradient : null,
          color: !enabled
              ? AppColors.glassHigh
              : (widget.solidColor),
          borderRadius: BorderRadius.circular(AppRadii.md),
          boxShadow: (widget.glow && enabled)
              ? [
                  BoxShadow(
                    color: (widget.solidColor ?? AppColors.primary)
                        .withValues(alpha: 0.5),
                    blurRadius: 28,
                    spreadRadius: -4,
                    offset: const Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.label.toUpperCase(),
                style: AppTheme.display(18, color: fg, letterSpacing: 0.8)),
            if (widget.icon != null) ...[
              const SizedBox(width: 10),
              Icon(widget.icon, color: fg, size: 22),
            ],
          ],
        ),
      ),
    );

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapUp: enabled ? (_) => setState(() => _down = false) : null,
      onTapCancel: enabled ? () => setState(() => _down = false) : null,
      onTap: enabled ? widget.onTap : null,
      child: widget.expand ? SizedBox(width: double.infinity, child: btn) : btn,
    );
  }
}

/// Glass outline button.
class SecondaryButton extends StatefulWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.height = 58,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final double height;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: AppMotion.fast,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: double.infinity,
              height: widget.height,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.glassHigh,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.glassStroke, width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: AppColors.textPrimary, size: 22),
                    const SizedBox(width: 10),
                  ],
                  Text(widget.label, style: AppTheme.title(16, weight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded-square tinted icon badge.
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.color = AppColors.primary,
    this.tint = AppColors.primaryTint,
    this.size = 50,
    this.iconSize = 26,
  });

  final IconData icon;
  final Color color;
  final Color tint;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: AppColors.glassStroke),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

/// Big number + label stat, scoreboard style.
class StatBlock extends StatelessWidget {
  const StatBlock({
    super.key,
    required this.value,
    required this.label,
    this.color = AppColors.textPrimary,
    this.alignment = CrossAxisAlignment.start,
  });

  final String value;
  final String label;
  final Color color;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: AppTheme.display(30, color: color, height: 0.9)),
        const SizedBox(height: 4),
        Text(label.toUpperCase(),
            style: AppTheme.caption(11, color: AppColors.textFaint)),
      ],
    );
  }
}

/// Slim aurora progress bar.
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, this.height = 8});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.glassHigh,
        borderRadius: BorderRadius.circular(height),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            AnimatedContainer(
              duration: AppMotion.medium,
              curve: AppMotion.emphasized,
              width: constraints.maxWidth * clamped,
              height: height,
              decoration: BoxDecoration(
                gradient: AppColors.heat,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating glass bottom nav with a gradient center action.
class SportNavBar extends StatelessWidget {
  const SportNavBar({
    super.key,
    required this.index,
    required this.onTap,
    required this.items,
  });

  final int index;
  final ValueChanged<int> onTap;
  final List<SportNavItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.glassHigh,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(color: AppColors.glassStroke),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(items.length, (i) {
                    final selected = i == index;
                    final item = items[i];
                    if (item.isCenter) {
                      return GestureDetector(
                        onTap: () => onTap(i),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: AppColors.heat,
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.55),
                                blurRadius: 18,
                                spreadRadius: -2,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 28),
                        ),
                      );
                    }
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(i),
                      child: SizedBox(
                        width: 52,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              selected ? item.activeIcon : item.icon,
                              size: 25,
                              color: selected ? AppColors.cyan : AppColors.textFaint,
                            ),
                            const SizedBox(height: 5),
                            AnimatedContainer(
                              duration: AppMotion.fast,
                              width: selected ? 16 : 0,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: AppColors.heat,
                                borderRadius: BorderRadius.circular(2),
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
          ),
        ),
      ),
    );
  }
}

class SportNavItem {
  const SportNavItem({
    required this.icon,
    required this.activeIcon,
    this.isCenter = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final bool isCenter;
}
