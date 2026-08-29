import 'package:flutter/widgets.dart';

import '../constants/app_constants.dart';
import 'app_strings.dart';

/// Holds the active language for the whole app.
///
/// Provided once in `main.dart`; read by the root widget and by
/// `context.tr(...)`. Changing it rebuilds every screen immediately.
class LocaleProvider extends ChangeNotifier {
  LocaleProvider({String initialCode = AppStrings.fallbackLocale})
    : _code = initialCode;

  String _code;

  /// Active language code, one of [AppConstants.supportedLocales].
  String get code => _code;

  Locale get locale => Locale(_code);

  /// True once the user has made an explicit language choice.
  bool get hasChosen => _hasChosen;
  bool _hasChosen = false;

  void setLocale(String code) {
    if (!AppConstants.supportedLocales.contains(code)) {
      return;
    }
    _hasChosen = true;
    if (_code == code) {
      notifyListeners();
      return;
    }
    _code = code;
    notifyListeners();
  }

  /// Resolves a key for the active language, falling back to English.
  String resolve(String key) {
    final Map<String, String>? active = AppStrings.values[_code];
    final String? value = active?[key];
    if (value != null) {
      return value;
    }
    return AppStrings.values[AppStrings.fallbackLocale]?[key] ?? key;
  }
}
