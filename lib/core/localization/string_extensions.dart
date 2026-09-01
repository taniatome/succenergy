import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'locale_provider.dart';

/// String lookup for widgets: `context.tr('goals.title')`.
///
/// Placeholders in the copy are written as `{name}` and filled through
/// [params]. Widgets never hold literal display text.
extension LocalizedContext on BuildContext {
  String tr(String key, {Map<String, String>? params}) {
    return _fill(watch<LocaleProvider>().resolve(key), params);
  }

  /// The same lookup for event handlers.
  ///
  /// Form validation runs from a tap rather than from a build, and `watch` is
  /// not allowed there: it would subscribe a callback to locale changes and
  /// asserts. Error messages resolve through this instead.
  String trRead(String key, {Map<String, String>? params}) {
    return _fill(read<LocaleProvider>().resolve(key), params);
  }

  /// The active language code, for data that carries per-locale variants.
  String get localeCode => watch<LocaleProvider>().code;

  String _fill(String raw, Map<String, String>? params) {
    if (params == null || params.isEmpty) {
      return raw;
    }
    String out = raw;
    params.forEach((String token, String value) {
      out = out.replaceAll('{$token}', value);
    });
    return out;
  }
}
