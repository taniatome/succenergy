import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'locale_provider.dart';

/// String lookup for widgets: `context.tr('goals.title')`.
///
/// Placeholders in the copy are written as `{name}` and filled through
/// [params]. Widgets never hold literal display text.
extension LocalizedContext on BuildContext {
  String tr(String key, {Map<String, String>? params}) {
    final String raw = watch<LocaleProvider>().resolve(key);
    if (params == null || params.isEmpty) {
      return raw;
    }
    String out = raw;
    params.forEach((String token, String value) {
      out = out.replaceAll('{$token}', value);
    });
    return out;
  }

  /// The active language code, for data that carries per-locale variants.
  String get localeCode => watch<LocaleProvider>().code;
}
