import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/permissions_service.dart';

/// Onboarding screen to explain and request location, photos, and camera access.
/// Shown right after Get Started. Requesting advances to the next step.
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({
    super.key,
    required this.onContinue,
  });

  final VoidCallback onContinue;

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with SingleTickerProviderStateMixin {
  static const Color _red = Color(0xFFEC3407);
  static const Color _volt = Color(0xFFE2FF3D);

  final _service = PermissionsService.instance;

  late final AnimationController _entrance;
  bool _requesting = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _allow() async {
    if (_requesting) return;
    _requesting = true;
    HapticFeedback.lightImpact();
    try {
      await _service.requestAll();
    } finally {
      if (mounted) {
        widget.onContinue();
      } else {
        _requesting = false;
      }
    }
  }

  void _skip() {
    if (_requesting) return;
    HapticFeedback.selectionClick();
    widget.onContinue();
  }

  Widget _staggered({
    required double start,
    required double end,
    required Widget child,
  }) {
    final anim = CurvedAnimation(
      parent: _entrance,
      curve: Interval(start.clamp(0, 1), end.clamp(0, 1),
          curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (context, c) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - anim.value)),
          child: c,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _red,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _staggered(
                start: 0,
                end: 0.45,
                child: Text(
                  'BEFORE YOU RUN',
                  style: GoogleFonts.archivo(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _staggered(
                start: 0.05,
                end: 0.55,
                child: Text(
                  'Let Rovu\nwork for you.',
                  style: GoogleFonts.kanit(
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontSize: 44,
                    height: 0.92,
                    letterSpacing: -1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _staggered(
                start: 0.12,
                end: 0.62,
                child: Text(
                  'We need a few permissions to show nearby runs, clubs, and help you build your profile.',
                  style: GoogleFonts.archivo(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  itemCount: PermissionsService.onboardingPermissions.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final permission =
                        PermissionsService.onboardingPermissions[i];
                    final start = 0.2 + i * 0.12;
                    return _staggered(
                      start: start,
                      end: start + 0.5,
                      child: _PermissionCard(permission: permission),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Listener(
                onPointerDown:
                    _requesting ? null : (_) => setState(() => _pressed = true),
                onPointerUp:
                    _requesting ? null : (_) => setState(() => _pressed = false),
                onPointerCancel: _requesting
                    ? null
                    : (_) => setState(() => _pressed = false),
                child: AnimatedScale(
                  scale: _pressed ? 0.97 : 1,
                  duration: const Duration(milliseconds: 120),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: _volt.withValues(alpha: 0.35),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _requesting ? null : _allow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _volt,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: _volt,
                        disabledForegroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                        'Allow permissions',
                        style: GoogleFonts.kanit(
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                          fontSize: 21,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: _requesting ? null : _skip,
                child: Text(
                  'Not now',
                  style: GoogleFonts.archivo(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({required this.permission});

  final AppPermission permission;

  IconData get _icon {
    switch (permission) {
      case AppPermission.location:
        return Icons.location_on_rounded;
      case AppPermission.photos:
        return Icons.photo_library_rounded;
      case AppPermission.camera:
        return Icons.camera_alt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  permission.title,
                  style: GoogleFonts.kanit(
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  permission.description,
                  style: GoogleFonts.archivo(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    height: 1.35,
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
