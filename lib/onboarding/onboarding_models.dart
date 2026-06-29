/// User profile built during onboarding — matches Crovu strategy doc.
class OnboardingProfile {
  const OnboardingProfile({
    this.runStyle,
    this.pace,
    this.city = 'Casablanca',
    this.displayName,
  });

  /// Solo | Casual | Club
  final String? runStyle;

  /// Easy | Moderate | Fast
  final String? pace;

  final String city;
  final String? displayName;

  OnboardingProfile copyWith({
    String? runStyle,
    String? pace,
    String? city,
    String? displayName,
  }) {
    return OnboardingProfile(
      runStyle: runStyle ?? this.runStyle,
      pace: pace ?? this.pace,
      city: city ?? this.city,
      displayName: displayName ?? this.displayName,
    );
  }

  bool get isClubPath => runStyle == 'Club';
  bool get questionsComplete => runStyle != null && pace != null;

  /// Screen 6 — tailored personalization copy.
  String get matchMessage {
    if (runStyle == 'Club' && pace == 'Fast') {
      return '3 running clubs near you are looking for new members this week.';
    }
    if (runStyle == 'Solo' && pace == 'Easy') {
      return 'We found 8 easy-pace runners near you looking for a running buddy.';
    }
    if (runStyle == 'Casual') {
      return '6 group runs near you match your pace this week.';
    }
    if (isClubPath) {
      return '2 clubs in $city are actively recruiting runners like you.';
    }
    return 'We found runners near you ready to go today.';
  }

  String get authHeadline => 'Your runners are waiting. Join free.';

  String welcomeMessage(String name) =>
      "Welcome to Crovu, $name. $city's running crew just got bigger. 🎉";
}

/// Demo runs shown on the map preview (Screen 3).
class PreviewRun {
  const PreviewRun({
    required this.time,
    required this.distance,
    required this.pace,
    required this.spotsLeft,
  });

  final String time;
  final String distance;
  final String pace;
  final int spotsLeft;
}

const previewRuns = [
  PreviewRun(time: '6:30 PM', distance: '8 km', pace: 'Easy', spotsLeft: 3),
  PreviewRun(time: '7:00 AM', distance: '5 km', pace: 'Moderate', spotsLeft: 5),
  PreviewRun(time: '6:00 PM', distance: '10 km', pace: 'Fast', spotsLeft: 2),
  PreviewRun(time: '8:00 AM', distance: '6 km', pace: 'Easy', spotsLeft: 4),
];

const socialProofQuotes = [
  SocialQuote(
    text:
        'I used to run alone every morning. Now I have 12 running friends I met through Crovu.',
    name: 'Sara',
    city: 'Rabat',
    flag: '🇲🇦',
  ),
  SocialQuote(
    text:
        'Found my running club in Lisbon on day one. We run every Saturday.',
    name: 'Miguel',
    city: 'Lisbon',
    flag: '🇵🇹',
  ),
  SocialQuote(
    text: 'Joined a run with strangers. Left with friends.',
    name: 'Amira',
    city: 'Casablanca',
    flag: '🇲🇦',
  ),
];

class SocialQuote {
  const SocialQuote({
    required this.text,
    required this.name,
    required this.city,
    required this.flag,
  });

  final String text;
  final String name;
  final String city;
  final String flag;
}
