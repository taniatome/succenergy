import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/onboarding_response.dart';
import '../../data/repositories/user_repository.dart';

/// Drives the four questions asked after the account exists.
///
/// The second half of the assessment: priorities, main goals, motivation and
/// what success looks like. The first three answers were given by the
/// pre-registration quiz and are merged back in on [save], so Profile shows
/// all seven.
///
/// Holds the draft answers, the current step, and whether the step is complete
/// enough to advance. Step [AppConstants.onboardingQuestionCount] is the
/// closing summary.
class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider(this._users) {
    _loadQuizAnswers();
  }

  final UserRepository _users;

  int _step = 0;
  OnboardingResponse _draft = OnboardingResponse.empty;
  bool _saving = false;

  /// Whether the user has actually placed the motivation scale. The draft
  /// starts it mid-track, so its value alone cannot tell us they answered.
  bool _motivationSet = false;

  int get step => _step;

  OnboardingResponse get draft => _draft;

  bool get saving => _saving;

  /// True once the user has moved past the last question.
  bool get isSummary => _step >= AppConstants.onboardingQuestionCount;

  /// Fraction of the assessment completed, for the header rule.
  double get progress =>
      (_step / AppConstants.onboardingQuestionCount).clamp(0.0, 1.0);

  /// Priorities offered by the first question here, at most three selectable.
  static const List<String> priorityOptions = <String>[
    'onboarding.option.confidence',
    'onboarding.option.focus',
    'onboarding.option.discipline',
    'onboarding.option.visibility',
    'onboarding.option.balance',
    'onboarding.option.income',
    'onboarding.option.team',
  ];

  static const int maxPriorities = 3;

  bool get canAdvance {
    switch (_step) {
      case 0:
        return _draft.priorityKeys.isNotEmpty;
      case 1:
        return _text(_draft.mainGoals).isNotEmpty;
      case 2:
        return _motivationSet;
      case 3:
        return _text(_draft.successVision).isNotEmpty;
      default:
        return true;
    }
  }

  void next() {
    if (_step >= AppConstants.onboardingQuestionCount) {
      return;
    }
    _step++;
    notifyListeners();
  }

  void back() {
    if (_step == 0) {
      return;
    }
    _step--;
    notifyListeners();
  }

  void setMainGoals(String value) {
    _draft = _draft.copyWith(mainGoals: OnboardingResponse.asTyped(value));
    notifyListeners();
  }

  void setSuccessVision(String value) {
    _draft = _draft.copyWith(successVision: OnboardingResponse.asTyped(value));
    notifyListeners();
  }

  void setMotivation(double value) {
    _motivationSet = true;
    _draft = _draft.copyWith(motivationBalance: value);
    notifyListeners();
  }

  void togglePriority(String key) {
    final List<String> next = List<String>.from(_draft.priorityKeys);
    if (next.contains(key)) {
      next.remove(key);
    } else {
      if (next.length >= maxPriorities) {
        next.removeAt(0);
      }
      next.add(key);
    }
    _draft = _draft.copyWith(priorityKeys: next);
    notifyListeners();
  }

  /// Reads the three pre-registration answers into the draft, so the closing
  /// summary shows the whole assessment rather than the half asked here.
  Future<void> _loadQuizAnswers() async {
    final OnboardingResponse stored = await _users.loadOnboardingResponse();
    _draft = _draft.copyWith(
      ambition: stored.ambition,
      focusAreaKeys: stored.focusAreaKeys,
      challenge: stored.challenge,
    );
    notifyListeners();
  }

  /// Persists the assessment. Called once, from the summary screen.
  ///
  /// The quiz answers are read again here rather than trusted from the draft,
  /// so a slow first read can never write three empty fields over them.
  Future<void> save() async {
    _saving = true;
    notifyListeners();
    final OnboardingResponse stored = await _users.loadOnboardingResponse();
    _draft = _draft.copyWith(
      ambition: stored.ambition,
      focusAreaKeys: stored.focusAreaKeys,
      challenge: stored.challenge,
    );
    await _users.saveOnboardingResponse(_draft);
    _saving = false;
    notifyListeners();
  }

  String _text(Map<String, String> field) =>
      OnboardingResponse.textFor(field, 'en').trim();
}
