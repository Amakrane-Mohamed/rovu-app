import 'dart:convert';
import 'dart:io' show Platform;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles Google and Apple sign-in through Supabase Auth.
/// Falls back to a local session when Supabase is not configured (dev).
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static bool _initialized = false;

  static bool get isConfigured =>
      const String.fromEnvironment('SUPABASE_URL').isNotEmpty ||
      _envUrl != null;

  static String? _envUrl;

  static Future<void> initialize({
    String? url,
    String? anonKey,
  }) async {
    _envUrl = url;

    final supabaseUrl =
        url ?? const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    final supabaseKey = anonKey ??
        const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

    if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          'AuthService: Supabase not configured — auth will use dev mode.',
        );
      }
      return;
    }

    if (_initialized) return;

    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseKey,
    );
    _initialized = true;
  }

  SupabaseClient? get _client {
    if (!_initialized) return null;
    return Supabase.instance.client;
  }

  /// Native Apple sign-in on iOS; web OAuth elsewhere.
  Future<AuthResult> signInWithApple() async {
    final client = _client;
    if (client == null) {
      return _devMock('apple');
    }

    if (!kIsWeb && Platform.isIOS) {
      return _signInWithAppleNative(client);
    }

    return _signInWithOAuth(client, OAuthProvider.apple, 'apple');
  }

  /// Sign in with Google via Supabase OAuth, or dev mock when not configured.
  Future<AuthResult> signInWithGoogle() async {
    final client = _client;
    if (client == null) {
      return _devMock('google');
    }

    return _signInWithOAuth(client, OAuthProvider.google, 'google');
  }

  Future<AuthResult> _signInWithAppleNative(SupabaseClient client) async {
    try {
      final rawNonce = client.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const AuthException('Could not get Apple identity token.');
      }

      final response = await client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      final user = response.user ?? client.auth.currentUser;
      if (user == null) {
        throw const AuthException('Sign-in failed.');
      }

      return AuthResult(
        userId: user.id,
        email: user.email ?? credential.email,
        provider: 'apple',
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthException('Sign-in cancelled.');
      }
      throw AuthException(e.message);
    }
  }

  Future<AuthResult> _signInWithOAuth(
    SupabaseClient client,
    OAuthProvider provider,
    String label,
  ) async {
    final launched = await client.auth.signInWithOAuth(
      provider,
      redirectTo: kIsWeb ? null : 'io.supabase.rovu://login-callback/',
    );

    if (!launched) {
      throw const AuthException('Could not open sign-in.');
    }

    for (var i = 0; i < 30; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final user = client.auth.currentUser;
      if (user != null) {
        return AuthResult(
          userId: user.id,
          email: user.email,
          provider: label,
        );
      }
    }

    throw const AuthException('Sign-in timed out. Please try again.');
  }

  Future<AuthResult> _devMock(String label) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return AuthResult(
      userId: 'dev_${label}_${DateTime.now().millisecondsSinceEpoch}',
      email: 'runner@example.com',
      provider: label,
    );
  }
}

class AuthResult {
  const AuthResult({
    required this.userId,
    this.email,
    required this.provider,
  });

  final String userId;
  final String? email;
  final String provider;
}
