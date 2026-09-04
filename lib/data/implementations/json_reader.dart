/// Reading values out of a decoded API payload.
///
/// Every mapper in this folder goes through these rather than casting
/// directly. A field that is missing, null or the wrong type takes a defined
/// fallback instead of throwing: an app that will not open because one
/// optional string arrived as a number is worse than one showing an empty
/// title, and the alternative is a `try` around every field.
///
/// This is the only place in the app that knows the wire is JSON.
class Json {
  const Json._();

  /// A nested object, or an empty map.
  static Map<String, Object?> object(Object? value) {
    return value is Map<String, Object?> ? value : const <String, Object?>{};
  }

  /// A list of nested objects, dropping anything that is not one.
  static List<Map<String, Object?>> objects(Object? value) {
    if (value is! List) {
      return const <Map<String, Object?>>[];
    }
    return value.whereType<Map<String, Object?>>().toList(growable: false);
  }

  static String text(Object? value, {String fallback = ''}) {
    return value is String ? value : fallback;
  }

  static String? textOrNull(Object? value) => value is String ? value : null;

  static int integer(Object? value, {int fallback = 0}) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static double number(Object? value, {double fallback = 0}) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static bool flag(Object? value, {bool fallback = false}) {
    return value is bool ? value : fallback;
  }

  /// An ISO 8601 timestamp, or null when absent or unparseable.
  static DateTime? dateOrNull(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value)?.toLocal();
  }

  /// An ISO 8601 timestamp, falling back to [fallback] or now.
  static DateTime date(Object? value, {DateTime? fallback}) {
    return dateOrNull(value) ?? fallback ?? DateTime.now();
  }

  /// A locale map, keeping only string values.
  ///
  /// The API sends `{en, pt}` for everything the app renders. A map with one
  /// side missing is normal — the person wrote in one language — and the
  /// models already fall back to English.
  static Map<String, String> localized(Object? value) {
    final Map<String, Object?> raw = object(value);
    final Map<String, String> out = <String, String>{};
    raw.forEach((String key, Object? entry) {
      if (entry is String) {
        out[key] = entry;
      }
    });
    return out;
  }

  /// A map of string to string, for the answers a session recorded.
  static Map<String, String> strings(Object? value) => localized(value);

  /// A list of strings, dropping anything else.
  static List<String> stringList(Object? value) {
    if (value is! List) {
      return const <String>[];
    }
    return value.whereType<String>().toList(growable: false);
  }

  /// An enum value by name, falling back when the wire carries something the
  /// app does not know — a value added by a newer backend, most likely.
  static T enumByName<T extends Enum>(
    Object? value,
    List<T> values,
    T fallback,
  ) {
    if (value is! String) {
      return fallback;
    }
    for (final T candidate in values) {
      if (candidate.name == value) {
        return candidate;
      }
    }
    return fallback;
  }
}
