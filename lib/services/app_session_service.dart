import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

/// Persists onboarding completion and profile so restarts skip to home.
class AppSessionService {
  AppSessionService._();

  static final AppSessionService instance = AppSessionService._();

  static const _completeKey = 'onboarding_complete';
  static const _profileKey = 'user_profile';

  Future<AppSession> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final complete = prefs.getBool(_completeKey) ?? false;
    final raw = prefs.getString(_profileKey);
    final profile = raw != null
        ? UserProfile.fromJson(
            jsonDecode(raw) as Map<String, dynamic>,
          )
        : const UserProfile();
    return AppSession(profile: profile, isOnboardingComplete: complete);
  }

  Future<void> saveCompleted(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completeKey, true);
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completeKey);
    await prefs.remove(_profileKey);
  }
}

class AppSession {
  const AppSession({
    required this.profile,
    required this.isOnboardingComplete,
  });

  final UserProfile profile;
  final bool isOnboardingComplete;
}
