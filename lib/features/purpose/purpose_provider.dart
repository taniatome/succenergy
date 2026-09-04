import 'package:flutter/foundation.dart';

import '../../core/network/request_guard.dart';

import '../../data/models/onboarding_response.dart';
import '../../data/repositories/user_repository.dart';

/// Holds the user's saved answers to the five Purpose prompts.
class PurposeProvider extends ChangeNotifier with RequestGuard {
  PurposeProvider(this._users);

  final UserRepository _users;

  Map<String, Map<String, String>> _answers =
      const <String, Map<String, String>>{};
  // Loading and failure state come from RequestGuard.

  bool get loading => isBusy;

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
    await guard(() async {
      _answers = await _users.loadPurposeAnswers();
    });
  }

  /// Saves one answer and re-reads, without blanking the screen: the prompt
  /// card shows its own progress and the rest of the section is unchanged.
  Future<void> save({required String promptId, required String answer}) async {
    await guard(() async {
      await _users.savePurposeAnswer(promptId: promptId, answer: answer);
      _answers = await _users.loadPurposeAnswers();
    }, showLoading: false);
  }
}
