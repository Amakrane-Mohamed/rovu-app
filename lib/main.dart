import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'get_started_screen.dart';
import 'models/user_profile.dart';
import 'onboarding/auth_screen.dart';
import 'onboarding/permissions_screen.dart';
import 'onboarding/profile_setup_screen.dart';
import 'onboarding/promise_screen.dart';
import 'onboarding/questionnaire_screen.dart';
import 'onboarding/runs_near_you_screen.dart';
import 'services/auth_service.dart';
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
    await AuthService.initialize(
      url: dotenv.env['SUPABASE_URL'],
      anonKey: dotenv.env['SUPABASE_ANON_KEY'],
    );
  } catch (_) {
    await AuthService.initialize();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROVU',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.barlowCondensedTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFEC3407)),
      ),
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

enum _Stage {
  splash,
  getStarted,
  permissions,
  runsNearYou,
  questionnaire,
  promise,
  auth,
  profile,
  home,
}

class _RootPageState extends State<RootPage> {
  _Stage _stage = _Stage.splash;
  UserProfile _profile = const UserProfile();

  Widget _current() {
    switch (_stage) {
      case _Stage.splash:
        return SplashScreen(
          onFinished: () => setState(() => _stage = _Stage.getStarted),
        );
      case _Stage.getStarted:
        return GetStartedScreen(
          onGetStarted: () => setState(() => _stage = _Stage.permissions),
        );
      case _Stage.permissions:
        return PermissionsScreen(
          onContinue: () => setState(() => _stage = _Stage.runsNearYou),
        );
      case _Stage.runsNearYou:
        return RunsNearYouScreen(
          onContinue: () => setState(() => _stage = _Stage.questionnaire),
        );
      case _Stage.questionnaire:
        return QuestionnaireScreen(
          onFinished: (answers) => setState(() {
            _profile = _profile.copyWith(questionnaire: answers);
            _stage = _Stage.promise;
          }),
          onSkip: () => setState(() => _stage = _Stage.promise),
        );
      case _Stage.promise:
        return PromiseScreen(
          answers: _profile.questionnaire,
          onContinue: () => setState(() => _stage = _Stage.auth),
        );
      case _Stage.auth:
        return AuthScreen(
          onAuthenticated: ({required userId, email, required provider}) {
            setState(() {
              _profile = _profile.copyWith(
                userId: userId,
                email: email,
                authProvider: provider,
              );
              _stage = _Stage.profile;
            });
          },
        );
      case _Stage.profile:
        return ProfileSetupScreen(
          profile: _profile,
          onFinished: (profile) => setState(() {
            _profile = profile;
            _stage = _Stage.home;
          }),
        );
      case _Stage.home:
        return HomePage(profile: _profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _current(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final name = profile.displayName ?? 'Runner';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('ROVU'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $name',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (profile.bio != null) ...[
              const SizedBox(height: 8),
              Text(
                profile.bio!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 15,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Your profile is set. Runs and clubs will appear here.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
