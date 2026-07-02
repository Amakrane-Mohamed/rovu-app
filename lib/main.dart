import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'get_started_screen.dart';
import 'home/home_screen.dart';
import 'models/user_profile.dart';
import 'onboarding/auth_screen.dart';
import 'onboarding/permissions_screen.dart';
import 'onboarding/profile_setup_screen.dart';
import 'onboarding/promise_screen.dart';
import 'onboarding/questionnaire_screen.dart';
import 'onboarding/runs_near_you_screen.dart';
import 'services/app_session_service.dart';
import 'services/auth_service.dart';
import 'splash_screen.dart';
import 'theme/app_theme.dart';

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
      theme: AppTheme.dark(),
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

  bool _sessionReady = false;
  bool _splashDone = false;
  bool _resumeToHome = false;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final session = await AppSessionService.instance.restore();
    final auth = AuthService.instance;

    UserProfile profile = session.profile;
    if (auth.isSignedIn) {
      final user = auth.currentUser!;
      profile = profile.copyWith(
        userId: user.id,
        email: user.email ?? profile.email,
      );
    }

    if (!mounted) return;
    setState(() {
      _profile = profile;
      _resumeToHome = session.isOnboardingComplete;
      _sessionReady = true;
    });
    _maybeLeaveSplash();
  }

  void _maybeLeaveSplash() {
    if (!_sessionReady || !_splashDone || !mounted) return;
    setState(() {
      _stage = _resumeToHome ? _Stage.home : _Stage.getStarted;
    });
  }

  Future<void> _finishOnboarding(UserProfile profile) async {
    await AppSessionService.instance.saveCompleted(profile);
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _stage = _Stage.home;
      _resumeToHome = true;
    });
  }

  Widget _current() {
    switch (_stage) {
      case _Stage.splash:
        return SplashScreen(
          onFinished: () {
            _splashDone = true;
            _maybeLeaveSplash();
          },
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
          onFinished: _finishOnboarding,
        );
      case _Stage.home:
        return const HomeScreen();
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
