import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/onboarding_response.dart';
import '../../data/repositories/user_repository.dart';

/// Drives the seven-question assessment.
///
/// Holds the draft answers, the current step, and whether the step is
/// complete enough to advance. Step [AppConstants.onboardingQuestionCount] is
/// the closing summary.
class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider(this._users);

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

  /// Life areas offered by question two, at most two selectable.
  static const List<String> focusAreaOptions = <String>[
    'onboarding.option.career',
    'onboarding.option.business',
    'onboarding.option.health',
    'onboarding.option.relationships',
    'onboarding.option.learning',
    'onboarding.option.finances',
    'onboarding.option.purposeArea',
  ];

  /// Priorities offered by question four, at most three selectable.
  static const List<String> priorityOptions = <String>[
    'onboarding.option.confidence',
    'onboarding.option.focus',
    'onboarding.option.discipline',
    'onboarding.option.visibility',
    'onboarding.option.balance',
    'onboarding.option.income',
    'onboarding.option.team',
  ];

  static const int maxFocusAreas = 2;
  static const int maxPriorities = 3;

  bool get canAdvance {
    switch (_step) {
      case 0:
        return _text(_draft.ambition).isNotEmpty;
      case 1:
        return _draft.focusAreaKeys.isNotEmpty;
      case 2:
        return _text(_draft.challenge).isNotEmpty;
      case 3:
        return _draft.priorityKeys.isNotEmpty;
      case 4:
        return _text(_draft.mainGoals).isNotEmpty;
      case 5:
        return _motivationSet;
      case 6:
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

  void setAmbition(String value) {
    _draft = _draft.copyWith(ambition: OnboardingResponse.asTyped(value));
    notifyListeners();
  }

  void setChallenge(String value) {
    _draft = _draft.copyWith(challenge: OnboardingResponse.asTyped(value));
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

  void toggleFocusArea(String key) {
    _draft = _draft.copyWith(
      focusAreaKeys: _toggle(_draft.focusAreaKeys, key, maxFocusAreas),
    );
    notifyListeners();
  }

  void togglePriority(String key) {
    _draft = _draft.copyWith(
      priorityKeys: _toggle(_draft.priorityKeys, key, maxPriorities),
    );
    notifyListeners();
  }

  /// Persists the assessment. Called once, from the summary screen.
  Future<void> save() async {
    _saving = true;
    notifyListeners();
    await _users.saveOnboardingResponse(_draft);
    _saving = false;
    notifyListeners();
  }

  String _text(Map<String, String> field) =>
      OnboardingResponse.textFor(field, 'en').trim();

  List<String> _toggle(List<String> current, String key, int limit) {
    final List<String> next = List<String>.from(current);
    if (next.contains(key)) {
      next.remove(key);
    } else {
      if (next.length >= limit) {
        next.removeAt(0);
      }
      next.add(key);
    }
    return next;
  }
}
