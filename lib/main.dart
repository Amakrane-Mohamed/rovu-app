import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'get_started_screen.dart';
import 'splash_screen.dart';

void main() {
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

enum _Stage { splash, getStarted, home }

class _RootPageState extends State<RootPage> {
  _Stage _stage = _Stage.splash;

  Widget _current() {
    switch (_stage) {
      case _Stage.splash:
        return SplashScreen(
          onFinished: () => setState(() => _stage = _Stage.getStarted),
        );
      case _Stage.getStarted:
        return GetStartedScreen(
          onGetStarted: () => setState(() => _stage = _Stage.home),
        );
      case _Stage.home:
        return const HomePage();
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
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('ROVU'),
      ),
      body: const Center(
        child: Text('Welcome to ROVU', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
