import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/onboarding_response.dart';
import '../../data/repositories/user_repository.dart';

/// Drives the three questions asked before an account exists.
///
/// The first half of the same seven-question assessment: what the user wants,
/// where their energy has to go, and what is in the way. The answers are held
/// here until they are written through [UserRepository.saveQuizAnswers], where
/// the four post-registration questions later join them.
class QuizProvider extends ChangeNotifier {
  QuizProvider(this._users);

  final UserRepository _users;

  int _step = 0;
  Map<String, String> _ambition = const <String, String>{};
  List<String> _focusAreaKeys = const <String>[];
  Map<String, String> _challenge = const <String, String>{};
  bool _saving = false;

  int get step => _step;

  bool get saving => _saving;

  Map<String, String> get ambition => _ambition;

  List<String> get focusAreaKeys => _focusAreaKeys;

  Map<String, String> get challenge => _challenge;

  /// Fraction of the quiz completed, for the header rule.
  double get progress =>
      ((_step + 1) / AppConstants.quizQuestionCount).clamp(0.0, 1.0);

  /// True on the last question, where the action creates the account.
  bool get isLast => _step == AppConstants.quizQuestionCount - 1;

  /// Life areas offered by question two, at most two selectable.
  static const List<String> focusAreaOptions = <String>[
    'onboarding.option.career',
    'onboarding.option.business',
    'onboarding.option.health',
    'onboarding.option.relationships',
    'onboarding.option.learning',
    'onboarding.option.finances',
    'onboarding.option.purposeArea',
    'onboarding.option.procrastination',
    'onboarding.option.stress',
    'onboarding.option.balancedLife',
  ];

  static const int maxFocusAreas = 2;

  bool get canAdvance {
    switch (_step) {
      case 0:
        return _text(_ambition).isNotEmpty;
      case 1:
        return _focusAreaKeys.isNotEmpty;
      default:
        return _text(_challenge).isNotEmpty;
    }
  }

  void next() {
    if (isLast) {
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
    _ambition = OnboardingResponse.asTyped(value);
    notifyListeners();
  }

  void setChallenge(String value) {
    _challenge = OnboardingResponse.asTyped(value);
    notifyListeners();
  }

  void toggleFocusArea(String key) {
    final List<String> next = List<String>.from(_focusAreaKeys);
    if (next.contains(key)) {
      next.remove(key);
    } else {
      if (next.length >= maxFocusAreas) {
        next.removeAt(0);
      }
      next.add(key);
    }
    _focusAreaKeys = next;
    notifyListeners();
  }

  /// Hands the three answers to the repository, from where registration and
  /// the four remaining questions pick them up.
  Future<void> save() async {
    _saving = true;
    notifyListeners();
    await _users.saveQuizAnswers(
      ambition: _ambition,
      focusAreaKeys: _focusAreaKeys,
      challenge: _challenge,
    );
    _saving = false;
    notifyListeners();
  }

  String _text(Map<String, String> field) =>
      OnboardingResponse.textFor(field, 'en').trim();
}
