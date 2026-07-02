/// Profile collected during onboarding and sign-up.
class UserProfile {
  const UserProfile({
    this.questionnaire = const {},
    this.displayName,
    this.bio,
    this.email,
    this.authProvider,
    this.userId,
    this.avatarPath,
  });

  final Map<String, String> questionnaire;
  final String? displayName;
  final String? bio;
  final String? email;
  final String? authProvider;
  final String? userId;
  final String? avatarPath;

  bool get hasAuth => userId != null;
  bool get isProfileComplete =>
      displayName != null && displayName!.trim().isNotEmpty;

  String get intent => questionnaire['intent'] ?? '';
  String get vibe => questionnaire['vibe'] ?? '';
  String get time => questionnaire['time'] ?? '';
  String get club => questionnaire['club'] ?? '';

  UserProfile copyWith({
    Map<String, String>? questionnaire,
    String? displayName,
    String? bio,
    String? email,
    String? authProvider,
    String? userId,
    String? avatarPath,
  }) {
    return UserProfile(
      questionnaire: questionnaire ?? this.questionnaire,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      authProvider: authProvider ?? this.authProvider,
      userId: userId ?? this.userId,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'questionnaire': questionnaire,
        'displayName': displayName,
        'bio': bio,
        'email': email,
        'authProvider': authProvider,
        'userId': userId,
        'avatarPath': avatarPath,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['questionnaire'];
    return UserProfile(
      questionnaire: rawAnswers is Map
          ? rawAnswers.map((k, v) => MapEntry('$k', '$v'))
          : const {},
      displayName: json['displayName'] as String?,
      bio: json['bio'] as String?,
      email: json['email'] as String?,
      authProvider: json['authProvider'] as String?,
      userId: json['userId'] as String?,
      avatarPath: json['avatarPath'] as String?,
    );
  }
}
