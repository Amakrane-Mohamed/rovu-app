import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';

/// Profile setup after authentication — a stepped, one-part-per-screen flow:
/// photo, name, bio, then a review. Mirrors the questionnaire's premium
/// red/volt sport styling with progress, staggered entrance, and haptics.
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({
    super.key,
    required this.profile,
    required this.onFinished,
  });

  final UserProfile profile;
  final ValueChanged<UserProfile> onFinished;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

enum _Step { photo, name, bio, review }

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with TickerProviderStateMixin {
  static const Color _red = Color(0xFFEC3407);
  static const Color _volt = Color(0xFFE2FF3D);

  static const int _bioMax = 160;

  late final TextEditingController _name;
  late final TextEditingController _bio;
  late final AnimationController _entrance;

  String? _avatarPath;
  int _index = 0;

  static const _steps = _Step.values;
  _Step get _step => _steps[_index];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.displayName ?? '');
    _bio = TextEditingController(text: widget.profile.bio ?? '');
    _avatarPath = widget.profile.avatarPath;
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..forward();
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _entrance.dispose();
    super.dispose();
  }

  bool get _canContinue {
    switch (_step) {
      case _Step.name:
        return _name.text.trim().isNotEmpty;
      case _Step.photo:
      case _Step.bio:
      case _Step.review:
        return true;
    }
  }

  String get _ctaLabel {
    switch (_step) {
      case _Step.photo:
        return _avatarPath == null ? 'Skip for now' : 'Continue';
      case _Step.review:
        return 'Finish';
      case _Step.name:
      case _Step.bio:
        return 'Continue';
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (file != null) {
        HapticFeedback.lightImpact();
        setState(() => _avatarPath = file.path);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open photos.')),
        );
      }
    }
  }

  void _showPhotoOptions() {
    FocusScope.of(context).unfocus();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(
          'Profile photo',
          style: GoogleFonts.archivo(fontWeight: FontWeight.w600),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheetContext);
              _pickPhoto(ImageSource.gallery);
            },
            child: const Text('Choose from Library'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheetContext);
              _pickPhoto(ImageSource.camera);
            },
            child: const Text('Take Photo'),
          ),
          if (_avatarPath != null)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(sheetContext);
                setState(() => _avatarPath = null);
              },
              child: const Text('Remove Photo'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(sheetContext),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (!_canContinue) return;
    HapticFeedback.lightImpact();
    if (_index < _steps.length - 1) {
      setState(() => _index++);
      _entrance.forward(from: 0);
    } else {
      _submit();
    }
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_index == 0) return;
    HapticFeedback.lightImpact();
    setState(() => _index--);
    _entrance.forward(from: 0);
  }

  void _submit() {
    HapticFeedback.mediumImpact();
    widget.onFinished(
      widget.profile.copyWith(
        displayName: _name.text.trim(),
        bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
        avatarPath: _avatarPath,
      ),
    );
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
          offset: Offset(0, 26 * (1 - anim.value)),
          child: c,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_index + 1) / _steps.length;

    return Scaffold(
      backgroundColor: _red,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _IconTap(
                        icon: Icons.arrow_back_rounded,
                        onTap: _index == 0 ? null : _back,
                      ),
                    ),
                    Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: progress),
                            duration: const Duration(milliseconds: 480),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) =>
                                LinearProgressIndicator(
                              value: value,
                              minHeight: 6,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.22),
                              valueColor:
                                  const AlwaysStoppedAnimation(_volt),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _buildStep(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _ContinueButton(
                label: _ctaLabel,
                enabled: _canContinue,
                onTap: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _Step.photo:
        return _photoStep();
      case _Step.name:
        return _nameStep();
      case _Step.bio:
        return _bioStep();
      case _Step.review:
        return _reviewStep();
    }
  }

  Widget _header(String title) {
    return _staggered(
      start: 0.08,
      end: 0.55,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: GoogleFonts.kanit(
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          color: Colors.white,
          fontSize: 44,
          height: 0.92,
          letterSpacing: -1.2,
        ),
      ),
    );
  }

  Widget _photoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header('Add a face\nto the name.'),
        const SizedBox(height: 36),
        _staggered(
          start: 0.25,
          end: 0.8,
          child: Center(
            child: GestureDetector(
              onTap: _showPhotoOptions,
              child: Stack(
                children: [
                  Container(
                    width: 156,
                    height: 156,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                      border: Border.all(
                        color: _avatarPath != null
                            ? _volt
                            : Colors.white.withValues(alpha: 0.28),
                        width: 2,
                      ),
                      image: _avatarPath != null
                          ? DecorationImage(
                              image: FileImage(File(_avatarPath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _avatarPath != null
                        ? null
                        : const Icon(
                            Icons.add_a_photo_outlined,
                            color: Colors.white,
                            size: 44,
                          ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _volt,
                        shape: BoxShape.circle,
                        border: Border.all(color: _red, width: 3),
                      ),
                      child: Icon(
                        _avatarPath != null
                            ? Icons.edit_rounded
                            : Icons.add_rounded,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _staggered(
          start: 0.35,
          end: 0.9,
          child: Text(
            _avatarPath != null
                ? 'Looking sharp. Tap to change it.'
                : 'A photo helps runners recognize you.\nYou can always add it later.',
            textAlign: TextAlign.center,
            style: GoogleFonts.archivo(
              color: Colors.white.withValues(alpha: 0.75),
              fontWeight: FontWeight.w500,
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _nameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header("What should\nwe call you?"),
        const SizedBox(height: 32),
        _staggered(
          start: 0.25,
          end: 0.8,
          child: _TextField(
            controller: _name,
            hint: 'Your name',
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _next(),
          ),
        ),
        const SizedBox(height: 14),
        _staggered(
          start: 0.35,
          end: 0.9,
          child: Text(
            'This is how you’ll show up on runs and in clubs.',
            style: GoogleFonts.archivo(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _bioStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header('Tell the crew\nabout you.'),
        const SizedBox(height: 32),
        _staggered(
          start: 0.25,
          end: 0.8,
          child: _TextField(
            controller: _bio,
            hint: 'A short line about your running (optional)',
            maxLines: 4,
            maxLength: _bioMax,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 8),
        _staggered(
          start: 0.35,
          end: 0.9,
          child: Text(
            'Optional — share your pace, goals, or favorite route.',
            style: GoogleFonts.archivo(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _reviewStep() {
    final prefs = _preferenceTags(widget.profile.questionnaire);
    final name = _name.text.trim().isEmpty ? 'Runner' : _name.text.trim();
    final bio = _bio.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header('Looking\ngood.'),
        const SizedBox(height: 32),
        _staggered(
          start: 0.2,
          end: 0.75,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                    border: Border.all(color: _volt, width: 2),
                    image: _avatarPath != null
                        ? DecorationImage(
                            image: FileImage(File(_avatarPath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _avatarPath != null
                      ? null
                      : Center(
                          child: Text(
                            name.substring(0, 1).toUpperCase(),
                            style: GoogleFonts.kanit(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              fontSize: 36,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.kanit(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    fontSize: 26,
                  ),
                ),
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.archivo(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
                if (prefs.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        prefs.map((t) => _PreferenceChip(label: t)).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _staggered(
          start: 0.3,
          end: 0.85,
          child: Center(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _index = 0;
                  _entrance.forward(from: 0);
                });
              },
              child: Text(
                'Edit details',
                style: GoogleFonts.archivo(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<String> _preferenceTags(Map<String, String> answers) {
    final tags = <String>[];
    for (final key in ['intent', 'vibe', 'time', 'club']) {
      final v = answers[key];
      if (v != null && v.isNotEmpty) tags.add(v);
    }
    return tags;
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final int? maxLength;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      textInputAction:
          maxLines > 1 ? TextInputAction.newline : TextInputAction.done,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      cursorColor: const Color(0xFFE2FF3D),
      style: GoogleFonts.archivo(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.archivo(
          color: Colors.white.withValues(alpha: 0.45),
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.12),
        counterStyle: GoogleFonts.archivo(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2FF3D), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _PreferenceChip extends StatelessWidget {
  const _PreferenceChip({required this.label});

  static const Color _volt = Color(0xFFE2FF3D);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _volt.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: _volt.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: GoogleFonts.archivo(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ContinueButton extends StatefulWidget {
  const _ContinueButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton> {
  static const Color _ink = Colors.black;
  static const Color _volt = Color(0xFFE2FF3D);

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    return Listener(
      onPointerDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onPointerUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onPointerCancel: enabled ? (_) => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.45,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: _volt.withValues(alpha: 0.35),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ]
                  : null,
            ),
            child: ElevatedButton(
              onPressed: enabled ? widget.onTap : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _volt,
                foregroundColor: _ink,
                disabledBackgroundColor: _volt,
                disabledForegroundColor: _ink,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                widget.label,
                style: GoogleFonts.kanit(
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  fontSize: 21,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconTap extends StatelessWidget {
  const _IconTap({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
