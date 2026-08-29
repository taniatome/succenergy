import 'package:flutter/foundation.dart';

import '../../data/models/onboarding_response.dart';
import '../../data/repositories/user_repository.dart';

/// Holds the user's saved answers to the five Purpose prompts.
class PurposeProvider extends ChangeNotifier {
  PurposeProvider(this._users);

  final UserRepository _users;

  Map<String, Map<String, String>> _answers =
      const <String, Map<String, String>>{};
  bool _loading = true;

  bool get loading => _loading;

  /// Prompt ids in the order the screen renders them.
  static const List<String> promptIds = <String>[
    'talents',
    'strengths',
    'values',
    'direction',
    'aspirations',
  ];

  String answerFor(String promptId, String localeCode) =>
      OnboardingResponse.textFor(
        _answers[promptId] ?? const <String, String>{},
        localeCode,
      );

  int get answeredCount =>
      promptIds
          .where(
            (String id) =>
                (_answers[id] ?? const <String, String>{}).isNotEmpty,
          )
          .length;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _answers = await _users.loadPurposeAnswers();
    _loading = false;
    notifyListeners();
  }

  Future<void> save({required String promptId, required String answer}) async {
    await _users.savePurposeAnswer(promptId: promptId, answer: answer);
    _answers = await _users.loadPurposeAnswers();
    notifyListeners();
  }
}
